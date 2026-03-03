import { pool } from '../config/postgres.js';
import { parse } from 'csv-parse/sync';

import {
  upsertCliente,
  upsertAutor,
  upsertCategoria,
  upsertLibro,
  upsertOrden,
  upsertDetalleOrden,
} from '../repositories/migracionLibros.repository.js';

function normalizarFila(raw) {
  const get = (...keys) => {
    for (const k of keys) {
      if (raw[k] !== undefined) return raw[k];
    }
    return undefined;
  };

  return {
    order_id: String(get('order_id') || '').trim(),
    order_date: String(get('order_date') || '').trim(),
    customer_name: String(get('customer_name') || '').trim(),
    customer_email: String(get('customer_email') || '').trim().toLowerCase(),
    book_isbn: String(get('book_isbn') || '').trim(),
    book_title: String(get('book_title') || '').trim(),
    category_name: String(get('category_name') || '').trim(),
    author_name: String(get('author_name') || '').trim(),
    unit_price: String(get('unit_price') || '').trim(),
    quantity: String(get('quantity') || '').trim(),
  };
}

function parseNumero(val) {
  const n = Number(String(val).replace(',', '.'));
  return Number.isNaN(n) ? null : n;
}

export async function migrarLibrosCsv(buffer) {
  const csvText = buffer.toString('utf-8');

  const rows = parse(csvText, {
    columns: true,
    skip_empty_lines: true,
    trim: true,
  });

  if (!rows.length) {
    throw new Error('archivo vacío');
  }

  const client = await pool.connect();

  let procesadas = 0;
  let errores = 0;

  try {
    await client.query('begin');

    for (const raw of rows) {
      const row = normalizarFila(raw);

      if (!row.order_id || !row.customer_email || !row.book_isbn) {
        errores++;
        continue;
      }

      const price = parseNumero(row.unit_price);
      const qty = parseNumero(row.quantity);

      if (!price || !qty) {
        errores++;
        continue;
      }

      const total_line = Number((price * qty).toFixed(2));

      // 1️⃣ Cliente
      const cliente_id = await upsertCliente(client, {
        nombre: row.customer_name,
        email: row.customer_email,
      });

      // 2️⃣ Autor
      const autor_id = await upsertAutor(client, {
        nombre: row.author_name,
      });

      // 3️⃣ Categoría
      const categoria_id = await upsertCategoria(client, {
        nombre: row.category_name,
      });

      // 4️⃣ Libro
      const libro_id = await upsertLibro(client, {
        isbn: row.book_isbn,
        titulo: row.book_title,
        categoria_id,
        autor_id,
      });

      // 5️⃣ Orden
      const orden_id = await upsertOrden(client, {
        order_id: row.order_id,
        fecha: row.order_date,
        cliente_id,
      });

      // 6️⃣ Detalle
      await upsertDetalleOrden(client, {
        orden_id,
        libro_id,
        unit_price: price,
        quantity: qty,
        total_line,
      });

      procesadas++;
    }

    await client.query('commit');

    return {
      total_filas: rows.length,
      procesadas,
      errores,
    };

  } catch (error) {
    await client.query('rollback');
    throw error;
  } finally {
    client.release();
  }
}
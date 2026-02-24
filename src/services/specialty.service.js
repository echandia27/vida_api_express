import { pool } from "../config/dbconfig.js";

export const createSpecialty = async (name) => {

    const query = `INSERT INTO test.specialty (name) VALUES ($1) RETURNING *`
    const values = [name]

    try {
        const response = await pool.query(query, values);
        return response.rows[0];
    } catch (error) {
        console.error(`Erro al crear la especialidad: ${error}`)
        throw error;
    }

}

export const deleteSpeciality = async (id) => {

    const query = 'DELETE FROM test.specialty WHERE id = $1';
    const values = [id]

    try {
        const response = await pool.query(query, values);
        return response;
    } catch (error) {
        console.error('Error al eliminar una especialidad')
        throw error;
    }
}

export const getAllSpecialitys = async () => {

    const query = `select s.* from test.specialty s`;

    try {
        const response = await pool.query(query);
        return response;
    } catch (error) {
        console.error('Error al obtener las especialidades:', error);
        throw error;
    }

}
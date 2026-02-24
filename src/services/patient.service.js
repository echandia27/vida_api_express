import { pool } from "../config/dbconfig.js";

export const createPatient = async (name, birth_date) => {

    const query = `INSERT INTO test.patient (name, birth_date) VALUES ($1, TO_DATE($2, 'DD/MM/YYYY')) RETURNING id, name`;
    const values = [name, birth_date]

    try {

        const response = await pool.query(query, values);
        if (!response.rows[0]) {
            throw Error("No se ha logrado crear el paciente")
        }
        return response;

    } catch (error) {
        console.error(`No se ha podido crear el paciente: ${error}`);
        throw (error);
    }

}


export const getAllPatients = async () => {
    const query = `SELECT * FROM test.patient`
    try {
        const response = await pool.query(query);
        if (!response.rows[0]) {
            throw Error("No se ha logrado obtener los pacientes")
        }
        return response;
    } catch (error) {
        console.error(`No se ha podido obtener los pacientes: ${error}`);
        throw (error);
    }
}


export const deletePatient = async (id) => {

    const query = `DELETE FROM test.patient WHERE id = $1`;
    const values = [id];

    try {
        const response = await pool.query(query, values)

        if (response.rowCount === 0) {
            throw new Error('No se ha logrado eliminar el paciente')
        }

        return response;

    } catch (error) {
        console.error(`No se ha podido eliminar el paciente: ${error}`)
        throw error;
    }

}
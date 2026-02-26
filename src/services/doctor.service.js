import { pool } from "../config/dbconfig.js";

export const createDoctor = async ({ name, specialty }) => {

    const query = 'CALL test.sp_create_doctor($1::text, $2::text, null, null)';
    const values = [name, specialty];

    try {
        const response = await pool.query(query, values);
        return response.rows[0];
    } catch (error) {
        console.error('Error al crear el doctor:', error);
        throw error;
    }

}

export const getAllDoctors = async () => {

    const query = `select p.name as nombre_paciente, p.*, d.* from test.doctor d
                   inner join test.appointment a on a.doctor_id =  d.id
                   inner join test.patient p on a.patient_id = p.id limit 100`;

    try {
        const response = await pool.query(query);
        return response.rows;
    } catch (error) {
        console.error('Error al obtener los doctores:', error);
        throw error;
    }

}

export const deleteDoctor = async (id) => {

    const query = 'DELETE FROM test.doctor WHERE id = $1 returning id= $1';
    const values = [id]

    try {
        const response = await pool.query(query, values);
        return response;
    } catch (error) {
        console.error('Error al eliminar un doctor')
        throw error;
    }
}
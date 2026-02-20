import express from 'express';
import { env } from './config/env.js';
import { pool } from './config/dbconfig.js';

const app = express();
app.use(express.json());

app.post('/doctors', async (req, res) => {

    const { name, specialty } = req.body;

    try {

        const response = await pool.query(
            'CALL test.sp_create_doctor($1::text, $2::text, null, null)',
            [name, specialty]
        );

        console.log(response);

        if (!response.rows[0].status) {
            return res.status(500).json({ error: response.rows[0].error_message });
        }


        res.status(201).json({response: response.rows[0].error_message});

    } catch (error) {
        console.error('Error al crear el doctor:', error);
        res.status(500).json({ error: error.message });
    }

})


app.get('/doctors', async (req, res) => {

    try {
        const response = await pool.query(`select p.name as nombre_paciente, p.*, d.* from test.doctor d
inner join test.appointment a on a.doctor_id =  d.id 
inner join test.patient p on a.patient_id = p.id`);
        res.status(200).json(response.rows);
    } catch (error) {
        console.error('Error al obtener los doctores:', error);
        res.status(500).json({ error: error.message });
    }

});

app.listen(env.APP_PORT, () => {
    console.log(`Corriendo en el puerto ${env.APP_PORT}`)
})
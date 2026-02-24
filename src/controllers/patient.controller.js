import { createPatient, deletePatient, getAllPatients } from "../services/patient.service.js";

export const create = async (req, res) => {

    const { name, birth_date } = req.body;

    try {
        const newPatient = await createPatient(name, birth_date);
        return res.status(201).json({
            response: "Se ha creado el paciente correctamente"
        })
    } catch (error) {
        res.status(500).json({
            response: error
        });
    }

}


export const getAll = async (req, res) => {

    try {
        const patients = await getAllPatients()
        return res.status(200).json({response: patients.rows})
    } catch (error) {
        res.status(500).json({
            response: error
        });
    }

}

export const deleteById = async (req, res) => {

    const { id } = req.params;

    try {
        const deletedPatient = await deletePatient(id)
        return res.status(200).json({
            response: "Se ha eliminado el usuario correctamente"
        })
    } catch (error) {
        res.status(500).json({
            response: error
        })
    }

}
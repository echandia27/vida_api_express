import { createDoctor, getAllDoctors, deleteDoctor } from "../services/doctor.service.js";

export const create = async (req, res) => {

    const { name, specialty } = req.body;

    try {
        const newDoctor = await createDoctor({ name, specialty });

        if (!newDoctor.status) {
            return res.status(500).json({ error: newDoctor.error_message });
        }

        res.status(201).json({response: newDoctor.error_message});

    } catch (error) {
        console.error('Error al crear el doctor:', error);
        res.status(500).json({ error: error.message });
    }

};

export const deleteById = async (req, res) => {
    const { id } = req.params;

    try {
        const deletedDoctor = await deleteDoctor(id);

        if (!deletedDoctor. rowCount === 0) {
            return res.status(500).json({ error: "no se ha podido eliminar el doctor"});
        }

        res.status(200).json({response: "doctor eliminado correctamente"});
    
    } catch (error) {
        console.error('Error al eliminar el doctor:', error);
        res.status(500).json({ error: error.message });
    }
};

export const getAll = async (req, res) => {

    try {
        const doctors = await getAllDoctors();
        res.status(200).json({ response: doctors });
    } catch (error) {
        console.error('Error al obtener los doctores:', error);
        res.status(500).json({ error: error.message });
    }

};
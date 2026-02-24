import { createSpecialty, deleteSpeciality, getAllSpecialitys } from "../services/specialty.service.js";

export const create = async (req, res) => {

    const { name } = req.body;

    try {
        const createSpecialtyResult = await createSpecialty(name);
        res.status(200).json({ response: "Especialidad creada correctamente" });
    } catch (error) {
        res.status(500).json({error})
    }

}

export const deleteById = async (req, res) => {

    const { id } = req.params;

    try {
        const deletedSpecialty = await deleteSpeciality(id);

        if (!deletedSpecialty.rowCount === 0) {
            return res.status(500).json({ error: "No se ha podido eliminar la especialidad" });
        }

        res.status(200).json({response: "Especialidad eliminado correctamente"});

    } catch (error) {
        console.error('Error al eliminar la especialidad:', error);
        res.status(500).json({ error: error.message });
    }

}

export const getAll = async (req, res) => {

    try {
        const specialities = await getAllSpecialitys();

        if (!specialities.rows) {
            return res.status(500).json({ error: "No se ha podido obtener las especialidades" });
        }

        res.status(200).json({ response: specialities.rows });
    } catch (error) {
        console.error('Error al obtener las especialidades:', error);
        res.status(500).json({ error: error.message });
    }

};
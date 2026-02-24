import { Router } from "express";
import { create, deleteById, getAll } from "../controllers/patient.controller.js";

export const patientRoutes = Router();

patientRoutes.post('/', create);
patientRoutes.get('/', getAll);
patientRoutes.delete('/:id', deleteById);
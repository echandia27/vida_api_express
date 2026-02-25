import { Router } from "express";
import { create, getAll, deleteById } from '../controllers/doctor.controller.js';


export const doctorRoutes = Router();

doctorRoutes.get('/', getAll);
doctorRoutes.post('/', create);
doctorRoutes.delete('/:id', deleteById);
import { Router } from "express";
import { create, getAll } from '../controllers/doctor.controller.js';


export const doctorRoutes = Router();

doctorRoutes.get('/', getAll);
doctorRoutes.post('/', create);
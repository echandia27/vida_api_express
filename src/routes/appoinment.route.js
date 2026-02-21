import { Router } from "express";
import { triage } from "../controllers/appoinment.controller.js";

export const appointmentRoutes = Router();

appointmentRoutes.post('/triage', triage)
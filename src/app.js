import express from 'express';
import { doctorRoutes } from './routes/doctor.route.js';
import { appointmentRoutes } from './routes/appoinment.route.js';

const app = express();

app.use(express.json());

//app.use('/doctors', doctorRoutes);
//app.use('/appointments', appointmentRoutes);

export default app;
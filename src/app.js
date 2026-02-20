import express from 'express';
import { doctorRoutes } from './routes/doctor.route.js';

const app = express();

app.use(express.json());

app.use('/doctors', doctorRoutes);

export default app;
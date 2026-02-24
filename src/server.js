import app from './app.js';
import { env } from './config/env.js';

app.listen(env.APP_PORT, () => {
    try {
        console.log(`🚀 Servidor corriendo en puerto https://localhost:${env.APP_PORT}`)
    } catch (error) {
        console.error('Error al iniciar el servidor:', error);
    }
});
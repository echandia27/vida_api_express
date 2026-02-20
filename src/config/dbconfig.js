import { Pool } from "pg";
import { env } from "./env.js";

export const pool = new Pool({
    host: env.DB.HOST,
    port: env.DB.PORT,
    database: env.DB.NAME,
    user: env.DB.USER,
    password: env.DB.PASSWORD
});
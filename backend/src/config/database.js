import mysql from 'mysql2/promise';
import { env } from './env.js';

export const pool = mysql.createPool(env.db);

export async function checkDatabase() {
  const connection = await pool.getConnection();
  try {
    await connection.query('SELECT 1');
  } finally {
    connection.release();
  }
}

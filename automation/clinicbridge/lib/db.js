const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

async function createDb() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 5,
    queueLimit: 0,
  });

  return {
    async queryOne(sql, params = []) {
      const [rows] = await pool.execute(sql, params);
      return rows[0] || null;
    },
    async execute(sql, params = []) {
      const [result] = await pool.execute(sql, params);
      return result;
    },
    async query(sql, params = []) {
      const [rows] = await pool.execute(sql, params);
      return rows;
    },
    async close() {
      await pool.end();
    },
  };
}

module.exports = { createDb };

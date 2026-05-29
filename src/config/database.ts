import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

// Parseamos la URL manualmente para que las variables PG* del entorno
// (que Render inyecta) no interfieran con la conexión a Neon.
function parseDbUrl(url: string) {
  const u = new URL(url);
  return {
    host:     u.hostname,
    port:     parseInt(u.port || '5432', 10),
    user:     decodeURIComponent(u.username),
    password: decodeURIComponent(u.password),
    database: u.pathname.replace(/^\//, ''),
    ssl:      u.searchParams.get('sslmode') !== 'disable' ? { rejectUnauthorized: false } : false,
  };
}

const dbConfig = process.env.DATABASE_URL
  ? parseDbUrl(process.env.DATABASE_URL)
  : { host: 'localhost', port: 5432, database: 'eco_wellness_db' };

export const pool = new Pool({
  ...dbConfig,
  max: 20,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 2_000,
});

pool.on('error', (err) => {
  console.error('Unexpected PostgreSQL pool error:', err);
  process.exit(1);
});

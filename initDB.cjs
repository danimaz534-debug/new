const { Client } = require('pg');
const fs = require('fs');

async function run() {
  const client = new Client({
    connectionString: 'postgresql://postgres:pcIvyksJ4KHVLxav@db.hqszihvjqscrwdzrwbyg.supabase.co:5432/postgres',
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log('Connected to DB');
    const sql = fs.readFileSync('./supabase-reset-schema.sql', 'utf8');
    await client.query(sql);
    console.log('Schema applied successfully');
  } catch (err) {
    console.error('Error applying schema:', err);
  } finally {
    await client.end();
  }
}

run();

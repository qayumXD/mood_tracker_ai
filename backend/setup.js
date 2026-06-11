/**
 * Run once after installing PostgreSQL.
 * Creates the configured database and applies the canonical schema.
 */
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');
require('dotenv').config();

const dbName = process.env.DB_NAME || 'mood_tracker';
const schemaPath = path.join(__dirname, '..', 'database', 'schema.sql');
const schemaSql = fs.readFileSync(schemaPath, 'utf8');

function getSafeDbIdentifier(name) {
  if (!/^[A-Za-z0-9_]+$/.test(name)) {
    throw new Error(
      `Invalid DB_NAME "${name}". Use only letters, numbers, and underscores.`,
    );
  }

  return `"${name}"`;
}

async function setup() {
  const adminClient = new Client({
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    port: parseInt(process.env.DB_PORT, 10) || 5432,
  });

  try {
    await adminClient.connect();
    console.log('Connected to PostgreSQL.');

    const dbCheck = await adminClient.query(
      'SELECT 1 FROM pg_database WHERE datname = $1',
      [dbName],
    );

    if (dbCheck.rowCount === 0) {
      await adminClient.query(`CREATE DATABASE ${getSafeDbIdentifier(dbName)}`);
      console.log(`Database "${dbName}" created.`);
    } else {
      console.log(`Database "${dbName}" already exists.`);
    }
  } catch (err) {
    console.error('Failed to create database:', err.message);
    process.exit(1);
  } finally {
    await adminClient.end();
  }

  const appClient = new Client({
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: dbName,
    password: process.env.DB_PASSWORD || 'postgres',
    port: parseInt(process.env.DB_PORT, 10) || 5432,
  });

  try {
    await appClient.connect();
    await appClient.query(schemaSql);
    console.log('Database schema applied successfully.');
    console.log('\nSetup complete. You can now run: npm run dev\n');
  } catch (err) {
    console.error('Failed to apply schema:', err.message);
    process.exit(1);
  } finally {
    await appClient.end();
  }
}

setup();

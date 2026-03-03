/**
 * setup.js — Run once after installing PostgreSQL.
 * Creates the mood_tracker database and all required tables.
 * Usage: node setup.js
 */
const { Client } = require('pg');
require('dotenv').config();

async function setup() {
  // Step 1: Connect to default 'postgres' database to create mood_tracker
  const adminClient = new Client({
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    port: parseInt(process.env.DB_PORT) || 5432,
  });

  try {
    await adminClient.connect();
    console.log('✅ Connected to PostgreSQL.');

    const dbCheck = await adminClient.query(
      `SELECT 1 FROM pg_database WHERE datname = $1`,
      [process.env.DB_NAME || 'mood_tracker']
    );

    if (dbCheck.rowCount === 0) {
      await adminClient.query(`CREATE DATABASE ${process.env.DB_NAME || 'mood_tracker'}`);
      console.log(`✅ Database "${process.env.DB_NAME || 'mood_tracker'}" created.`);
    } else {
      console.log(`ℹ️  Database "${process.env.DB_NAME || 'mood_tracker'}" already exists.`);
    }
  } catch (err) {
    console.error('❌ Failed to create database:', err.message);
    process.exit(1);
  } finally {
    await adminClient.end();
  }

  // Step 2: Connect to mood_tracker and create tables
  const appClient = new Client({
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'mood_tracker',
    password: process.env.DB_PASSWORD || 'postgres',
    port: parseInt(process.env.DB_PORT) || 5432,
  });

  try {
    await appClient.connect();

    await appClient.query(`
      CREATE TABLE IF NOT EXISTS moods (
        id SERIAL PRIMARY KEY,
        level INTEGER NOT NULL CHECK (level >= 1 AND level <= 5),
        note TEXT,
        ai_suggestion TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Tables created successfully.');
    console.log('\n🚀 Setup complete! You can now run: npm run dev\n');
  } catch (err) {
    console.error('❌ Failed to create tables:', err.message);
    process.exit(1);
  } finally {
    await appClient.end();
  }
}

setup();

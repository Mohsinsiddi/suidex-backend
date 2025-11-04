#!/usr/bin/env bun

import { readdir } from 'fs/promises';
import { join } from 'path';
import postgres from 'postgres';

const sql = postgres(process.env.DATABASE_URL!);

async function migrate() {
  console.log('🚀 Running database migrations...');
  
  // Create migrations tracking table
  await sql`
    CREATE TABLE IF NOT EXISTS migrations (
      id SERIAL PRIMARY KEY,
      filename VARCHAR(255) UNIQUE NOT NULL,
      executed_at TIMESTAMP DEFAULT NOW()
    )
  `;
  
  const migrationsDir = join(import.meta.dir, '../database');
  const files = await readdir(migrationsDir);
  const sqlFiles = files.filter(f => f.endsWith('.sql')).sort();
  
  // Get already executed migrations
  const executed = await sql`SELECT filename FROM migrations`;
  const executedSet = new Set(executed.map(r => r.filename));
  
  for (const file of sqlFiles) {
    if (executedSet.has(file)) {
      console.log(`  ⏭️  Skipping ${file} (already executed)`);
      continue;
    }
    
    console.log(`  📄 Executing ${file}...`);
    const content = await Bun.file(join(migrationsDir, file)).text();
    
    await sql.begin(async sql => {
      await sql.unsafe(content);
      await sql`INSERT INTO migrations (filename) VALUES (${file})`;
    });
  }
  
  console.log('✅ Migrations completed!');
  await sql.end();
}

migrate().catch(console.error);
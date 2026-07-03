/**
 * Local Test Setup
 * Initialize SQLite database for local testing without AWS dependencies
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

class LocalTestDB {
  constructor() {
    const dbPath = path.join(__dirname, '../../test.db');
    this.db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('❌ Database connection failed:', err);
      } else {
        console.log('✅ Local SQLite database ready');
      }
    });
  }

  async initialize() {
    return new Promise((resolve, reject) => {
      this.db.serialize(() => {
        // Users table
        this.db.run(`
          CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            first_name TEXT,
            last_name TEXT,
            company TEXT,
            subscription_tier TEXT DEFAULT 'free',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        `);

        // Client profiles table
        this.db.run(`
          CREATE TABLE IF NOT EXISTS client_profiles (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            client_name TEXT NOT NULL,
            client_role TEXT,
            company TEXT,
            industry TEXT,
            winter_json TEXT,
            spring_json TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id)
          )
        `);

        // Stories table
        this.db.run(`
          CREATE TABLE IF NOT EXISTS stories (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            client_profile_id TEXT,
            story_version INTEGER DEFAULT 1,
            three_act_json TEXT,
            metaphors_json TEXT,
            delivery_guidance_json TEXT,
            final_delivery_score REAL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id),
            FOREIGN KEY(client_profile_id) REFERENCES client_profiles(id)
          )
        `);

        // Practice attempts table
        this.db.run(`
          CREATE TABLE IF NOT EXISTS practice_attempts (
            id TEXT PRIMARY KEY,
            story_id TEXT NOT NULL,
            audio_url TEXT,
            transcription TEXT,
            gemini_analysis_json TEXT,
            overall_score REAL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(story_id) REFERENCES stories(id)
          )
        `);

        // Meeting outcomes table
        this.db.run(`
          CREATE TABLE IF NOT EXISTS meeting_outcomes (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            story_id TEXT,
            client_name TEXT,
            deal_advanced BOOLEAN DEFAULT 0,
            notes TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id),
            FOREIGN KEY(story_id) REFERENCES stories(id)
          )
        `, (err) => {
          if (err) reject(err);
          else {
            console.log('✅ All tables created');
            resolve();
          }
        });
      });
    });
  }

  async seedTestData() {
    return new Promise((resolve, reject) => {
      const userId = 'test-user-1';
      const profileId = 'profile-1';

      this.db.serialize(() => {
        // Create test user
        this.db.run(
          `INSERT OR IGNORE INTO users (id, email, password_hash, first_name, last_name, company, subscription_tier)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [userId, 'test@example.com', 'hashed_password', 'Test', 'User', 'Test Corp', 'free'],
          (err) => {
            if (err && !err.message.includes('UNIQUE')) reject(err);
          }
        );

        // Create test client profile
        this.db.run(
          `INSERT OR IGNORE INTO client_profiles (id, user_id, client_name, client_role, company, industry, winter_json, spring_json)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            profileId,
            userId,
            'Mike Johnson',
            'VP Sales',
            'TechCorp',
            'Technology',
            JSON.stringify({
              fear: 'Missing Q3 targets',
              pain: 'Long sales cycles',
              frustration: 'Inconsistent messaging',
            }),
            JSON.stringify({
              vision: 'Close deals 40% faster',
              outcome: '$2M ARR by Q4',
              feeling: 'Confident',
            }),
          ],
          (err) => {
            if (err && !err.message.includes('UNIQUE')) reject(err);
          }
        );

        // Create test story
        this.db.run(
          `INSERT OR IGNORE INTO stories (id, user_id, client_profile_id, three_act_json, metaphors_json, delivery_guidance_json, final_delivery_score)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            'story-1',
            userId,
            profileId,
            JSON.stringify({
              act1Hook: 'I see what\'s happening at TechCorp...',
              act2Bridge: 'I worked with a similar company...',
              act3Payoff: 'I see TechCorp hitting $2M ARR...',
            }),
            JSON.stringify(['Map vs navigation', 'Story is the bridge']),
            JSON.stringify({
              pace: 'Slow and deliberate',
              tone: 'Warm and understanding',
            }),
            8.2,
          ],
          (err) => {
            if (err && !err.message.includes('UNIQUE')) reject(err);
            else {
              console.log('✅ Test data seeded');
              resolve();
            }
          }
        );
      });
    });
  }

  query(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.all(sql, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  run(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.run(sql, params, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });
  }

  close() {
    return new Promise((resolve, reject) => {
      this.db.close((err) => {
        if (err) reject(err);
        else {
          console.log('✅ Database closed');
          resolve();
        }
      });
    });
  }
}

module.exports = { LocalTestDB };

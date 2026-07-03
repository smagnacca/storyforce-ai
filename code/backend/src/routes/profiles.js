const express = require('express');
const router = express.Router();
const { verifyToken } = require('./auth');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// ============================================================================
// CREATE CLIENT PROFILE
// ============================================================================
router.post('/', verifyToken, async (req, res) => {
  try {
    const {
      clientName,
      clientRole,
      company,
      industry,
      winterJson,
      springJson,
    } = req.body;

    // Validate required fields
    if (!clientName || !company || !winterJson || !springJson) {
      return res.status(400).json({
        error: 'Missing required fields: clientName, company, winterJson, springJson',
      });
    }

    const result = await pool.query(
      `INSERT INTO client_profiles (
        user_id, client_name, client_role, company, industry,
        winter_json, spring_json, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
      RETURNING id, created_at`,
      [
        req.user.userId,
        clientName,
        clientRole || null,
        company,
        industry || null,
        JSON.stringify(winterJson),
        JSON.stringify(springJson),
      ]
    );

    const profile = result.rows[0];

    res.status(201).json({
      id: profile.id,
      clientName,
      clientRole,
      company,
      industry,
      winterJson,
      springJson,
      createdAt: profile.created_at,
    });
  } catch (err) {
    console.error('Create profile error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// GET CLIENT PROFILE
// ============================================================================
router.get('/:profileId', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM client_profiles
       WHERE id = $1 AND user_id = $2`,
      [req.params.profileId, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    const profile = result.rows[0];

    res.json({
      id: profile.id,
      clientName: profile.client_name,
      clientRole: profile.client_role,
      company: profile.company,
      industry: profile.industry,
      winterJson: profile.winter_json,
      springJson: profile.spring_json,
      createdAt: profile.created_at,
      updatedAt: profile.updated_at,
    });
  } catch (err) {
    console.error('Get profile error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// LIST CLIENT PROFILES
// ============================================================================
router.get('/', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, client_name, company, industry, created_at
       FROM client_profiles
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [req.user.userId]
    );

    res.json(
      result.rows.map(row => ({
        id: row.id,
        clientName: row.client_name,
        company: row.company,
        industry: row.industry,
        createdAt: row.created_at,
      }))
    );
  } catch (err) {
    console.error('List profiles error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// UPDATE CLIENT PROFILE
// ============================================================================
router.patch('/:profileId', verifyToken, async (req, res) => {
  try {
    const { clientName, clientRole, company, industry, winterJson, springJson } = req.body;

    // Check ownership
    const checkResult = await pool.query(
      'SELECT id FROM client_profiles WHERE id = $1 AND user_id = $2',
      [req.params.profileId, req.user.userId]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    const updates = [];
    const values = [];
    let paramCount = 1;

    if (clientName !== undefined) {
      updates.push(`client_name = $${paramCount++}`);
      values.push(clientName);
    }
    if (clientRole !== undefined) {
      updates.push(`client_role = $${paramCount++}`);
      values.push(clientRole);
    }
    if (company !== undefined) {
      updates.push(`company = $${paramCount++}`);
      values.push(company);
    }
    if (industry !== undefined) {
      updates.push(`industry = $${paramCount++}`);
      values.push(industry);
    }
    if (winterJson !== undefined) {
      updates.push(`winter_json = $${paramCount++}`);
      values.push(JSON.stringify(winterJson));
    }
    if (springJson !== undefined) {
      updates.push(`spring_json = $${paramCount++}`);
      values.push(JSON.stringify(springJson));
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    values.push(req.params.profileId);

    const result = await pool.query(
      `UPDATE client_profiles
       SET ${updates.join(', ')}
       WHERE id = $${paramCount}
       RETURNING id, client_name, company, industry, winter_json, spring_json, updated_at`,
      values
    );

    const profile = result.rows[0];

    res.json({
      id: profile.id,
      clientName: profile.client_name,
      company: profile.company,
      industry: profile.industry,
      winterJson: profile.winter_json,
      springJson: profile.spring_json,
      updatedAt: profile.updated_at,
    });
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// DELETE CLIENT PROFILE
// ============================================================================
router.delete('/:profileId', verifyToken, async (req, res) => {
  try {
    // Check ownership
    const checkResult = await pool.query(
      'SELECT id FROM client_profiles WHERE id = $1 AND user_id = $2',
      [req.params.profileId, req.user.userId]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    // Delete associated stories first
    await pool.query(
      'DELETE FROM stories WHERE client_profile_id = $1',
      [req.params.profileId]
    );

    // Delete profile
    await pool.query(
      'DELETE FROM client_profiles WHERE id = $1',
      [req.params.profileId]
    );

    res.status(204).send();
  } catch (err) {
    console.error('Delete profile error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;

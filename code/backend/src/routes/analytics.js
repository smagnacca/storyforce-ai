const express = require('express');
const router = express.Router();
const { verifyToken } = require('./auth');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// ============================================================================
// GET USER ANALYTICS SUMMARY
// ============================================================================
router.get('/summary', verifyToken, async (req, res) => {
  try {
    // Get total stories
    const storiesResult = await pool.query(
      `SELECT COUNT(*) as total_stories,
              AVG(final_delivery_score) as avg_delivery_score
       FROM stories
       WHERE user_id = $1`,
      [req.user.userId]
    );

    // Get total practice attempts
    const practiceResult = await pool.query(
      `SELECT COUNT(*) as total_practice_attempts,
              AVG(overall_score) as avg_practice_score
       FROM practice_attempts pa
       INNER JOIN stories s ON pa.story_id = s.id
       WHERE s.user_id = $1`,
      [req.user.userId]
    );

    // Get meeting outcomes
    const meetingsResult = await pool.query(
      `SELECT COUNT(*) as total_meetings,
              SUM(CASE WHEN deal_advanced THEN 1 ELSE 0 END) as deals_advanced
       FROM meeting_outcomes
       WHERE user_id = $1`,
      [req.user.userId]
    );

    // Calculate conversion rate
    const totalMeetings = parseInt(meetingsResult.rows[0].total_meetings || 0);
    const dealsAdvanced = parseInt(meetingsResult.rows[0].deals_advanced || 0);
    const conversionRate =
      totalMeetings > 0 ? ((dealsAdvanced / totalMeetings) * 100).toFixed(1) : 0;

    res.json({
      totalStories: parseInt(storiesResult.rows[0].total_stories || 0),
      avgDeliveryScore:
        parseFloat(storiesResult.rows[0].avg_delivery_score || 0).toFixed(1) ||
        0,
      totalPracticeAttempts: parseInt(
        practiceResult.rows[0].total_practice_attempts || 0
      ),
      avgPracticeScore:
        parseFloat(practiceResult.rows[0].avg_practice_score || 0).toFixed(1) ||
        0,
      totalMeetings: totalMeetings,
      dealsAdvanced: dealsAdvanced,
      conversionRate: conversionRate,
    });
  } catch (err) {
    console.error('Analytics summary error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// GET STORIES ANALYTICS
// ============================================================================
router.get('/stories', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
        id,
        client_profile_id,
        final_delivery_score,
        created_at,
        (SELECT COUNT(*) FROM practice_attempts WHERE story_id = s.id) as practice_count
       FROM stories s
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [req.user.userId]
    );

    const stories = result.rows.map(row => ({
      id: row.id,
      clientProfileId: row.client_profile_id,
      deliveryScore: row.final_delivery_score,
      practiceCount: parseInt(row.practice_count),
      createdAt: row.created_at,
    }));

    res.json({ stories });
  } catch (err) {
    console.error('Stories analytics error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// GET DELIVERY SCORE TRENDS (Last 30 days)
// ============================================================================
router.get('/trends/delivery', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
        DATE_TRUNC('day', created_at) as date,
        AVG(final_delivery_score) as avg_score,
        COUNT(*) as story_count
       FROM stories
       WHERE user_id = $1
       AND created_at >= NOW() - INTERVAL '30 days'
       GROUP BY DATE_TRUNC('day', created_at)
       ORDER BY date DESC`,
      [req.user.userId]
    );

    const trends = result.rows.map(row => ({
      date: row.date,
      avgScore: parseFloat(row.avg_score || 0).toFixed(1),
      storyCount: parseInt(row.story_count),
    }));

    res.json({ trends });
  } catch (err) {
    console.error('Delivery trends error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// GET CONVERSION METRICS (Last 90 days)
// ============================================================================
router.get('/trends/conversion', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
        DATE_TRUNC('week', mo.created_at) as week,
        COUNT(*) as total_meetings,
        SUM(CASE WHEN mo.deal_advanced THEN 1 ELSE 0 END) as deals_advanced
       FROM meeting_outcomes mo
       WHERE mo.user_id = $1
       AND mo.created_at >= NOW() - INTERVAL '90 days'
       GROUP BY DATE_TRUNC('week', mo.created_at)
       ORDER BY week DESC`,
      [req.user.userId]
    );

    const trends = result.rows.map(row => {
      const total = parseInt(row.total_meetings);
      const advanced = parseInt(row.deals_advanced || 0);
      return {
        week: row.week,
        totalMeetings: total,
        dealsAdvanced: advanced,
        conversionRate: total > 0 ? ((advanced / total) * 100).toFixed(1) : 0,
      };
    });

    res.json({ trends });
  } catch (err) {
    console.error('Conversion trends error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// LOG MEETING OUTCOME
// ============================================================================
router.post('/meetings', verifyToken, async (req, res) => {
  try {
    const { storyId, clientName, dealAdvanced, notes } = req.body;

    if (!storyId) {
      return res.status(400).json({ error: 'storyId is required' });
    }

    // Verify story ownership
    const storyResult = await pool.query(
      'SELECT id FROM stories WHERE id = $1 AND user_id = $2',
      [storyId, req.user.userId]
    );

    if (storyResult.rows.length === 0) {
      return res.status(404).json({ error: 'Story not found' });
    }

    const result = await pool.query(
      `INSERT INTO meeting_outcomes (user_id, story_id, client_name, deal_advanced, notes, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW())
       RETURNING id, created_at`,
      [req.user.userId, storyId, clientName || null, dealAdvanced || false, notes || null]
    );

    const outcome = result.rows[0];

    res.status(201).json({
      id: outcome.id,
      storyId,
      dealAdvanced: dealAdvanced || false,
      createdAt: outcome.created_at,
    });
  } catch (err) {
    console.error('Meeting outcome error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;

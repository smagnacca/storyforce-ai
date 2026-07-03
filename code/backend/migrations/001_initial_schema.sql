-- ============================================================================
-- STORYFORCE.AI DATABASE SCHEMA
-- ============================================================================

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    company VARCHAR(255),
    role VARCHAR(100),
    subscription_tier VARCHAR(50) DEFAULT 'free',
    subscription_start_date TIMESTAMP,
    subscription_expiry_date TIMESTAMP,
    stories_generated_this_month INTEGER DEFAULT 0,
    practice_sessions_this_month INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active_at TIMESTAMP,
    onboarding_complete BOOLEAN DEFAULT FALSE,
    INDEX idx_email (email),
    INDEX idx_subscription_tier (subscription_tier),
    INDEX idx_created_at (created_at)
);

-- Client Profiles Table
CREATE TABLE IF NOT EXISTS client_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_name VARCHAR(255),
    client_role VARCHAR(100),
    company VARCHAR(255),
    industry VARCHAR(100),
    winter_json JSONB,
    spring_json JSONB,
    extracted_from VARCHAR(50),
    transcription TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- Stories Table
CREATE TABLE IF NOT EXISTS stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_profile_id UUID REFERENCES client_profiles(id) ON DELETE SET NULL,
    story_version INTEGER,
    three_act_json JSONB,
    metaphors_json JSONB,
    delivery_guidance_json JSONB,
    final_delivery_score DECIMAL(3,1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_client_profile_id (client_profile_id),
    INDEX idx_created_at (created_at)
);

-- Practice Attempts Table
CREATE TABLE IF NOT EXISTS practice_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
    attempt_number INTEGER,
    audio_url VARCHAR(255),
    transcription TEXT,
    gemini_analysis_json JSONB,
    overall_score DECIMAL(3,1),
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_story_id (story_id),
    INDEX idx_created_at (created_at)
);

-- Meeting Outcomes Table
CREATE TABLE IF NOT EXISTS meeting_outcomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
    meeting_date DATE,
    result VARCHAR(50),
    deal_value DECIMAL(12,2),
    deal_currency VARCHAR(3) DEFAULT 'USD',
    story_helpfulness_rating INTEGER,
    client_feedback TEXT,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_story_id (story_id),
    INDEX idx_meeting_date (meeting_date),
    INDEX idx_result (result)
);

-- Case Studies Table
CREATE TABLE IF NOT EXISTS case_studies (
    id VARCHAR(100) PRIMARY KEY,
    industry VARCHAR(100),
    client_type VARCHAR(100),
    challenge TEXT,
    solution TEXT,
    results_json JSONB,
    narrative TEXT,
    generated_from_source VARCHAR(255),
    conversion_rate DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_industry (industry),
    INDEX idx_client_type (client_type)
);

-- User Analytics Table (Denormalized for performance)
CREATE TABLE IF NOT EXISTS user_analytics (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_stories_generated INTEGER DEFAULT 0,
    practice_sessions_completed INTEGER DEFAULT 0,
    stories_taken_to_meetings INTEGER DEFAULT 0,
    deals_won INTEGER DEFAULT 0,
    conversion_rate DECIMAL(3,2),
    avg_delivery_score DECIMAL(3,1),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_last_updated (last_updated)
);

-- Create Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_stories_user_id ON stories(user_id);
CREATE INDEX IF NOT EXISTS idx_practice_attempts_story_id ON practice_attempts(story_id);
CREATE INDEX IF NOT EXISTS idx_meeting_outcomes_story_id ON meeting_outcomes(story_id);

-- Create Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_client_profiles_updated_at BEFORE UPDATE ON client_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create Views
CREATE OR REPLACE VIEW user_story_stats AS
SELECT
    u.id,
    u.email,
    COUNT(s.id) as total_stories,
    COUNT(CASE WHEN mo.result = 'won' THEN 1 END) as deals_won,
    ROUND(COUNT(CASE WHEN mo.result = 'won' THEN 1 END)::numeric / NULLIF(COUNT(mo.id), 0) * 100, 2) as conversion_rate
FROM users u
LEFT JOIN stories s ON u.id = s.user_id
LEFT JOIN meeting_outcomes mo ON s.id = mo.story_id
GROUP BY u.id, u.email;

-- Insert sample case studies
INSERT INTO case_studies (id, industry, client_type, challenge, solution, results_json, generated_from_source, conversion_rate)
VALUES (
    'case_001_meditech',
    'pharmaceutical',
    'operations_executive',
    'Cost reduction + implementation risk',
    'Phased optimization approach with stakeholder alignment',
    '{"cost_reduction_percent": 18, "implementation_months": 6, "team_satisfaction": 9}',
    'scott_magnacca_client_work',
    0.72
)
ON CONFLICT DO NOTHING;

-- Grant permissions (adjust as needed for your database user)
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO storyforce_user;
-- GRANT INSERT, UPDATE, DELETE ON stories, practice_attempts, meeting_outcomes, client_profiles TO storyforce_user;

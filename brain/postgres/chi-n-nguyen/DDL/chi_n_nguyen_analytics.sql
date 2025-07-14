-- =====================================================================
-- Project 2.2: Brain Architecture - Bonus Downstream Table DDL
-- File: chi_n_nguyen_analytics.sql
-- Author: Chi Nguyen
-- Description: Bonus downstream analytics table using GROUP BY/WHERE/ORDER BY
-- =====================================================================

-- Set search path
SET search_path TO project_two, public;

-- =====================================================================
-- CHI_N_NGUYEN_ANALYTICS TABLE (Bonus Downstream Table)
-- =====================================================================

-- Drop table if exists (for testing)
DROP TABLE IF EXISTS project_two.chi_n_nguyen_analytics CASCADE;

-- Create downstream analytics table
CREATE TABLE project_two.chi_n_nguyen_analytics (
    -- Primary key and metadata
    analytics_id SERIAL PRIMARY KEY,
    analysis_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Grouping dimensions
    context_method VARCHAR(20) NOT NULL,
    brain_layer_used VARCHAR(20),
    model_name VARCHAR(50),
    
    -- Aggregated performance metrics
    total_interactions INTEGER NOT NULL DEFAULT 0,
    avg_response_time_ms DECIMAL(10, 2),
    min_response_time_ms INTEGER,
    max_response_time_ms INTEGER,
    
    -- Cost analytics
    avg_cost_usd DECIMAL(12, 8),
    total_cost_usd DECIMAL(15, 6),
    cost_per_token DECIMAL(12, 8),
    
    -- Quality metrics
    avg_quality_score DECIMAL(4, 3),
    avg_user_satisfaction DECIMAL(3, 2),
    quality_consistency_score DECIMAL(4, 3),
    
    -- Token usage analytics
    avg_prompt_tokens DECIMAL(10, 2),
    avg_completion_tokens DECIMAL(10, 2),
    avg_total_tokens DECIMAL(10, 2),
    token_efficiency_ratio DECIMAL(6, 4),
    
    -- Performance rankings
    performance_rank INTEGER,
    cost_efficiency_rank INTEGER,
    quality_rank INTEGER,
    
    -- Success metrics
    success_rate_percent DECIMAL(5, 2),
    high_quality_interactions INTEGER,
    high_satisfaction_interactions INTEGER,
    
    -- Comparative analytics
    performance_vs_baseline_percent DECIMAL(6, 2),
    cost_vs_baseline_percent DECIMAL(6, 2),
    
    -- Context-specific analytics
    avg_retrieval_time_ms DECIMAL(8, 2), -- For RAG
    avg_context_size_tokens DECIMAL(10, 2), -- For Context Dump
    context_efficiency_score DECIMAL(4, 3)
);

-- =====================================================================
-- INDEXES FOR DOWNSTREAM ANALYTICS
-- =====================================================================

-- Primary analysis dimensions
CREATE INDEX idx_analytics_context_method ON project_two.chi_n_nguyen_analytics(context_method);
CREATE INDEX idx_analytics_analysis_date ON project_two.chi_n_nguyen_analytics(analysis_date DESC);
CREATE INDEX idx_analytics_brain_layer ON project_two.chi_n_nguyen_analytics(brain_layer_used);
CREATE INDEX idx_analytics_model ON project_two.chi_n_nguyen_analytics(model_name);

-- Performance analysis
CREATE INDEX idx_analytics_performance_rank ON project_two.chi_n_nguyen_analytics(performance_rank);
CREATE INDEX idx_analytics_cost_efficiency_rank ON project_two.chi_n_nguyen_analytics(cost_efficiency_rank);
CREATE INDEX idx_analytics_quality_rank ON project_two.chi_n_nguyen_analytics(quality_rank);

-- Composite index for common queries
CREATE INDEX idx_analytics_method_date_layer ON project_two.chi_n_nguyen_analytics(context_method, analysis_date, brain_layer_used);

-- =====================================================================
-- ANALYTICAL VIEWS
-- =====================================================================

-- View comparing RAG vs Context Dumping performance
CREATE OR REPLACE VIEW project_two.v_context_method_comparison AS
SELECT 
    context_method,
    COUNT(*) as method_usage_count,
    AVG(avg_response_time_ms) as overall_avg_response_time,
    AVG(avg_cost_usd) as overall_avg_cost,
    AVG(avg_quality_score) as overall_avg_quality,
    AVG(success_rate_percent) as overall_success_rate,
    RANK() OVER (ORDER BY AVG(avg_response_time_ms) ASC) as speed_rank,
    RANK() OVER (ORDER BY AVG(avg_cost_usd) ASC) as cost_rank,
    RANK() OVER (ORDER BY AVG(avg_quality_score) DESC) as quality_rank
FROM project_two.chi_n_nguyen_analytics
GROUP BY context_method
ORDER BY overall_avg_response_time ASC;

-- View showing top performing configurations
CREATE OR REPLACE VIEW project_two.v_top_performers AS
SELECT 
    context_method,
    brain_layer_used,
    model_name,
    avg_response_time_ms,
    avg_cost_usd,
    avg_quality_score,
    success_rate_percent,
    performance_rank,
    'Top 10% Performance' as category
FROM project_two.chi_n_nguyen_analytics
WHERE performance_rank <= (SELECT COUNT(*) * 0.1 FROM project_two.chi_n_nguyen_analytics)
ORDER BY performance_rank ASC;

-- =====================================================================
-- ANALYTICAL FUNCTIONS
-- =====================================================================

-- Function to calculate performance baseline
CREATE OR REPLACE FUNCTION calculate_performance_baseline()
RETURNS TABLE (
    baseline_response_time DECIMAL(10, 2),
    baseline_cost DECIMAL(12, 8),
    baseline_quality DECIMAL(4, 3)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        AVG(avg_response_time_ms) as baseline_response_time,
        AVG(avg_cost_usd) as baseline_cost,
        AVG(avg_quality_score) as baseline_quality
    FROM project_two.chi_n_nguyen_analytics;
END;
$$ LANGUAGE plpgsql;

-- Function to get method efficiency report
CREATE OR REPLACE FUNCTION get_method_efficiency_report(method_filter VARCHAR(20))
RETURNS TABLE (
    analysis_summary TEXT,
    total_interactions INTEGER,
    avg_response_time DECIMAL(10, 2),
    cost_efficiency_rating VARCHAR(20),
    quality_rating VARCHAR(20),
    recommendation TEXT
) AS $$
DECLARE
    interaction_count INTEGER;
    avg_time DECIMAL(10, 2);
    avg_cost DECIMAL(12, 8);
    avg_quality DECIMAL(4, 3);
BEGIN
    SELECT 
        SUM(ca.total_interactions),
        AVG(ca.avg_response_time_ms),
        AVG(ca.avg_cost_usd),
        AVG(ca.avg_quality_score)
    INTO interaction_count, avg_time, avg_cost, avg_quality
    FROM project_two.chi_n_nguyen_analytics ca
    WHERE ca.context_method = method_filter;
    
    RETURN QUERY
    SELECT 
        format('Analysis for %s method with %s interactions', method_filter, interaction_count),
        interaction_count,
        avg_time,
        CASE 
            WHEN avg_cost < 0.001 THEN 'EXCELLENT'
            WHEN avg_cost < 0.01 THEN 'GOOD'
            WHEN avg_cost < 0.1 THEN 'MODERATE'
            ELSE 'EXPENSIVE'
        END,
        CASE 
            WHEN avg_quality > 0.9 THEN 'EXCELLENT'
            WHEN avg_quality > 0.8 THEN 'GOOD'
            WHEN avg_quality > 0.7 THEN 'MODERATE'
            ELSE 'NEEDS_IMPROVEMENT'
        END,
        CASE 
            WHEN method_filter = 'RAG' THEN 'Recommended for production: High performance, low cost'
            WHEN method_filter = 'CONTEXT_DUMP' THEN 'Use for specialized cases: High quality but expensive'
            WHEN method_filter = 'HYBRID' THEN 'Good balance: Consider for mixed workloads'
            ELSE 'Method requires evaluation'
        END;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================================

COMMENT ON TABLE project_two.chi_n_nguyen_analytics IS 
'Bonus downstream analytics table aggregating performance data from chi_n_nguyen table 
using GROUP BY, WHERE, and ORDER BY operations as required by Project 2.2 bonus specification.';

COMMENT ON COLUMN project_two.chi_n_nguyen_analytics.context_method IS 
'Grouping dimension: The context method (RAG, CONTEXT_DUMP, HYBRID) being analyzed';

COMMENT ON COLUMN project_two.chi_n_nguyen_analytics.performance_rank IS 
'Ranking of this configuration by overall performance (1 = best performance)';

COMMENT ON VIEW project_two.v_context_method_comparison IS 
'Comparative analysis view showing performance differences between context methods';

COMMENT ON FUNCTION get_method_efficiency_report IS 
'Analytical function providing efficiency recommendations for specific context methods';

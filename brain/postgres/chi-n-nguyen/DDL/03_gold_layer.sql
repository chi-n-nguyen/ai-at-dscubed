-- =====================================================================
-- Project 2.2: Brain Architecture - Gold Layer DDL
-- File: 03_gold_layer.sql
-- Author: Chi Nguyen
-- Description: Gold layer schema for executive dashboards and business intelligence
-- =====================================================================

-- Create schema for gold layer
CREATE SCHEMA IF NOT EXISTS gold;

-- Set search path
SET search_path TO gold, silver, bronze, public;

-- =====================================================================
-- EXECUTIVE_DASHBOARD TABLE (Strategic KPIs)
-- =====================================================================
CREATE TABLE gold.executive_dashboard (
    dashboard_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_date DATE NOT NULL,
    report_period VARCHAR(20) NOT NULL CHECK (report_period IN ('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY')),
    
    -- Performance Metrics
    total_queries_processed INTEGER NOT NULL DEFAULT 0,
    avg_response_time_ms DECIMAL(8,2),
    system_uptime_percent DECIMAL(5,2),
    error_rate_percent DECIMAL(5,2),
    
    -- RAG vs Context Dumping Performance
    rag_performance_advantage_percent DECIMAL(5,2),
    rag_cost_savings_percent DECIMAL(5,2),
    rag_quality_improvement_percent DECIMAL(5,2),
    rag_adoption_rate_percent DECIMAL(5,2),
    
    -- Business Value Metrics
    total_cost_savings_usd DECIMAL(15,2),
    productivity_improvement_percent DECIMAL(5,2),
    user_satisfaction_score DECIMAL(3,2),
    roi_percent DECIMAL(8,2),
    
    -- Strategic Indicators
    market_position_score DECIMAL(3,2),
    innovation_index DECIMAL(3,2),
    competitive_advantage_score DECIMAL(3,2),
    
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- PERFORMANCE_ANALYTICS TABLE (Detailed Performance Intelligence)
-- =====================================================================
CREATE TABLE gold.performance_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_date DATE NOT NULL,
    processing_method VARCHAR(20) NOT NULL,
    
    -- Volume Metrics
    total_interactions INTEGER NOT NULL,
    peak_queries_per_hour INTEGER,
    avg_queries_per_hour DECIMAL(8,2),
    
    -- Performance Metrics
    avg_response_time_ms DECIMAL(8,2),
    median_response_time_ms DECIMAL(8,2),
    p95_response_time_ms DECIMAL(8,2),
    p99_response_time_ms DECIMAL(8,2),
    
    -- Quality Metrics
    avg_quality_score DECIMAL(3,2),
    quality_score_trend VARCHAR(10) CHECK (quality_score_trend IN ('IMPROVING', 'STABLE', 'DECLINING')),
    user_satisfaction_avg DECIMAL(3,2),
    
    -- Cost Metrics
    total_cost_usd DECIMAL(12,6),
    avg_cost_per_query_usd DECIMAL(10,6),
    cost_efficiency_score DECIMAL(5,2),
    
    -- System Health
    error_count INTEGER DEFAULT 0,
    timeout_count INTEGER DEFAULT 0,
    success_rate_percent DECIMAL(5,2),
    
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- ROI_ANALYSIS TABLE (Return on Investment Intelligence)
-- =====================================================================
CREATE TABLE gold.roi_analysis (
    roi_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_period_start DATE NOT NULL,
    analysis_period_end DATE NOT NULL,
    
    -- Investment Metrics
    total_infrastructure_cost_usd DECIMAL(15,2),
    total_development_cost_usd DECIMAL(15,2),
    total_operational_cost_usd DECIMAL(15,2),
    total_investment_usd DECIMAL(15,2),
    
    -- Return Metrics
    cost_savings_from_rag_usd DECIMAL(15,2),
    productivity_gains_usd DECIMAL(15,2),
    quality_improvement_value_usd DECIMAL(15,2),
    total_return_usd DECIMAL(15,2),
    
    -- ROI Calculations
    roi_percent DECIMAL(8,2),
    payback_period_months DECIMAL(5,2),
    net_present_value_usd DECIMAL(15,2),
    
    -- Strategic Value
    market_advantage_value_usd DECIMAL(15,2),
    innovation_value_usd DECIMAL(15,2),
    
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- EXECUTIVE VIEWS FOR STRATEGIC DECISION MAKING
-- =====================================================================

-- Real-time Executive Summary
CREATE OR REPLACE VIEW gold.v_executive_summary AS
SELECT 
    'TODAY' as period_type,
    CURRENT_DATE as report_date,
    COUNT(DISTINCT s.user_id) as active_users_today,
    COUNT(*) as total_queries_today,
    AVG(s.response_time_ms) as avg_response_time_ms,
    AVG(s.response_quality_score) as avg_quality_score,
    SUM(s.cost_usd) as total_cost_today,
    AVG(CASE WHEN s.processing_method = 'RAG' THEN s.response_time_ms END) as rag_avg_time,
    AVG(CASE WHEN s.processing_method = 'CONTEXT_DUMP' THEN s.response_time_ms END) as context_avg_time,
    ROUND(
        (AVG(CASE WHEN s.processing_method = 'CONTEXT_DUMP' THEN s.response_time_ms END) - 
         AVG(CASE WHEN s.processing_method = 'RAG' THEN s.response_time_ms END)) /
        AVG(CASE WHEN s.processing_method = 'CONTEXT_DUMP' THEN s.response_time_ms END) * 100, 2
    ) as rag_performance_advantage_percent
FROM silver.queries s
WHERE DATE(s.query_timestamp) = CURRENT_DATE;

-- =====================================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================================
COMMENT ON SCHEMA gold IS 'Gold layer for executive dashboards, strategic insights, and business intelligence';
COMMENT ON TABLE gold.executive_dashboard IS 'Executive-level KPIs and strategic performance metrics';
COMMENT ON TABLE gold.performance_analytics IS 'Detailed performance intelligence for strategic planning';
COMMENT ON TABLE gold.roi_analysis IS 'Return on investment analysis and financial intelligence';

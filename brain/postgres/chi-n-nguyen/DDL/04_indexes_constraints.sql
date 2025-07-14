-- =====================================================================
-- Project 2.2: Brain Architecture - Indexes and Constraints DDL
-- File: 04_indexes_constraints.sql
-- Author: Chi Nguyen
-- Description: Performance indexes and data integrity constraints
-- =====================================================================

-- Set search path for all layers
SET search_path TO gold, silver, bronze, public;

-- =====================================================================
-- BRONZE LAYER INDEXES
-- =====================================================================

-- Primary performance indexes for bronze layer
CREATE INDEX IF NOT EXISTS idx_bronze_raw_queries_timestamp 
    ON bronze.raw_queries(query_timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_bronze_raw_queries_processing_method 
    ON bronze.raw_queries(processing_method);

CREATE INDEX IF NOT EXISTS idx_bronze_raw_performance_method_time 
    ON bronze.raw_performance_metrics(processing_method, response_time_ms);

CREATE INDEX IF NOT EXISTS idx_bronze_raw_performance_timestamp 
    ON bronze.raw_performance_metrics(timestamp DESC);

-- =====================================================================
-- SILVER LAYER INDEXES
-- =====================================================================

-- Performance-critical indexes for silver layer analytics
CREATE INDEX IF NOT EXISTS idx_silver_queries_processing_method 
    ON silver.queries(processing_method, response_time_ms);

CREATE INDEX IF NOT EXISTS idx_silver_queries_quality_score 
    ON silver.queries(response_quality_score DESC);

CREATE INDEX IF NOT EXISTS idx_silver_queries_category 
    ON silver.queries(query_category);

CREATE INDEX IF NOT EXISTS idx_silver_performance_method_time 
    ON silver.performance_metrics(processing_method, timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_silver_performance_efficiency 
    ON silver.performance_metrics(efficiency_score DESC);

CREATE INDEX IF NOT EXISTS idx_silver_performance_cost 
    ON silver.performance_metrics(cost_per_query_usd);

-- Composite indexes for complex queries
CREATE INDEX IF NOT EXISTS idx_silver_queries_method_quality_time 
    ON silver.queries(processing_method, response_quality_score, query_timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_silver_performance_method_cost_time 
    ON silver.performance_metrics(processing_method, cost_per_query_usd, timestamp DESC);

-- =====================================================================
-- GOLD LAYER INDEXES
-- =====================================================================

-- Executive dashboard performance indexes
CREATE INDEX IF NOT EXISTS idx_gold_executive_dashboard_date 
    ON gold.executive_dashboard(report_date DESC);

CREATE INDEX IF NOT EXISTS idx_gold_executive_dashboard_period 
    ON gold.executive_dashboard(report_period, report_date DESC);

CREATE INDEX IF NOT EXISTS idx_gold_performance_analytics_date_method 
    ON gold.performance_analytics(analysis_date DESC, processing_method);

CREATE INDEX IF NOT EXISTS idx_gold_roi_analysis_period 
    ON gold.roi_analysis(analysis_period_end DESC);

-- =====================================================================
-- FOREIGN KEY CONSTRAINTS
-- =====================================================================

-- Silver layer foreign keys
ALTER TABLE silver.performance_metrics 
ADD CONSTRAINT fk_silver_performance_query 
FOREIGN KEY (query_id) REFERENCES silver.queries(query_id) 
ON DELETE CASCADE;

-- =====================================================================
-- CHECK CONSTRAINTS
-- =====================================================================

-- Bronze layer constraints
ALTER TABLE bronze.raw_queries 
ADD CONSTRAINT check_bronze_response_time_positive 
CHECK (response_time_ms IS NULL OR response_time_ms >= 0);

ALTER TABLE bronze.raw_queries 
ADD CONSTRAINT check_bronze_tokens_positive 
CHECK (tokens_used IS NULL OR tokens_used >= 0);

ALTER TABLE bronze.raw_queries 
ADD CONSTRAINT check_bronze_cost_positive 
CHECK (cost_usd IS NULL OR cost_usd >= 0);

ALTER TABLE bronze.raw_performance_metrics 
ADD CONSTRAINT check_bronze_perf_response_time_positive 
CHECK (response_time_ms >= 0);

ALTER TABLE bronze.raw_performance_metrics 
ADD CONSTRAINT check_bronze_perf_quality_range 
CHECK (quality_score IS NULL OR (quality_score >= 0 AND quality_score <= 1));

-- Silver layer constraints
ALTER TABLE silver.queries 
ADD CONSTRAINT check_silver_queries_response_time_positive 
CHECK (response_time_ms >= 0);

ALTER TABLE silver.queries 
ADD CONSTRAINT check_silver_queries_tokens_positive 
CHECK (tokens_used IS NULL OR tokens_used >= 0);

ALTER TABLE silver.queries 
ADD CONSTRAINT check_silver_queries_cost_positive 
CHECK (cost_usd IS NULL OR cost_usd >= 0);

ALTER TABLE silver.queries 
ADD CONSTRAINT check_silver_queries_quality_range 
CHECK (response_quality_score IS NULL OR (response_quality_score >= 0 AND response_quality_score <= 1));

ALTER TABLE silver.queries 
ADD CONSTRAINT check_silver_queries_context_relevance_range 
CHECK (context_relevance_score IS NULL OR (context_relevance_score >= 0 AND context_relevance_score <= 1));

ALTER TABLE silver.performance_metrics 
ADD CONSTRAINT check_silver_perf_efficiency_positive 
CHECK (efficiency_score IS NULL OR efficiency_score >= 0);

ALTER TABLE silver.performance_metrics 
ADD CONSTRAINT check_silver_perf_cost_efficiency_positive 
CHECK (cost_efficiency_ratio IS NULL OR cost_efficiency_ratio >= 0);

-- Gold layer constraints
ALTER TABLE gold.executive_dashboard 
ADD CONSTRAINT check_gold_exec_uptime_range 
CHECK (system_uptime_percent IS NULL OR (system_uptime_percent >= 0 AND system_uptime_percent <= 100));

ALTER TABLE gold.executive_dashboard 
ADD CONSTRAINT check_gold_exec_error_rate_range 
CHECK (error_rate_percent IS NULL OR (error_rate_percent >= 0 AND error_rate_percent <= 100));

ALTER TABLE gold.executive_dashboard 
ADD CONSTRAINT check_gold_exec_satisfaction_range 
CHECK (user_satisfaction_score IS NULL OR (user_satisfaction_score >= 1 AND user_satisfaction_score <= 5));

ALTER TABLE gold.performance_analytics 
ADD CONSTRAINT check_gold_perf_success_rate_range 
CHECK (success_rate_percent IS NULL OR (success_rate_percent >= 0 AND success_rate_percent <= 100));

ALTER TABLE gold.roi_analysis 
ADD CONSTRAINT check_gold_roi_costs_positive 
CHECK (total_investment_usd >= 0 AND total_return_usd >= 0);

-- =====================================================================
-- UNIQUE CONSTRAINTS
-- =====================================================================

-- Ensure unique executive dashboard reports per period
ALTER TABLE gold.executive_dashboard 
ADD CONSTRAINT unique_gold_exec_dashboard_period 
UNIQUE (report_date, report_period);

-- Ensure unique performance analytics per date and method
ALTER TABLE gold.performance_analytics 
ADD CONSTRAINT unique_gold_perf_analytics_date_method 
UNIQUE (analysis_date, processing_method);

-- =====================================================================
-- PERFORMANCE OPTIMIZATION SETTINGS
-- =====================================================================

-- Set table statistics targets for better query planning
ALTER TABLE silver.queries ALTER COLUMN query_timestamp SET STATISTICS 1000;
ALTER TABLE silver.performance_metrics ALTER COLUMN timestamp SET STATISTICS 1000;
ALTER TABLE silver.performance_metrics ALTER COLUMN processing_method SET STATISTICS 1000;
ALTER TABLE silver.queries ALTER COLUMN processing_method SET STATISTICS 1000;

-- =====================================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================================

COMMENT ON INDEX idx_bronze_raw_queries_timestamp IS 'Performance index for time-based queries on raw data';
COMMENT ON INDEX idx_silver_queries_processing_method IS 'Critical index for RAG vs Context Dumping analysis';
COMMENT ON INDEX idx_gold_executive_dashboard_date IS 'Executive dashboard performance optimization';

-- =====================================================================
-- Project 2.2: Brain Architecture - Silver Layer DDL
-- File: 02_silver_layer.sql
-- Author: Chi Nguyen
-- Description: Silver layer schema for cleaned and transformed data
-- =====================================================================

-- Create schema for silver layer
CREATE SCHEMA IF NOT EXISTS silver;

-- Set search path
SET search_path TO silver, bronze, public;

-- =====================================================================
-- CONVERSATIONS TABLE (Cleaned)
-- =====================================================================
CREATE TABLE silver.conversations (
    conversation_id UUID PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    session_id VARCHAR(100),
    start_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    end_timestamp TIMESTAMP WITH TIME ZONE,
    total_queries INTEGER DEFAULT 0,
    total_response_time_ms INTEGER DEFAULT 0,
    avg_response_time_ms DECIMAL(8,2),
    conversation_topic VARCHAR(100),
    conversation_category VARCHAR(50),
    user_satisfaction_avg DECIMAL(3,2),
    processing_method_primary VARCHAR(20),
    total_cost_usd DECIMAL(10,6) DEFAULT 0.00,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    quality_score DECIMAL(3,2),
    conversation_summary TEXT
);

-- =====================================================================
-- QUERIES TABLE (Processed)
-- =====================================================================
CREATE TABLE silver.queries (
    query_id UUID PRIMARY KEY,
    conversation_id UUID NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    query_text_clean TEXT NOT NULL,
    query_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    response_text_clean TEXT,
    response_timestamp TIMESTAMP WITH TIME ZONE,
    processing_method VARCHAR(20) NOT NULL CHECK (processing_method IN ('RAG', 'CONTEXT_DUMP')),
    response_time_ms INTEGER NOT NULL,
    tokens_used INTEGER,
    cost_usd DECIMAL(10,6),
    query_complexity_score INTEGER CHECK (query_complexity_score BETWEEN 1 AND 10),
    response_quality_score DECIMAL(3,2),
    user_satisfaction INTEGER CHECK (user_satisfaction BETWEEN 1 AND 5),
    query_category VARCHAR(50),
    is_follow_up BOOLEAN DEFAULT FALSE,
    context_relevance_score DECIMAL(3,2),
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES silver.conversations(conversation_id)
);

-- =====================================================================
-- PERFORMANCE_METRICS TABLE (Aggregated)
-- =====================================================================
CREATE TABLE silver.performance_metrics (
    metric_id UUID PRIMARY KEY,
    query_id UUID NOT NULL,
    processing_method VARCHAR(20) NOT NULL,
    response_time_ms INTEGER NOT NULL,
    token_count INTEGER,
    cost_per_query_usd DECIMAL(10,6),
    memory_usage_mb INTEGER,
    cpu_utilization_percent DECIMAL(5,2),
    quality_score DECIMAL(3,2),
    user_satisfaction INTEGER CHECK (user_satisfaction BETWEEN 1 AND 5),
    efficiency_score DECIMAL(5,2),
    cost_efficiency_ratio DECIMAL(10,6),
    performance_percentile INTEGER CHECK (performance_percentile BETWEEN 1 AND 100),
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (query_id) REFERENCES silver.queries(query_id)
);

-- =====================================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================================
COMMENT ON SCHEMA silver IS 'Silver layer for cleaned, transformed, and business-ready data';
COMMENT ON TABLE silver.conversations IS 'Processed conversation sessions with business metrics';
COMMENT ON TABLE silver.queries IS 'Cleaned query-response pairs with quality scores';
COMMENT ON TABLE silver.performance_metrics IS 'Comprehensive performance analysis with efficiency scores';

-- =====================================================================
-- Project 2.2: Brain Architecture - Bronze Layer DDL
-- File: 01_bronze_layer.sql
-- Author: Chi Nguyen
-- Description: Bronze layer schema for raw data ingestion
-- =====================================================================

-- Create schema for bronze layer
CREATE SCHEMA IF NOT EXISTS bronze;

-- Set search path
SET search_path TO bronze, public;

-- =====================================================================
-- RAW CONVERSATIONS TABLE
-- =====================================================================
CREATE TABLE bronze.raw_conversations (
    conversation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(50) NOT NULL,
    session_id VARCHAR(100),
    conversation_data JSONB NOT NULL,
    metadata JSONB,
    ingestion_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    source_system VARCHAR(50) DEFAULT 'chatbot',
    data_version INTEGER DEFAULT 1,
    is_processed BOOLEAN DEFAULT FALSE,
    processing_status VARCHAR(20) DEFAULT 'pending'
);

-- =====================================================================
-- RAW QUERIES TABLE
-- =====================================================================
CREATE TABLE bronze.raw_queries (
    query_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID,
    user_id VARCHAR(50) NOT NULL,
    query_text TEXT NOT NULL,
    query_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    query_metadata JSONB,
    response_text TEXT,
    response_timestamp TIMESTAMP WITH TIME ZONE,
    response_metadata JSONB,
    processing_method VARCHAR(20) CHECK (processing_method IN ('RAG', 'CONTEXT_DUMP')),
    response_time_ms INTEGER,
    tokens_used INTEGER,
    cost_usd DECIMAL(10,6),
    ingestion_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    source_batch_id VARCHAR(100),
    is_processed BOOLEAN DEFAULT FALSE
);

-- =====================================================================
-- RAW PERFORMANCE_METRICS TABLE
-- =====================================================================
CREATE TABLE bronze.raw_performance_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    query_id UUID,
    processing_method VARCHAR(20) NOT NULL,
    response_time_ms INTEGER NOT NULL,
    token_count INTEGER,
    cost_per_query_usd DECIMAL(10,6),
    memory_usage_mb INTEGER,
    cpu_utilization_percent DECIMAL(5,2),
    quality_score DECIMAL(3,2),
    user_satisfaction INTEGER CHECK (user_satisfaction BETWEEN 1 AND 5),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ingestion_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    additional_metrics JSONB
);

-- =====================================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================================
COMMENT ON SCHEMA bronze IS 'Bronze layer for raw data ingestion from various AI interaction sources';
COMMENT ON TABLE bronze.raw_conversations IS 'Raw conversation data with complete interaction history';
COMMENT ON TABLE bronze.raw_queries IS 'Individual queries and responses with performance metrics';
COMMENT ON TABLE bronze.raw_performance_metrics IS 'Raw performance data for both RAG and context dumping';

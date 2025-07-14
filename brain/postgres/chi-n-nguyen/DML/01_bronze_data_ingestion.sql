-- =====================================================================
-- Project 2.2: Brain Architecture - Bronze Layer DML
-- File: 01_bronze_data_ingestion.sql
-- Author: Chi Nguyen
-- Description: Bronze layer data ingestion with realistic AI interaction data
-- =====================================================================

-- Set search path
SET search_path TO bronze, public;

-- =====================================================================
-- RAG QUERIES DATA (High Performance)
-- =====================================================================

-- Insert RAG-based queries with superior performance
INSERT INTO bronze.raw_queries (
    query_id, user_id, query_text, query_timestamp,
    response_text, response_timestamp, processing_method,
    response_time_ms, tokens_used, cost_usd
) VALUES 
-- RAG Query 1: Fast, efficient, high quality
(
    '660e8400-e29b-41d4-a716-446655440001'::UUID,
    'user_001',
    'What are the key performance benefits of RAG over traditional context dumping?',
    '2024-01-15 10:30:00+10'::TIMESTAMP WITH TIME ZONE,
    'RAG (Retrieval-Augmented Generation) offers significant performance advantages: 1) 45x faster response times by retrieving only relevant context, 2) 1250x cost reduction through efficient token usage, 3) Higher accuracy through focused information retrieval, 4) Better scalability for large knowledge bases.',
    '2024-01-15 10:30:02.150+10'::TIMESTAMP WITH TIME ZONE,
    'RAG',
    2150, 380, 0.0019
),
-- RAG Query 2: Complex technical question
(
    '660e8400-e29b-41d4-a716-446655440002'::UUID,
    'user_001',
    'How does vector similarity search improve query performance in RAG systems?',
    '2024-01-15 10:32:00+10'::TIMESTAMP WITH TIME ZONE,
    'Vector similarity search optimizes RAG performance by: 1) Semantic matching rather than keyword matching, 2) Sub-second retrieval from millions of documents, 3) Relevance scoring ensuring high-quality context, 4) Dimensionality reduction for faster computation.',
    '2024-01-15 10:32:01.890+10'::TIMESTAMP WITH TIME ZONE,
    'RAG',
    1890, 420, 0.0021
);

-- =====================================================================
-- CONTEXT DUMPING QUERIES DATA (Poor Performance)
-- =====================================================================

-- Insert context dumping queries with significantly worse performance
INSERT INTO bronze.raw_queries (
    query_id, user_id, query_text, query_timestamp,
    response_text, response_timestamp, processing_method,
    response_time_ms, tokens_used, cost_usd
) VALUES 
-- Context Dump Query 1: Slow, expensive, verbose
(
    '660e8400-e29b-41d4-a716-446655440011'::UUID,
    'user_001',
    'What are the key performance benefits of RAG over traditional context dumping?',
    '2024-01-15 10:35:00+10'::TIMESTAMP WITH TIME ZONE,
    'Based on extensive documentation analysis... [MASSIVE CONTEXT DUMP] ...RAG systems demonstrate superior performance through selective retrieval mechanisms, whereas traditional approaches require processing entire knowledge bases, leading to computational inefficiencies and increased latency...',
    '2024-01-15 10:36:37.500+10'::TIMESTAMP WITH TIME ZONE,
    'CONTEXT_DUMP',
    97500, 15420, 0.771
),
-- Context Dump Query 2: Extremely slow
(
    '660e8400-e29b-41d4-a716-446655440012'::UUID,
    'user_002',
    'How does vector similarity search work in AI systems?',
    '2024-01-15 11:20:00+10'::TIMESTAMP WITH TIME ZONE,
    'Vector similarity search encompasses numerous mathematical concepts... [EXTENSIVE DOCUMENTATION DUMP] ...involving high-dimensional space computations, cosine similarity calculations, and various distance metrics...',
    '2024-01-15 11:22:15.200+10'::TIMESTAMP WITH TIME ZONE,
    'CONTEXT_DUMP',
    135200, 18950, 0.9475
);

-- =====================================================================
-- PERFORMANCE METRICS DATA
-- =====================================================================

-- Insert detailed performance metrics
INSERT INTO bronze.raw_performance_metrics (
    metric_id, query_id, processing_method, response_time_ms,
    token_count, cost_per_query_usd, quality_score, user_satisfaction
) VALUES 
-- RAG performance metrics: Excellent across all dimensions
('880e8400-e29b-41d4-a716-446655440001'::UUID, '660e8400-e29b-41d4-a716-446655440001'::UUID, 'RAG', 2150, 380, 0.0019, 0.92, 5),
('880e8400-e29b-41d4-a716-446655440002'::UUID, '660e8400-e29b-41d4-a716-446655440002'::UUID, 'RAG', 1890, 420, 0.0021, 0.89, 4),

-- Context dump performance metrics: Poor across all dimensions
('880e8400-e29b-41d4-a716-446655440011'::UUID, '660e8400-e29b-41d4-a716-446655440011'::UUID, 'CONTEXT_DUMP', 97500, 15420, 0.771, 0.68, 2),
('880e8400-e29b-41d4-a716-446655440012'::UUID, '660e8400-e29b-41d4-a716-446655440012'::UUID, 'CONTEXT_DUMP', 135200, 18950, 0.9475, 0.61, 2);

-- =====================================================================
-- DATA VALIDATION AND SUMMARY
-- =====================================================================

-- Validate data insertion
DO $$
DECLARE
    rag_count INTEGER;
    context_dump_count INTEGER;
    avg_rag_time DECIMAL;
    avg_context_time DECIMAL;
    performance_ratio DECIMAL;
BEGIN
    -- Count records and calculate performance metrics
    SELECT COUNT(*) INTO rag_count FROM bronze.raw_queries WHERE processing_method = 'RAG';
    SELECT COUNT(*) INTO context_dump_count FROM bronze.raw_queries WHERE processing_method = 'CONTEXT_DUMP';
    
    SELECT AVG(response_time_ms) INTO avg_rag_time 
    FROM bronze.raw_queries WHERE processing_method = 'RAG';
    
    SELECT AVG(response_time_ms) INTO avg_context_time 
    FROM bronze.raw_queries WHERE processing_method = 'CONTEXT_DUMP';
    
    performance_ratio := avg_context_time / avg_rag_time;
    
    -- Display summary
    RAISE NOTICE '=====================================';
    RAISE NOTICE 'BRONZE LAYER DATA INGESTION COMPLETE';
    RAISE NOTICE '=====================================';
    RAISE NOTICE 'RAG queries: %', rag_count;
    RAISE NOTICE 'Context dump queries: %', context_dump_count;
    RAISE NOTICE 'Average RAG response time: % ms', ROUND(avg_rag_time, 2);
    RAISE NOTICE 'Average Context Dump response time: % ms', ROUND(avg_context_time, 2);
    RAISE NOTICE 'Context Dump is %x SLOWER than RAG', ROUND(performance_ratio, 1);
    RAISE NOTICE '=====================================';
END $$;

-- =====================================================================
-- Project 2.2: Brain Architecture - Silver Layer DML
-- File: 02_silver_data_transformation.sql
-- Author: Chi Nguyen
-- Description: Silver layer data transformation from Bronze to business-ready format
-- =====================================================================

-- Set search path
SET search_path TO silver, bronze, public;

-- =====================================================================
-- TRANSFORM QUERIES (Bronze → Silver) 
-- =====================================================================

-- Transform raw queries with enhanced analytics and quality scoring
INSERT INTO silver.queries (
    query_id, user_id, query_text_clean, query_timestamp,
    response_text_clean, response_timestamp, processing_method,
    response_time_ms, tokens_used, cost_usd, query_complexity_score,
    response_quality_score, user_satisfaction, query_category,
    is_follow_up, context_relevance_score
)
SELECT 
    rq.query_id,
    rq.user_id,
    -- Clean query text (remove extra spaces, normalize)
    TRIM(REGEXP_REPLACE(rq.query_text, '\s+', ' ', 'g')) as query_text_clean,
    rq.query_timestamp,
    -- Clean response text (truncate for readability)
    CASE 
        WHEN LENGTH(rq.response_text) > 500 
        THEN CONCAT(LEFT(rq.response_text, 497), '...')
        ELSE rq.response_text
    END as response_text_clean,
    rq.response_timestamp,
    rq.processing_method,
    rq.response_time_ms,
    rq.tokens_used,
    rq.cost_usd,
    -- Calculate query complexity based on length and keywords
    CASE 
        WHEN LENGTH(rq.query_text) > 200 THEN 8
        WHEN LENGTH(rq.query_text) > 150 THEN 7
        WHEN LENGTH(rq.query_text) > 100 THEN 6
        WHEN LENGTH(rq.query_text) > 75 THEN 5
        WHEN LENGTH(rq.query_text) > 50 THEN 4
        WHEN LENGTH(rq.query_text) > 25 THEN 3
        ELSE 2
    END as query_complexity_score,
    rpm.quality_score as response_quality_score,
    rpm.user_satisfaction,
    -- Categorize queries based on content
    CASE 
        WHEN rq.query_text ILIKE '%performance%' OR rq.query_text ILIKE '%speed%' OR rq.query_text ILIKE '%fast%' THEN 'PERFORMANCE'
        WHEN rq.query_text ILIKE '%cost%' OR rq.query_text ILIKE '%price%' OR rq.query_text ILIKE '%ROI%' THEN 'COST_ANALYSIS'
        WHEN rq.query_text ILIKE '%implement%' OR rq.query_text ILIKE '%deploy%' THEN 'IMPLEMENTATION'
        WHEN rq.query_text ILIKE '%architecture%' OR rq.query_text ILIKE '%design%' THEN 'ARCHITECTURE'
        WHEN rq.query_text ILIKE '%explain%' OR rq.query_text ILIKE '%what%' OR rq.query_text ILIKE '%how%' THEN 'EDUCATIONAL'
        ELSE 'GENERAL'
    END as query_category,
    -- Determine if this is a follow-up query (basic heuristic)
    false as is_follow_up,  -- Simplified for this demo
    -- Calculate context relevance based on processing method and quality
    CASE 
        WHEN rq.processing_method = 'RAG' AND rpm.quality_score > 0.85 THEN 0.95
        WHEN rq.processing_method = 'RAG' AND rpm.quality_score > 0.75 THEN 0.85
        WHEN rq.processing_method = 'RAG' THEN 0.75
        WHEN rq.processing_method = 'CONTEXT_DUMP' AND rpm.quality_score > 0.75 THEN 0.70
        WHEN rq.processing_method = 'CONTEXT_DUMP' THEN 0.60
        ELSE 0.50
    END as context_relevance_score
FROM bronze.raw_queries rq
LEFT JOIN bronze.raw_performance_metrics rpm ON rq.query_id = rpm.query_id
WHERE NOT EXISTS (
    SELECT 1 FROM silver.queries sq WHERE sq.query_id = rq.query_id
);

-- =====================================================================
-- TRANSFORM PERFORMANCE METRICS (Bronze → Silver)
-- =====================================================================

-- Transform performance metrics with enhanced analytics
INSERT INTO silver.performance_metrics (
    metric_id, query_id, processing_method, response_time_ms,
    token_count, cost_per_query_usd, quality_score, user_satisfaction,
    efficiency_score, cost_efficiency_ratio, performance_percentile,
    timestamp
)
SELECT 
    rpm.metric_id,
    rpm.query_id,
    rpm.processing_method,
    rpm.response_time_ms,
    rpm.token_count,
    rpm.cost_per_query_usd,
    rpm.quality_score,
    rpm.user_satisfaction,
    -- Calculate efficiency score (quality/time ratio)
    ROUND(
        (rpm.quality_score / (rpm.response_time_ms::DECIMAL / 1000)) * 100, 2
    ) as efficiency_score,
    -- Calculate cost efficiency (quality/cost ratio)
    ROUND(
        rpm.quality_score / NULLIF(rpm.cost_per_query_usd, 0), 6
    ) as cost_efficiency_ratio,
    -- Calculate performance percentile within processing method
    ROUND(
        PERCENT_RANK() OVER (
            PARTITION BY rpm.processing_method 
            ORDER BY rpm.response_time_ms ASC
        ) * 100
    ) as performance_percentile,
    rpm.timestamp
FROM bronze.raw_performance_metrics rpm
WHERE NOT EXISTS (
    SELECT 1 FROM silver.performance_metrics spm WHERE spm.metric_id = rpm.metric_id
);

-- =====================================================================
-- DATA VALIDATION AND SUMMARY
-- =====================================================================

-- Validate transformation and display summary
DO $$
DECLARE
    queries_transformed INTEGER;
    rag_queries INTEGER;
    context_dump_queries INTEGER;
    avg_rag_response_time DECIMAL;
    avg_context_response_time DECIMAL;
    performance_improvement DECIMAL;
BEGIN
    -- Count transformed records
    SELECT COUNT(*) INTO queries_transformed FROM silver.queries;
    SELECT COUNT(*) INTO rag_queries FROM silver.queries WHERE processing_method = 'RAG';
    SELECT COUNT(*) INTO context_dump_queries FROM silver.queries WHERE processing_method = 'CONTEXT_DUMP';
    
    -- Get performance metrics
    SELECT AVG(response_time_ms) INTO avg_rag_response_time 
    FROM silver.queries WHERE processing_method = 'RAG';
    
    SELECT AVG(response_time_ms) INTO avg_context_response_time 
    FROM silver.queries WHERE processing_method = 'CONTEXT_DUMP';
    
    -- Calculate improvements
    IF avg_rag_response_time > 0 AND avg_context_response_time > 0 THEN
        performance_improvement := ROUND((avg_context_response_time - avg_rag_response_time) / avg_context_response_time * 100, 1);
    ELSE
        performance_improvement := 0;
    END IF;
    
    -- Display transformation summary
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'SILVER LAYER TRANSFORMATION COMPLETE';
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Queries transformed: %', queries_transformed;
    RAISE NOTICE 'RAG queries: %', rag_queries;
    RAISE NOTICE 'Context dump queries: %', context_dump_queries;
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE 'BUSINESS VALUE DELIVERED:';
    RAISE NOTICE 'RAG Performance Advantage: %% faster', performance_improvement;
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE 'Analytics Ready: Business metrics calculated';
    RAISE NOTICE 'Ready for Gold layer aggregation!';
    RAISE NOTICE '==========================================';
END $$;

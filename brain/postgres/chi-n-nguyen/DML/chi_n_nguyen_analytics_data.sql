-- =====================================================================
-- Project 2.2: Brain Architecture - Bonus Analytics Table DML
-- File: chi_n_nguyen_analytics_data.sql  
-- Author: Chi Nguyen
-- Description: Bonus downstream analytics using WHERE/ORDER BY/GROUP BY
-- =====================================================================

-- Set search path
SET search_path TO project_two, public;

-- Clear existing analytics data
TRUNCATE TABLE project_two.chi_n_nguyen_analytics RESTART IDENTITY CASCADE;

-- =====================================================================
-- BONUS: DOWNSTREAM ANALYTICS USING GROUP BY/WHERE/ORDER BY
-- =====================================================================

-- Generate analytics by aggregating main table data using GROUP BY
INSERT INTO project_two.chi_n_nguyen_analytics (
    context_method, brain_layer_used, model_name,
    total_interactions, avg_response_time_ms, min_response_time_ms, max_response_time_ms,
    avg_cost_usd, total_cost_usd, cost_per_token,
    avg_quality_score, avg_user_satisfaction, quality_consistency_score,
    avg_prompt_tokens, avg_completion_tokens, avg_total_tokens, token_efficiency_ratio,
    success_rate_percent, high_quality_interactions, high_satisfaction_interactions,
    avg_retrieval_time_ms, avg_context_size_tokens, context_efficiency_score
)
SELECT 
    -- GROUP BY dimensions
    cn.context_method,
    cn.brain_layer_used,
    cn.model_name,
    
    -- Aggregated metrics using COUNT, AVG, MIN, MAX
    COUNT(*) as total_interactions,
    ROUND(AVG(cn.response_time_ms), 2) as avg_response_time_ms,
    MIN(cn.response_time_ms) as min_response_time_ms,
    MAX(cn.response_time_ms) as max_response_time_ms,
    
    -- Cost analytics
    ROUND(AVG(cn.cost_usd), 8) as avg_cost_usd,
    ROUND(SUM(cn.cost_usd), 6) as total_cost_usd,
    ROUND(AVG(cn.cost_usd) / NULLIF(AVG(cn.total_tokens), 0), 8) as cost_per_token,
    
    -- Quality metrics with statistical analysis
    ROUND(AVG(cn.quality_score), 3) as avg_quality_score,
    ROUND(AVG(cn.user_satisfaction_rating), 2) as avg_user_satisfaction,
    ROUND(1.0 - STDDEV(cn.quality_score) / NULLIF(AVG(cn.quality_score), 0), 3) as quality_consistency_score,
    
    -- Token usage analytics
    ROUND(AVG(cn.prompt_tokens), 2) as avg_prompt_tokens,
    ROUND(AVG(cn.completion_tokens), 2) as avg_completion_tokens,
    ROUND(AVG(cn.total_tokens), 2) as avg_total_tokens,
    ROUND(AVG(cn.completion_tokens) / NULLIF(AVG(cn.prompt_tokens), 0), 4) as token_efficiency_ratio,
    
    -- Success rate calculations using conditional aggregation
    ROUND(COUNT(CASE WHEN cn.user_satisfaction_rating >= 4 THEN 1 END) * 100.0 / COUNT(*), 2) as success_rate_percent,
    COUNT(CASE WHEN cn.quality_score >= 0.85 THEN 1 END) as high_quality_interactions,
    COUNT(CASE WHEN cn.user_satisfaction_rating >= 4 THEN 1 END) as high_satisfaction_interactions,
    
    -- Context-specific metrics using conditional averages
    ROUND(AVG(CASE WHEN cn.context_method = 'RAG' THEN cn.retrieval_time_ms END), 2) as avg_retrieval_time_ms,
    ROUND(AVG(CASE WHEN cn.context_method = 'CONTEXT_DUMP' THEN cn.context_size_tokens END), 2) as avg_context_size_tokens,
    ROUND(AVG(cn.quality_score) / (AVG(cn.response_time_ms) / 1000.0), 3) as context_efficiency_score

FROM project_two.chi_n_nguyen cn
-- WHERE clause to filter for meaningful analysis
WHERE cn.user_satisfaction_rating IS NOT NULL 
  AND cn.quality_score IS NOT NULL
  AND cn.response_time_ms > 0
-- GROUP BY all non-aggregated columns
GROUP BY cn.context_method, cn.brain_layer_used, cn.model_name
-- HAVING clause to ensure statistical significance  
HAVING COUNT(*) >= 1;

-- =====================================================================
-- UPDATE PERFORMANCE RANKINGS USING WINDOW FUNCTIONS AND ORDER BY
-- =====================================================================

-- Update performance rankings based on response time (ORDER BY performance)
UPDATE project_two.chi_n_nguyen_analytics 
SET performance_rank = ranked_data.rank
FROM (
    SELECT 
        analytics_id,
        RANK() OVER (ORDER BY avg_response_time_ms ASC) as rank
    FROM project_two.chi_n_nguyen_analytics
) ranked_data
WHERE project_two.chi_n_nguyen_analytics.analytics_id = ranked_data.analytics_id;

-- Update cost efficiency rankings (ORDER BY cost efficiency)
UPDATE project_two.chi_n_nguyen_analytics 
SET cost_efficiency_rank = ranked_data.rank
FROM (
    SELECT 
        analytics_id,
        RANK() OVER (ORDER BY avg_cost_usd ASC) as rank
    FROM project_two.chi_n_nguyen_analytics
) ranked_data
WHERE project_two.chi_n_nguyen_analytics.analytics_id = ranked_data.analytics_id;

-- Update quality rankings (ORDER BY quality descending)
UPDATE project_two.chi_n_nguyen_analytics 
SET quality_rank = ranked_data.rank
FROM (
    SELECT 
        analytics_id,
        RANK() OVER (ORDER BY avg_quality_score DESC) as rank
    FROM project_two.chi_n_nguyen_analytics
) ranked_data
WHERE project_two.chi_n_nguyen_analytics.analytics_id = ranked_data.analytics_id;

-- =====================================================================
-- CALCULATE BASELINE COMPARISONS USING SUBQUERIES
-- =====================================================================

-- Update baseline comparisons using subqueries and aggregation
UPDATE project_two.chi_n_nguyen_analytics 
SET 
    performance_vs_baseline_percent = ROUND(
        (baseline.avg_response_time - ca.avg_response_time_ms) / baseline.avg_response_time * 100, 2
    ),
    cost_vs_baseline_percent = ROUND(
        (baseline.avg_cost - ca.avg_cost_usd) / baseline.avg_cost * 100, 2
    )
FROM project_two.chi_n_nguyen_analytics ca
CROSS JOIN (
    -- Subquery calculating overall baseline metrics
    SELECT 
        AVG(avg_response_time_ms) as avg_response_time,
        AVG(avg_cost_usd) as avg_cost
    FROM project_two.chi_n_nguyen_analytics
) baseline
WHERE project_two.chi_n_nguyen_analytics.analytics_id = ca.analytics_id;

-- =====================================================================
-- GENERATE ADDITIONAL INSIGHTS USING ADVANCED WHERE/ORDER BY/GROUP BY
-- =====================================================================

-- Create summary statistics grouped by context method (using WHERE and GROUP BY)
DO $$
DECLARE
    method_stats RECORD;
    best_performer RECORD;
    worst_performer RECORD;
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'BONUS ANALYTICS: DOWNSTREAM TABLE ANALYSIS';
    RAISE NOTICE '==============================================';
    
    -- Loop through each context method (GROUP BY simulation)
    FOR method_stats IN 
        SELECT 
            context_method,
            COUNT(*) as configurations,
            AVG(avg_response_time_ms) as avg_time,
            AVG(avg_cost_usd) as avg_cost,
            AVG(avg_quality_score) as avg_quality,
            AVG(success_rate_percent) as avg_success_rate
        FROM project_two.chi_n_nguyen_analytics
        GROUP BY context_method
        ORDER BY avg_response_time_ms ASC
    LOOP
        RAISE NOTICE 'Method: % | Configs: % | Avg Time: %ms | Avg Cost: $% | Quality: % | Success: %%',
            method_stats.context_method,
            method_stats.configurations,
            ROUND(method_stats.avg_time, 0),
            ROUND(method_stats.avg_cost, 6),
            ROUND(method_stats.avg_quality, 2),
            ROUND(method_stats.avg_success_rate, 1);
    END LOOP;
    
    -- Find best performer using ORDER BY and LIMIT (WHERE performance_rank = 1)
    SELECT context_method, model_name, avg_response_time_ms, avg_cost_usd, avg_quality_score
    INTO best_performer
    FROM project_two.chi_n_nguyen_analytics
    WHERE performance_rank = 1
    ORDER BY avg_response_time_ms ASC
    LIMIT 1;
    
    -- Find worst performer using ORDER BY DESC and LIMIT
    SELECT context_method, model_name, avg_response_time_ms, avg_cost_usd, avg_quality_score
    INTO worst_performer
    FROM project_two.chi_n_nguyen_analytics
    ORDER BY avg_response_time_ms DESC
    LIMIT 1;
    
    RAISE NOTICE '----------------------------------------------';
    RAISE NOTICE 'BEST PERFORMER: % + % | Time: %ms | Cost: $% | Quality: %',
        best_performer.context_method,
        best_performer.model_name,
        best_performer.avg_response_time_ms,
        best_performer.avg_cost_usd,
        best_performer.avg_quality_score;
        
    RAISE NOTICE 'WORST PERFORMER: % + % | Time: %ms | Cost: $% | Quality: %',
        worst_performer.context_method,
        worst_performer.model_name,
        worst_performer.avg_response_time_ms,
        worst_performer.avg_cost_usd,
        worst_performer.avg_quality_score;
    
    RAISE NOTICE '----------------------------------------------';
    RAISE NOTICE 'PERFORMANCE IMPROVEMENT: %x faster with best vs worst',
        ROUND(worst_performer.avg_response_time_ms / best_performer.avg_response_time_ms, 1);
    
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'BONUS TASK COMPLETED: Advanced WHERE/ORDER BY/GROUP BY operations demonstrated!';
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================================
-- DEMONSTRATION OF COMPLEX ANALYTICAL QUERIES
-- =====================================================================

-- Complex query demonstrating multiple WHERE/ORDER BY/GROUP BY operations
SELECT 
    'Advanced Analysis: Context Method Performance Ranking' as analysis_type,
    context_method,
    brain_layer_used,
    COUNT(*) as configurations,
    ROUND(AVG(avg_response_time_ms), 1) as avg_response_time,
    ROUND(AVG(avg_cost_usd), 6) as avg_cost,
    ROUND(AVG(success_rate_percent), 1) as avg_success_rate,
    -- Ranking within each brain layer
    RANK() OVER (
        PARTITION BY brain_layer_used 
        ORDER BY AVG(avg_response_time_ms) ASC
    ) as layer_performance_rank,
    -- Percentile ranking across all methods
    ROUND(
        PERCENT_RANK() OVER (ORDER BY AVG(avg_response_time_ms) ASC) * 100, 1
    ) as percentile_rank
FROM project_two.chi_n_nguyen_analytics
-- WHERE clause for filtering
WHERE avg_quality_score >= 0.8  -- Only high-quality configurations
  AND total_interactions >= 1   -- Ensure statistical significance
-- GROUP BY for aggregation
GROUP BY context_method, brain_layer_used
-- HAVING for post-aggregation filtering  
HAVING AVG(success_rate_percent) >= 50.0
-- ORDER BY for final result ordering
ORDER BY 
    brain_layer_used,
    AVG(avg_response_time_ms) ASC;

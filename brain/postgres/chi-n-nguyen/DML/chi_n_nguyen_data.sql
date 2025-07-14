-- =====================================================================
-- Project 2.2: Brain Architecture - Main Table DML
-- File: chi_n_nguyen_data.sql
-- Author: Chi Nguyen
-- Description: Data insertion for chi_n_nguyen table (Project 2.2 spec)
-- =====================================================================

-- Set search path
SET search_path TO project_two, public;

-- Clear existing data (for testing)
TRUNCATE TABLE project_two.chi_n_nguyen RESTART IDENTITY CASCADE;

-- =====================================================================
-- RAG-BASED INTERACTIONS
-- Demonstrating Retrieval-Augmented Generation from Lecture 2.2
-- =====================================================================

INSERT INTO project_two.chi_n_nguyen (
    session_id, user_id, model_name, engine_type, prompt_tokens, completion_tokens, total_tokens,
    user_query, ai_response, context_method, retrieved_documents, similarity_scores,
    retrieval_time_ms, vector_search_query, knowledge_base_version,
    response_time_ms, cost_usd, quality_score, user_satisfaction_rating,
    brain_layer_used, context_window_utilized, memory_retrieval_successful,
    request_ip, user_agent, api_version, environment, tenant_id
) VALUES 
-- High-performance RAG interaction
(
    'sess_001', 'student_001', 'gpt-4o-mini', 'brain', 180, 320, 500,
    'What are the key differences between RAG and context dumping in AI systems?',
    'RAG (Retrieval-Augmented Generation) and context dumping represent fundamentally different approaches to providing context to LLMs. RAG delivers approximately 45x faster response times and significantly lower costs by selectively retrieving only relevant information from a knowledge base, while context dumping provides the entire context window to the model...',
    'RAG',
    '[
        {"doc_id": "brain_001", "content": "RAG systems achieve superior performance through selective retrieval...", "source": "AI_Research", "score": 0.94},
        {"doc_id": "brain_002", "content": "Context dumping provides complete continuity but at higher cost...", "source": "Performance_Studies", "score": 0.89}
    ]'::jsonb,
    '[0.94, 0.89, 0.87, 0.82]'::jsonb,
    120, 'brain architecture RAG vs context dumping performance',
    'knowledge_base_v2.1',
    980, 0.000085, 0.92, 5,
    'silver', 500, true,
    '192.168.1.100'::inet, 'Mozilla/5.0 (Brain Research Client)',
    'v2.1', 'development', 'ai_dscubed_project'
),

-- Complex RAG query with multiple retrievals
(
    'sess_002', 'student_002', 'claude-3-sonnet', 'brain', 220, 450, 670,
    'How does the Medallion Architecture support Brain functionality in AI systems?',
    'The Medallion Architecture provides a structured approach to Brain functionality through its three-layer design: Bronze (raw data), Silver (cleaned processing), and Gold (business analytics). This enables sophisticated context management by allowing the Brain to access different levels of data granularity...',
    'RAG',
    '[
        {"doc_id": "medallion_001", "content": "Bronze layer captures raw AI interactions...", "source": "Architecture_Docs", "score": 0.91},
        {"doc_id": "medallion_002", "content": "Silver layer transforms data into analysis-ready format...", "source": "Data_Engineering", "score": 0.88}
    ]'::jsonb,
    '[0.91, 0.88, 0.85]'::jsonb,
    150, 'medallion architecture brain functionality AI systems',
    'knowledge_base_v2.1',
    1150, 0.000112, 0.89, 4,
    'silver', 670, true,
    '10.0.0.15'::inet, 'Mozilla/5.0 (Research Browser)',
    'v2.1', 'development', 'ai_dscubed_project'
),

-- Fast RAG query demonstrating efficiency
(
    'sess_003', 'student_003', 'gpt-4o-mini', 'advanced', 95, 180, 275,
    'Quick summary: advantages of RAG over context dumping',
    'RAG advantages: 45x faster response times, significantly lower costs, selective information retrieval, reduced token usage, scalable knowledge base integration.',
    'RAG',
    '[
        {"doc_id": "rag_benefits_001", "content": "RAG enables cost-effective knowledge retrieval...", "source": "Performance_Analysis", "score": 0.96}
    ]'::jsonb,
    '[0.96, 0.93]'::jsonb,
    80, 'RAG advantages benefits over context dumping',
    'knowledge_base_v2.1',
    650, 0.000045, 0.95, 5,
    'bronze', 275, true,
    '172.16.0.10'::inet, 'Mozilla/5.0 (Engineering Tools)',
    'v2.1', 'development', 'ai_dscubed_project'
);

-- =====================================================================
-- CONTEXT DUMPING INTERACTIONS  
-- Demonstrating full context approach with higher costs
-- =====================================================================

INSERT INTO project_two.chi_n_nguyen (
    session_id, user_id, model_name, engine_type, prompt_tokens, completion_tokens, total_tokens,
    user_query, ai_response, context_method, context_size_tokens, context_truncated,
    full_context_text, context_compression_ratio,
    response_time_ms, cost_usd, quality_score, user_satisfaction_rating,
    brain_layer_used, context_window_utilized, memory_retrieval_successful,
    request_ip, user_agent, api_version, environment, tenant_id
) VALUES 
-- Context dumping interaction showing higher costs
(
    'sess_004', 'student_004', 'gpt-4o', 'brain', 7800, 1200, 9000,
    'Write a comprehensive analysis of AI system architectures.',
    'The evolution of AI system architectures represents a fundamental shift from monolithic systems to sophisticated, layered approaches. Traditional systems relied on brute-force processing, while modern Brain Architecture introduces intelligent context management, selective retrieval, and medallion-based data processing...',
    'CONTEXT_DUMP',
    7800, false,
    'FULL CONTEXT: Complete historical documentation of AI architectures, detailed performance studies, comprehensive research papers on Brain Architecture, Medallion Architecture principles, RAG implementation guidelines...',
    0.85,
    42000, 0.185, 0.93, 4,
    'gold', 9000, true,
    '192.168.1.101'::inet, 'Mozilla/5.0 (Academic Research)',
    'v2.1', 'development', 'ai_dscubed_project'
),

-- Large context dump with maximum utilization
(
    'sess_005', 'student_005', 'claude-3-opus', 'brain', 12000, 2000, 14000,
    'Develop a strategic business plan for implementing Brain Architecture.',
    'Strategic implementation of Brain Architecture requires comprehensive planning. The implementation roadmap should begin with pilot programs, gradually scaling while maintaining operational continuity. Cost-benefit analysis indicates substantial long-term ROI...',
    'CONTEXT_DUMP',
    12000, false,
    'COMPREHENSIVE CONTEXT: Complete business strategy documentation, financial models, market research, competitor analysis, technology assessments, implementation case studies...',
    0.80,
    58000, 0.295, 0.88, 3,
    'gold', 14000, true,
    '10.0.0.25'::inet, 'Mozilla/5.0 (Business Intelligence)',
    'v2.1', 'development', 'ai_dscubed_project'
);

-- =====================================================================
-- HYBRID APPROACH INTERACTIONS
-- Demonstrating balanced performance between RAG and Context Dumping
-- =====================================================================

INSERT INTO project_two.chi_n_nguyen (
    session_id, user_id, model_name, engine_type, prompt_tokens, completion_tokens, total_tokens,
    user_query, ai_response, context_method, retrieved_documents, similarity_scores,
    retrieval_time_ms, vector_search_query, knowledge_base_version,
    context_size_tokens, context_truncated, full_context_text, context_compression_ratio,
    response_time_ms, cost_usd, quality_score, user_satisfaction_rating,
    brain_layer_used, context_window_utilized, memory_retrieval_successful,
    request_ip, user_agent, api_version, environment, tenant_id
) VALUES 
-- Hybrid approach balancing retrieval and context
(
    'sess_006', 'student_006', 'gpt-4o', 'brain', 2500, 800, 3300,
    'Analyze the performance implications of different Brain Architecture implementations.',
    'Production implementations of Brain Architecture demonstrate significant performance variations based on context management strategy. RAG implementations achieve average response times of 0.98 seconds with costs of $0.000085 per query, while context dumping approaches average 42 seconds with costs of $0.185 per query...',
    'HYBRID',
    '[
        {"doc_id": "performance_study_001", "content": "Production RAG systems demonstrate sub-second response times...", "source": "Production_Analytics", "score": 0.92}
    ]'::jsonb,
    '[0.92, 0.88]'::jsonb,
    200, 'brain architecture production performance analysis',
    'knowledge_base_v2.1',
    2500, false,
    'SELECTIVE CONTEXT: Key performance studies, production metrics, user feedback analysis...',
    0.65,
    2300, 0.0052, 0.91, 4,
    'silver', 3300, true,
    '172.16.0.20'::inet, 'Mozilla/5.0 (Research Platform)',
    'v2.1', 'development', 'ai_dscubed_project'
);

-- =====================================================================
-- DATA VALIDATION AND SUMMARY
-- =====================================================================

-- Display insertion summary
DO $$
DECLARE
    total_records INTEGER;
    rag_records INTEGER;
    context_dump_records INTEGER;
    hybrid_records INTEGER;
    avg_rag_cost DECIMAL(10, 6);
    avg_context_dump_cost DECIMAL(10, 6);
    avg_rag_time INTEGER;
    avg_context_dump_time INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_records FROM project_two.chi_n_nguyen;
    SELECT COUNT(*) INTO rag_records FROM project_two.chi_n_nguyen WHERE context_method = 'RAG';
    SELECT COUNT(*) INTO context_dump_records FROM project_two.chi_n_nguyen WHERE context_method = 'CONTEXT_DUMP';
    SELECT COUNT(*) INTO hybrid_records FROM project_two.chi_n_nguyen WHERE context_method = 'HYBRID';
    
    SELECT AVG(cost_usd) INTO avg_rag_cost FROM project_two.chi_n_nguyen WHERE context_method = 'RAG';
    SELECT AVG(cost_usd) INTO avg_context_dump_cost FROM project_two.chi_n_nguyen WHERE context_method = 'CONTEXT_DUMP';
    SELECT AVG(response_time_ms) INTO avg_rag_time FROM project_two.chi_n_nguyen WHERE context_method = 'RAG';
    SELECT AVG(response_time_ms) INTO avg_context_dump_time FROM project_two.chi_n_nguyen WHERE context_method = 'CONTEXT_DUMP';
    
    RAISE NOTICE 'PROJECT 2.2 DATA INSERTION COMPLETED!';
    RAISE NOTICE 'Total records inserted: %', total_records;
    RAISE NOTICE 'RAG interactions: % (avg cost: $%, avg time: %ms)', rag_records, avg_rag_cost, avg_rag_time;
    RAISE NOTICE 'Context Dump interactions: % (avg cost: $%, avg time: %ms)', context_dump_records, avg_context_dump_cost, avg_context_dump_time;
    RAISE NOTICE 'Hybrid interactions: %', hybrid_records;
    RAISE NOTICE 'Performance demonstration: RAG is %x faster and %x cheaper than Context Dumping!', 
                 ROUND(avg_context_dump_time::DECIMAL / avg_rag_time::DECIMAL), 
                 ROUND(avg_context_dump_cost / avg_rag_cost);
END $$;

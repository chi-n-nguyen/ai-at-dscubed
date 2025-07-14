-- =====================================================================
-- Project 2.2: Brain Architecture - Main Table DDL
-- File: chi_n_nguyen_table.sql
-- Author: Chi Nguyen  
-- Description: Primary table as required by Project 2.2 specification
-- =====================================================================

-- Create project_two schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS project_two;

-- Set search path
SET search_path TO project_two, public;

-- =====================================================================
-- CHI_N_NGUYEN TABLE (Project 2.2 Main Requirement)
-- =====================================================================

-- Drop table if exists (for testing)
DROP TABLE IF EXISTS project_two.chi_n_nguyen CASCADE;

-- Create main table as per specification
CREATE TABLE project_two.chi_n_nguyen (
    -- Primary key and metadata
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- AI Interaction Data (Brain Architecture Focus)
    session_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
    
    -- AI Model Information
    model_name VARCHAR(50) NOT NULL,
    engine_type VARCHAR(50) NOT NULL,
    
    -- Token Usage Metrics
    prompt_tokens INTEGER,
    completion_tokens INTEGER,
    total_tokens INTEGER,
    
    -- Query and Response Data
    user_query TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    
    -- Brain Architecture: Context Method (Core to Brain lecture)
    context_method VARCHAR(20) NOT NULL CHECK (context_method IN ('RAG', 'CONTEXT_DUMP', 'HYBRID')),
    
    -- Performance Metrics
    response_time_ms INTEGER,
    cost_usd DECIMAL(10, 6),
    quality_score DECIMAL(3, 2) CHECK (quality_score >= 0 AND quality_score <= 1),
    user_satisfaction_rating INTEGER CHECK (user_satisfaction_rating >= 1 AND user_satisfaction_rating <= 5),
    
    -- RAG-specific fields (when context_method = 'RAG')
    retrieved_documents JSONB,
    similarity_scores JSONB,
    retrieval_time_ms INTEGER,
    vector_search_query TEXT,
    knowledge_base_version VARCHAR(50),
    
    -- Context-specific fields (when context_method = 'CONTEXT_DUMP')
    context_size_tokens INTEGER,
    context_truncated BOOLEAN DEFAULT FALSE,
    full_context_text TEXT,
    context_compression_ratio DECIMAL(3, 2),
    
    -- Brain Layer Information
    brain_layer_used VARCHAR(20) CHECK (brain_layer_used IN ('bronze', 'silver', 'gold')),
    context_window_utilized INTEGER,
    memory_retrieval_successful BOOLEAN DEFAULT TRUE,
    
    -- Request metadata
    request_ip INET,
    user_agent TEXT,
    api_version VARCHAR(20),
    environment VARCHAR(20) DEFAULT 'development',
    tenant_id VARCHAR(50)
);

-- =====================================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================================

-- Primary access patterns
CREATE INDEX idx_chi_n_nguyen_session_user ON project_two.chi_n_nguyen(session_id, user_id);
CREATE INDEX idx_chi_n_nguyen_context_method ON project_two.chi_n_nguyen(context_method);
CREATE INDEX idx_chi_n_nguyen_created_at ON project_two.chi_n_nguyen(created_at DESC);
CREATE INDEX idx_chi_n_nguyen_brain_layer ON project_two.chi_n_nguyen(brain_layer_used);

-- Performance analysis indexes
CREATE INDEX idx_chi_n_nguyen_response_time ON project_two.chi_n_nguyen(response_time_ms);
CREATE INDEX idx_chi_n_nguyen_cost ON project_two.chi_n_nguyen(cost_usd);
CREATE INDEX idx_chi_n_nguyen_quality ON project_two.chi_n_nguyen(quality_score DESC);

-- =====================================================================
-- TRIGGERS FOR AUTOMATION
-- =====================================================================

-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER trigger_chi_n_nguyen_updated_at
    BEFORE UPDATE ON project_two.chi_n_nguyen
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================================

COMMENT ON TABLE project_two.chi_n_nguyen IS 
'Main table for Project 2.2 Brain Architecture analysis. Stores AI interaction data 
comparing RAG vs Context Dumping approaches as discussed in Lecture 2.2.';

COMMENT ON COLUMN project_two.chi_n_nguyen.context_method IS 
'The method used for providing context to the AI: RAG, CONTEXT_DUMP, or HYBRID';

COMMENT ON COLUMN project_two.chi_n_nguyen.brain_layer_used IS 
'Which layer of the Brain Architecture was accessed: bronze, silver, or gold';

COMMENT ON COLUMN project_two.chi_n_nguyen.quality_score IS 
'Quality score from 0.0 to 1.0 measuring response accuracy and relevance';

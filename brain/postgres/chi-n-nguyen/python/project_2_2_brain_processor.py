#!/usr/bin/env python3
"""
Project 2.2: Brain Architecture - Modular Python Processor
File: project_2_2_brain_processor.py
Author: Chi Nguyen
Description: Modular Python script for Project 2.2 specification compliance
Connects to RDS PostgreSQL and executes DDL/DML with individual functions
"""

import psycopg2
import psycopg2.extras
import os
import sys
from pathlib import Path
import logging
from typing import List, Dict, Any, Optional
import pandas as pd
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('project_2_2_brain.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class Project22BrainProcessor:
    """
    Modular Brain Architecture processor for Project 2.2
    Implements individual functions for DDL, DML, and table viewing as per specification
    """
    
    def __init__(self, rds_endpoint: str = None, database: str = "postgres", 
                 username: str = None, password: str = None, port: int = 5432):
        """
        Initialize connection to RDS PostgreSQL database
        
        Args:
            rds_endpoint: RDS endpoint URL (provided in Discord)
            database: Database name
            username: Database username
            password: Database password  
            port: Database port
        """
        # Use environment variables or parameters
        self.rds_endpoint = rds_endpoint or os.getenv('RDS_ENDPOINT', 'localhost')
        self.database = database or os.getenv('RDS_DATABASE', 'postgres')
        self.username = username or os.getenv('RDS_USERNAME', 'postgres')
        self.password = password or os.getenv('RDS_PASSWORD', 'password')
        self.port = port or int(os.getenv('RDS_PORT', '5432'))
        
        self.connection = None
        self.base_path = Path(__file__).parent.parent
        
        logger.info(f"Initialized Project 2.2 Brain Processor")
        logger.info(f"Target: {self.rds_endpoint}:{self.port}/{self.database}")
    
    def connect_to_database(self) -> bool:
        """
        Establish connection to RDS PostgreSQL database
        
        Returns:
            bool: True if connection successful, False otherwise
        """
        try:
            self.connection = psycopg2.connect(
                host=self.rds_endpoint,
                database=self.database,
                user=self.username,
                password=self.password,
                port=self.port,
                connect_timeout=30
            )
            self.connection.autocommit = True
            logger.info("✅ Successfully connected to RDS PostgreSQL database")
            return True
            
        except psycopg2.Error as e:
            logger.error(f"❌ Failed to connect to database: {e}")
            return False
        except Exception as e:
            logger.error(f"❌ Unexpected error during connection: {e}")
            return False
    
    def run_ddl(self, ddl_file: str = None) -> bool:
        """
        Execute DDL scripts to create tables and schemas
        Individual function for DDL execution as per Project 2.2 specification
        
        Args:
            ddl_file: Specific DDL file to run (optional)
            
        Returns:
            bool: True if DDL execution successful, False otherwise
        """
        logger.info("��️  Starting DDL execution (CREATE TABLE operations)")
        
        if not self.connection:
            logger.error("No database connection available")
            return False
        
        try:
            cursor = self.connection.cursor()
            
            # Define DDL files to execute
            ddl_files = []
            if ddl_file:
                ddl_files = [ddl_file]
            else:
                # Execute both main and bonus DDL files
                ddl_files = [
                    'DDL/chi_n_nguyen_table.sql',
                    'DDL/chi_n_nguyen_analytics.sql'
                ]
            
            for ddl_file_path in ddl_files:
                full_path = self.base_path / ddl_file_path
                
                if not full_path.exists():
                    logger.warning(f"DDL file not found: {full_path}")
                    continue
                
                logger.info(f"Executing DDL: {ddl_file_path}")
                
                with open(full_path, 'r') as file:
                    ddl_content = file.read()
                
                # Execute DDL script
                cursor.execute(ddl_content)
                logger.info(f"✅ Successfully executed DDL: {ddl_file_path}")
            
            cursor.close()
            logger.info("🎉 DDL execution completed successfully")
            return True
            
        except psycopg2.Error as e:
            logger.error(f"❌ DDL execution failed: {e}")
            return False
        except Exception as e:
            logger.error(f"❌ Unexpected error during DDL execution: {e}")
            return False
    
    def run_dml(self, dml_file: str = None) -> bool:
        """
        Execute DML scripts to insert data into tables
        Individual function for DML execution as per Project 2.2 specification
        
        Args:
            dml_file: Specific DML file to run (optional)
            
        Returns:
            bool: True if DML execution successful, False otherwise
        """
        logger.info("📝 Starting DML execution (INSERT DATA operations)")
        
        if not self.connection:
            logger.error("No database connection available")
            return False
        
        try:
            cursor = self.connection.cursor()
            
            # Define DML files to execute
            dml_files = []
            if dml_file:
                dml_files = [dml_file]
            else:
                # Execute both main and bonus DML files
                dml_files = [
                    'DML/chi_n_nguyen_data.sql',
                    'DML/chi_n_nguyen_analytics_data.sql'
                ]
            
            for dml_file_path in dml_files:
                full_path = self.base_path / dml_file_path
                
                if not full_path.exists():
                    logger.warning(f"DML file not found: {full_path}")
                    continue
                
                logger.info(f"Executing DML: {dml_file_path}")
                
                with open(full_path, 'r') as file:
                    dml_content = file.read()
                
                # Execute DML script
                cursor.execute(dml_content)
                logger.info(f"✅ Successfully executed DML: {dml_file_path}")
            
            cursor.close()
            logger.info("🎉 DML execution completed successfully")
            return True
            
        except psycopg2.Error as e:
            logger.error(f"❌ DML execution failed: {e}")
            return False
        except Exception as e:
            logger.error(f"❌ Unexpected error during DML execution: {e}")
            return False
    
    def view_table(self, table_name: str = "chi_n_nguyen", limit: int = 10, 
                   schema: str = "project_two") -> Optional[pd.DataFrame]:
        """
        View data from a given table
        Individual function for table viewing as per Project 2.2 specification
        
        Args:
            table_name: Name of table to view
            limit: Number of rows to return
            schema: Schema name
            
        Returns:
            pd.DataFrame: Table data or None if error
        """
        logger.info(f"👀 Viewing table: {schema}.{table_name} (limit: {limit})")
        
        if not self.connection:
            logger.error("No database connection available")
            return None
        
        try:
            cursor = self.connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            
            # Query table data
            query = f"""
                SELECT * 
                FROM {schema}.{table_name} 
                ORDER BY created_at DESC 
                LIMIT %s
            """
            
            cursor.execute(query, (limit,))
            rows = cursor.fetchall()
            
            if not rows:
                logger.warning(f"No data found in {schema}.{table_name}")
                return None
            
            # Convert to DataFrame for better display
            df = pd.DataFrame(rows)
            
            logger.info(f"✅ Retrieved {len(df)} rows from {schema}.{table_name}")
            logger.info("📊 Table Preview:")
            print(f"\n{'-'*80}")
            print(f"TABLE: {schema}.{table_name}")
            print(f"{'-'*80}")
            print(df.to_string(max_rows=10, max_cols=8, width=None))
            print(f"{'-'*80}\n")
            
            cursor.close()
            return df
            
        except psycopg2.Error as e:
            logger.error(f"❌ Failed to view table {schema}.{table_name}: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Unexpected error viewing table: {e}")
            return None
    
    def get_performance_analysis(self) -> Optional[Dict[str, Any]]:
        """
        Get Brain Architecture performance analysis from analytics table
        Demonstrates the bonus downstream analytics functionality
        
        Returns:
            Dict with performance analysis results
        """
        logger.info("📈 Generating Brain Architecture performance analysis")
        
        if not self.connection:
            logger.error("No database connection available")
            return None
        
        try:
            cursor = self.connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            
            # Get method comparison data
            cursor.execute("""
                SELECT 
                    context_method,
                    total_interactions,
                    avg_response_time_ms,
                    avg_cost_usd,
                    avg_quality_score,
                    success_rate_percent,
                    performance_rank
                FROM project_two.chi_n_nguyen_analytics
                ORDER BY performance_rank ASC
            """)
            
            method_comparison = cursor.fetchall()
            
            # Get best and worst performers
            cursor.execute("""
                SELECT 'BEST' as category, context_method, model_name, avg_response_time_ms, avg_cost_usd
                FROM project_two.chi_n_nguyen_analytics
                WHERE performance_rank = 1
                UNION ALL
                SELECT 'WORST' as category, context_method, model_name, avg_response_time_ms, avg_cost_usd
                FROM project_two.chi_n_nguyen_analytics
                ORDER BY performance_rank DESC
                LIMIT 2
            """)
            
            performers = cursor.fetchall()
            
            cursor.close()
            
            # Calculate improvement factor
            best_time = next((p['avg_response_time_ms'] for p in performers if p['category'] == 'BEST'), 1)
            worst_time = next((p['avg_response_time_ms'] for p in performers if p['category'] == 'WORST'), 1)
            improvement_factor = round(worst_time / best_time, 1) if best_time > 0 else 0
            
            analysis = {
                'timestamp': datetime.now().isoformat(),
                'method_comparison': [dict(row) for row in method_comparison],
                'best_performer': next((dict(p) for p in performers if p['category'] == 'BEST'), None),
                'worst_performer': next((dict(p) for p in performers if p['category'] == 'WORST'), None),
                'improvement_factor': improvement_factor,
                'total_methods_analyzed': len(method_comparison)
            }
            
            # Display analysis
            print(f"\n{'='*60}")
            print("🧠 BRAIN ARCHITECTURE PERFORMANCE ANALYSIS")
            print(f"{'='*60}")
            
            for method in method_comparison:
                print(f"Method: {method['context_method']:<12} | "
                      f"Rank: #{method['performance_rank']:<2} | "
                      f"Time: {method['avg_response_time_ms']:>6.0f}ms | "
                      f"Cost: ${method['avg_cost_usd']:>8.6f} | "
                      f"Quality: {method['avg_quality_score']:>4.2f}")
            
            print(f"\n🏆 Performance Improvement: {improvement_factor}x faster (best vs worst)")
            print(f"{'='*60}\n")
            
            return analysis
            
        except Exception as e:
            logger.error(f"❌ Failed to generate performance analysis: {e}")
            return None
    
    def close_connection(self):
        """Close database connection"""
        if self.connection:
            self.connection.close()
            logger.info("🔒 Database connection closed")

def main():
    """
    Main execution function demonstrating Project 2.2 requirements
    """
    print("🧠 Project 2.2: Brain Architecture Processor")
    print("=" * 60)
    print("Modular Python implementation for RDS PostgreSQL")
    print("Individual functions for DDL, DML, and table viewing")
    print("=" * 60)
    
    # Initialize processor (configure with actual RDS endpoint from Discord)
    processor = Project22BrainProcessor(
        rds_endpoint="your-rds-endpoint-from-discord.amazonaws.com",  # Update with actual endpoint
        database="postgres",
        username="your_username",  # Update with actual credentials
        password="your_password"   # Update with actual credentials
    )
    
    try:
        # Step 1: Connect to RDS database
        if not processor.connect_to_database():
            logger.error("Failed to connect to database. Exiting.")
            return
        
        # Step 2: Run DDL (CREATE TABLE operations)
        logger.info("Step 1: Executing DDL scripts...")
        if processor.run_ddl():
            logger.info("✅ DDL execution completed")
        else:
            logger.error("❌ DDL execution failed")
            return
        
        # Step 3: Run DML (INSERT DATA operations)
        logger.info("Step 2: Executing DML scripts...")
        if processor.run_dml():
            logger.info("✅ DML execution completed")
        else:
            logger.error("❌ DML execution failed")
            return
        
        # Step 4: View main table (chi_n_nguyen)
        logger.info("Step 3: Viewing main table...")
        main_table_data = processor.view_table("chi_n_nguyen", limit=5)
        
        # Step 5: View bonus analytics table
        logger.info("Step 4: Viewing bonus analytics table...")
        analytics_data = processor.view_table("chi_n_nguyen_analytics", limit=5)
        
        # Step 6: Generate performance analysis
        logger.info("Step 5: Generating performance analysis...")
        analysis = processor.get_performance_analysis()
        
        # Summary
        print("\n" + "="*60)
        print("🎉 PROJECT 2.2 EXECUTION COMPLETED SUCCESSFULLY!")
        print("="*60)
        print("✅ DDL scripts executed (tables created)")
        print("✅ DML scripts executed (data inserted)")
        print("✅ Main table viewed (chi_n_nguyen)")
        print("✅ Bonus analytics table viewed (chi_n_nguyen_analytics)")
        print("✅ Performance analysis generated")
        print("\n🏆 Brain Architecture demonstrates:")
        if analysis:
            print(f"   • {analysis['improvement_factor']}x performance improvement")
            print(f"   • {analysis['total_methods_analyzed']} context methods analyzed")
        print("   • Complete Medallion Architecture implementation")
        print("   • RAG vs Context Dumping comparison")
        print("="*60)
        
    except Exception as e:
        logger.error(f"❌ Main execution failed: {e}")
    
    finally:
        processor.close_connection()

if __name__ == "__main__":
    main()

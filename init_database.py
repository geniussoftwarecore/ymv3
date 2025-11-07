"""
Database Initialization Script for Yaman Workshop Management System
This script initializes the PostgreSQL database with required schemas and tables
"""
import os
import psycopg2
from pathlib import Path
import sys

def get_database_url():
    """Get database URL from environment or use default"""
    return os.getenv("DATABASE_URL", None)

def read_sql_file(filepath):
    """Read SQL file content"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return f.read()

def init_database():
    """Initialize database with SQL scripts"""
    db_url = get_database_url()
    
    if not db_url:
        print("❌ DATABASE_URL environment variable not set!")
        print("\nℹ️  To set up the database:")
        print("1. Go to the Replit Database tab")
        print("2. Create a PostgreSQL database")
        print("3. The DATABASE_URL will be automatically set")
        print("\nOr manually set DATABASE_URL in environment variables.")
        return False
    
    try:
        print(f"📊 Connecting to database...")
        conn = psycopg2.connect(db_url)
        cursor = conn.cursor()
        
        # Get list of SQL initialization scripts
        init_scripts_dir = Path("database/init-scripts")
        sql_files = sorted(init_scripts_dir.glob("*.sql"))
        
        if not sql_files:
            print("❌ No SQL initialization scripts found in database/init-scripts/")
            return False
        
        print(f"📝 Found {len(sql_files)} SQL initialization scripts")
        
        # Execute each SQL file
        for sql_file in sql_files:
            print(f"\n🔄 Executing: {sql_file.name}")
            try:
                sql_content = read_sql_file(sql_file)
                cursor.execute(sql_content)
                conn.commit()
                print(f"✅ {sql_file.name} executed successfully")
            except Exception as e:
                print(f"⚠️  Error in {sql_file.name}: {str(e)}")
                print("   Continuing with next file...")
                conn.rollback()
        
        cursor.close()
        conn.close()
        
        print("\n✅ Database initialization completed!")
        return True
        
    except psycopg2.OperationalError as e:
        print(f"❌ Database connection error: {str(e)}")
        print("\nPlease check:")
        print("- DATABASE_URL is correct")
        print("- Database server is running")
        print("- Network connectivity")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {str(e)}")
        return False

if __name__ == "__main__":
    print("="*60)
    print("Yaman Workshop Management System - Database Initialization")
    print("="*60)
    
    success = init_database()
    sys.exit(0 if success else 1)

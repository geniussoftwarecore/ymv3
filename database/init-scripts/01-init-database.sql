-- إعداد قاعدة البيانات الأولي لنظام إدارة ورش يمن الهجين
-- Initial Database Setup for Yaman Hybrid Workshop Management System

-- إنشاء امتدادات PostgreSQL المطلوبة
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- إنشاء مخططات قاعدة البيانات
CREATE SCHEMA IF NOT EXISTS user_management;
CREATE SCHEMA IF NOT EXISTS service_catalog;
CREATE SCHEMA IF NOT EXISTS work_orders;
CREATE SCHEMA IF NOT EXISTS chat_system;
CREATE SCHEMA IF NOT EXISTS reporting;
CREATE SCHEMA IF NOT EXISTS audit_logs;

-- تعليق على المخططات
COMMENT ON SCHEMA user_management IS 'مخطط إدارة المستخدمين والمصادقة';
COMMENT ON SCHEMA service_catalog IS 'مخطط كتالوج الخدمات والمنتجات';
COMMENT ON SCHEMA work_orders IS 'مخطط إدارة أوامر العمل والمهام';
COMMENT ON SCHEMA chat_system IS 'مخطط نظام الدردشة والرسائل';
COMMENT ON SCHEMA reporting IS 'مخطط التقارير والإحصائيات';
COMMENT ON SCHEMA audit_logs IS 'مخطط سجلات التدقيق والمراجعة';

-- إنشاء أنواع البيانات المخصصة
DO $$
BEGIN
    -- أنواع أدوار المستخدمين
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role_enum') THEN
        CREATE TYPE user_role_enum AS ENUM ('Admin', 'Supervisor', 'Engineer', 'Sales', 'Customer');
    END IF;
    
    -- أنواع حالة المستخدم
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status_enum') THEN
        CREATE TYPE user_status_enum AS ENUM ('Active', 'Inactive', 'Suspended', 'Pending');
    END IF;
    
    -- أنواع حالة أوامر العمل
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'work_order_status_enum') THEN
        CREATE TYPE work_order_status_enum AS ENUM ('Draft', 'Pending', 'In_Progress', 'On_Hold', 'Completed', 'Cancelled');
    END IF;
    
    -- أنواع أولوية أوامر العمل
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'priority_enum') THEN
        CREATE TYPE priority_enum AS ENUM ('Low', 'Medium', 'High', 'Critical');
    END IF;
    
    -- أنواع حالة الخدمات
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'service_status_enum') THEN
        CREATE TYPE service_status_enum AS ENUM ('Available', 'Unavailable', 'Discontinued');
    END IF;
END $$;

-- إنشاء دالة لتحديث timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إنشاء دالة لإنشاء UUID
CREATE OR REPLACE FUNCTION generate_uuid()
RETURNS UUID AS $$
BEGIN
    RETURN uuid_generate_v4();
END;
$$ language 'plpgsql';

-- منح الصلاحيات للمستخدم
GRANT USAGE ON SCHEMA user_management TO yaman_user;
GRANT USAGE ON SCHEMA service_catalog TO yaman_user;
GRANT USAGE ON SCHEMA work_orders TO yaman_user;
GRANT USAGE ON SCHEMA chat_system TO yaman_user;
GRANT USAGE ON SCHEMA reporting TO yaman_user;
GRANT USAGE ON SCHEMA audit_logs TO yaman_user;

GRANT CREATE ON SCHEMA user_management TO yaman_user;
GRANT CREATE ON SCHEMA service_catalog TO yaman_user;
GRANT CREATE ON SCHEMA work_orders TO yaman_user;
GRANT CREATE ON SCHEMA chat_system TO yaman_user;
GRANT CREATE ON SCHEMA reporting TO yaman_user;
GRANT CREATE ON SCHEMA audit_logs TO yaman_user;

-- إنشاء جداول إدارة المستخدمين
CREATE TABLE IF NOT EXISTS user_management.users (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    role user_role_enum DEFAULT 'Customer' NOT NULL,
    status user_status_enum DEFAULT 'Pending' NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    profile_image VARCHAR(500),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

-- إنشاء فهارس للجدول
CREATE INDEX IF NOT EXISTS idx_users_email ON user_management.users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON user_management.users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON user_management.users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON user_management.users(status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON user_management.users(created_at);

-- إنشاء trigger لتحديث updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON user_management.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- إنشاء جدول جلسات المستخدمين
CREATE TABLE IF NOT EXISTS user_management.user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES user_management.users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    refresh_token VARCHAR(500),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    ip_address INET,
    user_agent TEXT,
    device_info TEXT
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_management.user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_management.user_sessions(token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON user_management.user_sessions(expires_at);

-- إنشاء مستخدم إداري افتراضي
INSERT INTO user_management.users (
    email, username, full_name, hashed_password, role, status, is_active, is_verified
) VALUES (
    'admin@yaman-workshop.com',
    'admin',
    'مدير النظام',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5uO8G', -- password: admin123
    'Admin',
    'Active',
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

-- إنشاء جدول سجل التدقيق
CREATE TABLE IF NOT EXISTS audit_logs.audit_trail (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    user_id INTEGER,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);

CREATE INDEX IF NOT EXISTS idx_audit_trail_table_name ON audit_logs.audit_trail(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_trail_operation ON audit_logs.audit_trail(operation);
CREATE INDEX IF NOT EXISTS idx_audit_trail_user_id ON audit_logs.audit_trail(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_trail_timestamp ON audit_logs.audit_trail(timestamp);

-- منح الصلاحيات على الجداول
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA user_management TO yaman_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA audit_logs TO yaman_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA user_management TO yaman_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA audit_logs TO yaman_user;

-- إظهار رسالة نجاح
DO $$
BEGIN
    RAISE NOTICE 'تم إعداد قاعدة البيانات بنجاح - Database setup completed successfully';
END $$;

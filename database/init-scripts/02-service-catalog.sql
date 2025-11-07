-- إعداد جداول كتالوج الخدمات
-- Service Catalog Tables Setup

-- جدول فئات الخدمات
CREATE TABLE IF NOT EXISTS service_catalog.service_categories (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    description TEXT,
    description_ar TEXT,
    icon VARCHAR(255),
    color VARCHAR(7), -- HEX color code
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول الخدمات
CREATE TABLE IF NOT EXISTS service_catalog.services (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    category_id INTEGER NOT NULL REFERENCES service_catalog.service_categories(id),
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    description TEXT,
    description_ar TEXT,
    service_code VARCHAR(50) UNIQUE NOT NULL,
    base_price DECIMAL(10,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'YER',
    estimated_duration INTEGER, -- in minutes
    status service_status_enum DEFAULT 'Available',
    is_featured BOOLEAN DEFAULT FALSE,
    images JSONB, -- array of image URLs
    specifications JSONB, -- service specifications
    requirements JSONB, -- service requirements
    tags TEXT[], -- search tags
    created_by INTEGER REFERENCES user_management.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول أسعار الخدمات (للأسعار المتدرجة)
CREATE TABLE IF NOT EXISTS service_catalog.service_pricing (
    id SERIAL PRIMARY KEY,
    service_id INTEGER NOT NULL REFERENCES service_catalog.services(id) ON DELETE CASCADE,
    tier_name VARCHAR(100) NOT NULL,
    tier_name_ar VARCHAR(100) NOT NULL,
    min_quantity INTEGER DEFAULT 1,
    max_quantity INTEGER,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'YER',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول مواصفات الخدمات
CREATE TABLE IF NOT EXISTS service_catalog.service_specifications (
    id SERIAL PRIMARY KEY,
    service_id INTEGER NOT NULL REFERENCES service_catalog.services(id) ON DELETE CASCADE,
    spec_name VARCHAR(255) NOT NULL,
    spec_name_ar VARCHAR(255) NOT NULL,
    spec_value TEXT NOT NULL,
    spec_value_ar TEXT,
    spec_type VARCHAR(50) DEFAULT 'text', -- text, number, boolean, list
    is_required BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0
);

-- إنشاء الفهارس
CREATE INDEX IF NOT EXISTS idx_service_categories_name ON service_catalog.service_categories(name);
CREATE INDEX IF NOT EXISTS idx_service_categories_active ON service_catalog.service_categories(is_active);

CREATE INDEX IF NOT EXISTS idx_services_category_id ON service_catalog.services(category_id);
CREATE INDEX IF NOT EXISTS idx_services_code ON service_catalog.services(service_code);
CREATE INDEX IF NOT EXISTS idx_services_status ON service_catalog.services(status);
CREATE INDEX IF NOT EXISTS idx_services_featured ON service_catalog.services(is_featured);
CREATE INDEX IF NOT EXISTS idx_services_tags ON service_catalog.services USING GIN(tags);

CREATE INDEX IF NOT EXISTS idx_service_pricing_service_id ON service_catalog.service_pricing(service_id);
CREATE INDEX IF NOT EXISTS idx_service_specifications_service_id ON service_catalog.service_specifications(service_id);

-- إنشاء triggers لتحديث updated_at
CREATE TRIGGER update_service_categories_updated_at
    BEFORE UPDATE ON service_catalog.service_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at
    BEFORE UPDATE ON service_catalog.services
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- إدراج بيانات تجريبية لفئات الخدمات
INSERT INTO service_catalog.service_categories (name, name_ar, description, description_ar, icon, color) VALUES
('Mechanical Repair', 'الإصلاحات الميكانيكية', 'Engine and mechanical system repairs', 'إصلاحات المحرك والأنظمة الميكانيكية', 'fa-wrench', '#FF6B35'),
('Electrical Services', 'الخدمات الكهربائية', 'Electrical system diagnostics and repair', 'تشخيص وإصلاح الأنظمة الكهربائية', 'fa-bolt', '#4ECDC4'),
('Body Work', 'أعمال الهيكل', 'Body repair and painting services', 'خدمات إصلاح ودهان الهيكل', 'fa-car', '#45B7D1'),
('Maintenance', 'الصيانة', 'Regular maintenance and inspection', 'الصيانة الدورية والفحص', 'fa-tools', '#96CEB4'),
('Diagnostics', 'التشخيص', 'Computer diagnostics and testing', 'التشخيص الحاسوبي والاختبار', 'fa-laptop', '#FFEAA7')
ON CONFLICT DO NOTHING;

-- إدراج بيانات تجريبية للخدمات
INSERT INTO service_catalog.services (category_id, name, name_ar, description, description_ar, service_code, base_price, estimated_duration, tags) VALUES
(1, 'Engine Oil Change', 'تغيير زيت المحرك', 'Complete engine oil and filter replacement', 'تغيير زيت المحرك والفلتر بالكامل', 'SRV-001', 15000.00, 30, ARRAY['oil', 'maintenance', 'engine']),
(1, 'Brake System Repair', 'إصلاح نظام الفرامل', 'Brake pad replacement and system check', 'تغيير تيل الفرامل وفحص النظام', 'SRV-002', 25000.00, 60, ARRAY['brakes', 'safety', 'repair']),
(2, 'Battery Replacement', 'تغيير البطارية', 'Car battery testing and replacement', 'فحص وتغيير بطارية السيارة', 'SRV-003', 35000.00, 20, ARRAY['battery', 'electrical', 'replacement']),
(2, 'Alternator Repair', 'إصلاح المولد', 'Alternator diagnostics and repair', 'تشخيص وإصلاح مولد الكهرباء', 'SRV-004', 45000.00, 90, ARRAY['alternator', 'electrical', 'charging']),
(3, 'Dent Removal', 'إزالة الخدوش', 'Professional dent removal service', 'خدمة إزالة الخدوش المهنية', 'SRV-005', 20000.00, 120, ARRAY['bodywork', 'dent', 'cosmetic']),
(4, 'Full Service', 'الصيانة الشاملة', 'Complete vehicle inspection and maintenance', 'فحص وصيانة شاملة للمركبة', 'SRV-006', 75000.00, 180, ARRAY['maintenance', 'inspection', 'service']),
(5, 'Computer Diagnostics', 'التشخيص الحاسوبي', 'ECU diagnostics and error code reading', 'تشخيص وحدة التحكم وقراءة رموز الأخطاء', 'SRV-007', 10000.00, 45, ARRAY['diagnostics', 'computer', 'ecu'])
ON CONFLICT DO NOTHING;

-- منح الصلاحيات
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA service_catalog TO yaman_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA service_catalog TO yaman_user;

-- إظهار رسالة نجاح
DO $$
BEGIN
    RAISE NOTICE 'تم إعداد جداول كتالوج الخدمات بنجاح - Service catalog tables setup completed successfully';
END $$;

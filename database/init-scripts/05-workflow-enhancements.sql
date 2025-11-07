-- Workflow Enhancements for Yaman Hybrid Workshop Management System
-- إضافات سير العمل لنظام إدارة ورش يمن الهجين

-- إضافة أنواع البيانات المطلوبة لسير العمل الجديد
DO $$
BEGIN
    -- أنواع فحص المركبات
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'inspection_type_enum') THEN
        CREATE TYPE inspection_type_enum AS ENUM ('Standard', 'Custom');
    END IF;

    -- أنواع حالة الفحص
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'inspection_status_enum') THEN
        CREATE TYPE inspection_status_enum AS ENUM ('Draft', 'In_Progress', 'Completed', 'Converted_to_Work_Order');
    END IF;

    -- أنواع حالة التوقيع الإلكتروني
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'signature_status_enum') THEN
        CREATE TYPE signature_status_enum AS ENUM ('Pending', 'Signed', 'Rejected', 'Expired');
    END IF;

    -- أنواع الإشعارات
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_type_enum') THEN
        CREATE TYPE notification_type_enum AS ENUM ('Email', 'WhatsApp', 'In_App', 'SMS');
    END IF;

    -- أنواع حالة الإشعارات
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_status_enum') THEN
        CREATE TYPE notification_status_enum AS ENUM ('Pending', 'Sent', 'Delivered', 'Read', 'Failed');
    END IF;
END $$;

-- جدول أنواع المركبات
CREATE TABLE IF NOT EXISTS work_orders.vehicle_types (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER,
    trim_level VARCHAR(100),
    engine_type VARCHAR(100),
    transmission VARCHAR(50),
    fuel_type VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول الفحوصات الأولية
CREATE TABLE IF NOT EXISTS work_orders.inspections (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    inspection_number VARCHAR(50) UNIQUE NOT NULL,

    -- معلومات العميل والمركبة
    customer_id INTEGER NOT NULL REFERENCES user_management.users(id),
    vehicle_type_id INTEGER REFERENCES work_orders.vehicle_types(id),
    vehicle_make VARCHAR(100),
    vehicle_model VARCHAR(100),
    vehicle_year INTEGER,
    vehicle_vin VARCHAR(50),
    vehicle_license_plate VARCHAR(20),
    vehicle_mileage INTEGER,
    vehicle_color VARCHAR(50),
    vehicle_trim VARCHAR(100),

    -- تفاصيل الفحص
    inspection_type inspection_type_enum DEFAULT 'Standard',
    status inspection_status_enum DEFAULT 'Draft',
    inspector_id INTEGER REFERENCES user_management.users(id), -- الفاحص (مهندس)

    -- المحتوى
    customer_complaint TEXT,
    observations TEXT,
    recommendations TEXT,

    -- المرفقات
    attachments JSONB, -- array of file objects {url, type, name, size}

    -- التواريخ
    scheduled_date TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,

    -- التحويل إلى أمر عمل
    converted_to_work_order_id INTEGER REFERENCES work_orders.work_orders(id),
    converted_by INTEGER REFERENCES user_management.users(id),
    converted_at TIMESTAMP WITH TIME ZONE,

    -- تتبع التغييرات
    created_by INTEGER NOT NULL REFERENCES user_management.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول عيوب المركبة المكتشفة
CREATE TABLE IF NOT EXISTS work_orders.inspection_faults (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER NOT NULL REFERENCES work_orders.inspections(id) ON DELETE CASCADE,
    fault_category VARCHAR(100) NOT NULL, -- Mechanical, Electrical, Body, etc.
    fault_description TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'Medium', -- Low, Medium, High, Critical
    photos JSONB, -- array of photo URLs
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول الخدمات المقترحة في الفحص
CREATE TABLE IF NOT EXISTS work_orders.inspection_services (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER NOT NULL REFERENCES work_orders.inspections(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES service_catalog.services(id),
    service_name VARCHAR(255) NOT NULL,
    estimated_cost DECIMAL(10,2),
    estimated_duration INTEGER, -- in minutes
    assigned_engineer_id INTEGER REFERENCES user_management.users(id),
    priority priority_enum DEFAULT 'Medium',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول عروض الأسعار
CREATE TABLE IF NOT EXISTS work_orders.quotes (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    quote_number VARCHAR(50) UNIQUE NOT NULL,

    -- المراجع
    inspection_id INTEGER REFERENCES work_orders.inspections(id),
    work_order_id INTEGER REFERENCES work_orders.work_orders(id),
    customer_id INTEGER NOT NULL REFERENCES user_management.users(id),

    -- تفاصيل العرض
    total_amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'YER',
    valid_until TIMESTAMP WITH TIME ZONE,
    notes TEXT,

    -- الحالة والتوقيع
    status VARCHAR(50) DEFAULT 'Draft', -- Draft, Sent, Accepted, Rejected, Expired
    sent_at TIMESTAMP WITH TIME ZONE,
    accepted_at TIMESTAMP WITH TIME ZONE,
    rejected_at TIMESTAMP WITH TIME ZONE,

    -- المستخدمون
    created_by INTEGER NOT NULL REFERENCES user_management.users(id), -- Sales person
    accepted_by INTEGER REFERENCES user_management.users(id),

    -- التوقيتات
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول عناصر عرض السعر
CREATE TABLE IF NOT EXISTS work_orders.quote_items (
    id SERIAL PRIMARY KEY,
    quote_id INTEGER NOT NULL REFERENCES work_orders.quotes(id) ON DELETE CASCADE,
    service_name VARCHAR(255) NOT NULL,
    description TEXT,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    estimated_duration INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول التوقيعات الإلكترونية
CREATE TABLE IF NOT EXISTS work_orders.electronic_signatures (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,

    -- المرجع (عرض سعر أو إيصال تسليم)
    reference_type VARCHAR(50) NOT NULL, -- quote, delivery_receipt
    reference_id INTEGER NOT NULL,

    -- معلومات الموقع
    signer_id INTEGER NOT NULL REFERENCES user_management.users(id),
    signer_name VARCHAR(255) NOT NULL,
    signer_email VARCHAR(255),
    signer_phone VARCHAR(20),

    -- التوقيع
    signature_data TEXT NOT NULL, -- Base64 encoded signature image
    signature_method VARCHAR(50) DEFAULT 'digital', -- digital, typed, drawn
    ip_address INET,
    user_agent TEXT,

    -- الحالة
    status signature_status_enum DEFAULT 'Pending',
    signed_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,

    -- التحقق
    verification_code VARCHAR(100) UNIQUE,
    verified_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS work_orders.notifications (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,

    -- المستلم
    recipient_id INTEGER NOT NULL REFERENCES user_management.users(id),
    recipient_email VARCHAR(255),
    recipient_phone VARCHAR(20),

    -- نوع ومحتوى الإشعار
    notification_type notification_type_enum NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'Normal', -- Low, Normal, High, Urgent

    -- المرجع (اختياري)
    reference_type VARCHAR(50), -- work_order, inspection, quote, etc.
    reference_id INTEGER,

    -- الحالة والتسليم
    status notification_status_enum DEFAULT 'Pending',
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,

    -- بيانات إضافية
    metadata JSONB,
    error_message TEXT,

    -- المرسل
    sent_by INTEGER REFERENCES user_management.users(id),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول مرفقات الملفات العامة
CREATE TABLE IF NOT EXISTS work_orders.file_attachments (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,

    -- المرجع
    reference_type VARCHAR(50) NOT NULL, -- inspection, work_order, quote, message, etc.
    reference_id INTEGER NOT NULL,

    -- معلومات الملف
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    mime_type VARCHAR(100),

    -- الصور المصغرة والمعالجة
    thumbnail_path VARCHAR(500),
    processed_path VARCHAR(500),

    -- التصنيف
    category VARCHAR(50), -- photo, document, video, audio
    tags TEXT[],

    -- الرفع
    uploaded_by INTEGER NOT NULL REFERENCES user_management.users(id),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- الحالة
    is_active BOOLEAN DEFAULT TRUE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- جدول تاريخ حالة الفحص
CREATE TABLE IF NOT EXISTS work_orders.inspection_status_history (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER NOT NULL REFERENCES work_orders.inspections(id) ON DELETE CASCADE,
    old_status inspection_status_enum,
    new_status inspection_status_enum NOT NULL,
    changed_by INTEGER NOT NULL REFERENCES user_management.users(id),
    change_reason TEXT,
    notes TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء الفهارس
CREATE INDEX IF NOT EXISTS idx_inspections_customer_id ON work_orders.inspections(customer_id);
CREATE INDEX IF NOT EXISTS idx_inspections_status ON work_orders.inspections(status);
CREATE INDEX IF NOT EXISTS idx_inspections_inspector_id ON work_orders.inspections(inspector_id);
CREATE INDEX IF NOT EXISTS idx_inspections_created_at ON work_orders.inspections(created_at);

CREATE INDEX IF NOT EXISTS idx_inspection_faults_inspection_id ON work_orders.inspection_faults(inspection_id);
CREATE INDEX IF NOT EXISTS idx_inspection_services_inspection_id ON work_orders.inspection_services(inspection_id);
CREATE INDEX IF NOT EXISTS idx_inspection_services_assigned_engineer_id ON work_orders.inspection_services(assigned_engineer_id);

CREATE INDEX IF NOT EXISTS idx_quotes_customer_id ON work_orders.quotes(customer_id);
CREATE INDEX IF NOT EXISTS idx_quotes_status ON work_orders.quotes(status);
CREATE INDEX IF NOT EXISTS idx_quotes_created_by ON work_orders.quotes(created_by);

CREATE INDEX IF NOT EXISTS idx_electronic_signatures_signer_id ON work_orders.electronic_signatures(signer_id);
CREATE INDEX IF NOT EXISTS idx_electronic_signatures_reference ON work_orders.electronic_signatures(reference_type, reference_id);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient_id ON work_orders.notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON work_orders.notifications(status);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON work_orders.notifications(notification_type);

CREATE INDEX IF NOT EXISTS idx_file_attachments_reference ON work_orders.file_attachments(reference_type, reference_id);
CREATE INDEX IF NOT EXISTS idx_file_attachments_uploaded_by ON work_orders.file_attachments(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_file_attachments_tags ON work_orders.file_attachments USING GIN(tags);

-- إنشاء triggers للتحديث التلقائي
CREATE TRIGGER update_inspections_updated_at
    BEFORE UPDATE ON work_orders.inspections
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quotes_updated_at
    BEFORE UPDATE ON work_orders.quotes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON work_orders.notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- دوال لإنشاء الأرقام التلقائية
CREATE OR REPLACE FUNCTION generate_inspection_number()
RETURNS TEXT AS $$
DECLARE
    new_number TEXT;
    counter INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(inspection_number FROM 9 FOR 6) AS INTEGER)), 0) + 1
    INTO counter
    FROM work_orders.inspections
    WHERE inspection_number LIKE 'INSP-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '%';

    new_number := 'INSP-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(counter::TEXT, 6, '0');
    RETURN new_number;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_quote_number()
RETURNS TEXT AS $$
DECLARE
    new_number TEXT;
    counter INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(quote_number FROM 7 FOR 6) AS INTEGER)), 0) + 1
    INTO counter
    FROM work_orders.quotes
    WHERE quote_number LIKE 'QUOTE-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '%';

    new_number := 'QUOTE-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(counter::TEXT, 6, '0');
    RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- triggers لإنشاء الأرقام التلقائية
CREATE OR REPLACE FUNCTION set_inspection_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.inspection_number IS NULL OR NEW.inspection_number = '' THEN
        NEW.inspection_number := generate_inspection_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_inspection_number_trigger
    BEFORE INSERT ON work_orders.inspections
    FOR EACH ROW
    EXECUTE FUNCTION set_inspection_number();

CREATE OR REPLACE FUNCTION set_quote_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quote_number IS NULL OR NEW.quote_number = '' THEN
        NEW.quote_number := generate_quote_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_quote_number_trigger
    BEFORE INSERT ON work_orders.quotes
    FOR EACH ROW
    EXECUTE FUNCTION set_quote_number();

-- trigger لتسجيل تغييرات حالة الفحص
CREATE OR REPLACE FUNCTION log_inspection_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO work_orders.inspection_status_history (
            inspection_id, old_status, new_status, changed_by, change_reason
        ) VALUES (
            NEW.id, OLD.status, NEW.status, NEW.updated_by, 'Status changed'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إضافة عمود updated_by للفحوصات
ALTER TABLE work_orders.inspections ADD COLUMN IF NOT EXISTS updated_by INTEGER REFERENCES user_management.users(id);

-- منح الصلاحيات
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA work_orders TO yaman_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA work_orders TO yaman_user;

-- إدراج بيانات تجريبية لأنواع المركبات
INSERT INTO work_orders.vehicle_types (make, model, year, trim_level, engine_type, transmission, fuel_type) VALUES
('Toyota', 'Corolla', 2020, 'LE', '1.8L 4-Cylinder', 'Automatic', 'Gasoline'),
('Honda', 'Civic', 2019, 'EX', '2.0L 4-Cylinder', 'Manual', 'Gasoline'),
('Ford', 'F-150', 2021, 'Lariat', '3.5L V6', 'Automatic', 'Gasoline'),
('Chevrolet', 'Silverado', 2020, 'Work Truck', '5.3L V8', 'Automatic', 'Gasoline'),
('BMW', '3 Series', 2018, '330i', '2.0L Turbo', 'Automatic', 'Gasoline'),
('Mercedes-Benz', 'C-Class', 2019, 'C300', '2.0L Turbo', 'Automatic', 'Gasoline')
ON CONFLICT DO NOTHING;

-- إظهار رسالة نجاح
DO $$
BEGIN
    RAISE NOTICE 'تم إعداد جداول سير العمل بنجاح - Workflow tables setup completed successfully';
END $$;
-- إعداد جداول أوامر العمل
-- Work Orders Tables Setup

-- جدول أوامر العمل الرئيسي
CREATE TABLE IF NOT EXISTS work_orders.work_orders (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES user_management.users(id),
    assigned_to INTEGER REFERENCES user_management.users(id),
    created_by INTEGER NOT NULL REFERENCES user_management.users(id),
    
    -- معلومات المركبة
    vehicle_make VARCHAR(100),
    vehicle_model VARCHAR(100),
    vehicle_year INTEGER,
    vehicle_vin VARCHAR(50),
    vehicle_license_plate VARCHAR(20),
    vehicle_mileage INTEGER,
    vehicle_color VARCHAR(50),
    
    -- تفاصيل الطلب
    title VARCHAR(255) NOT NULL,
    description TEXT,
    customer_complaint TEXT,
    diagnosis TEXT,
    
    -- الحالة والأولوية
    status work_order_status_enum DEFAULT 'Draft',
    priority priority_enum DEFAULT 'Medium',
    
    -- التواريخ والأوقات
    scheduled_date TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    estimated_completion TIMESTAMP WITH TIME ZONE,
    
    -- المعلومات المالية
    estimated_cost DECIMAL(12,2) DEFAULT 0.00,
    actual_cost DECIMAL(12,2) DEFAULT 0.00,
    labor_cost DECIMAL(12,2) DEFAULT 0.00,
    parts_cost DECIMAL(12,2) DEFAULT 0.00,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'YER',
    
    -- معلومات إضافية
    notes TEXT,
    internal_notes TEXT,
    attachments JSONB, -- array of file URLs
    tags TEXT[],
    
    -- تتبع التغييرات
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- معلومات الإغلاق
    closed_by INTEGER REFERENCES user_management.users(id),
    closed_at TIMESTAMP WITH TIME ZONE,
    closure_reason TEXT
);

-- جدول خدمات أمر العمل
CREATE TABLE IF NOT EXISTS work_orders.work_order_services (
    id SERIAL PRIMARY KEY,
    work_order_id INTEGER NOT NULL REFERENCES work_orders.work_orders(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES service_catalog.services(id),
    service_name VARCHAR(255) NOT NULL, -- in case service is deleted
    service_description TEXT,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    estimated_duration INTEGER, -- in minutes
    actual_duration INTEGER, -- in minutes
    status VARCHAR(50) DEFAULT 'Pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول قطع الغيار المستخدمة
CREATE TABLE IF NOT EXISTS work_orders.work_order_parts (
    id SERIAL PRIMARY KEY,
    work_order_id INTEGER NOT NULL REFERENCES work_orders.work_orders(id) ON DELETE CASCADE,
    part_number VARCHAR(100),
    part_name VARCHAR(255) NOT NULL,
    part_description TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_cost DECIMAL(10,2) NOT NULL,
    total_cost DECIMAL(10,2) NOT NULL,
    supplier VARCHAR(255),
    warranty_period INTEGER, -- in days
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول مهام أمر العمل
CREATE TABLE IF NOT EXISTS work_orders.work_order_tasks (
    id SERIAL PRIMARY KEY,
    work_order_id INTEGER NOT NULL REFERENCES work_orders.work_orders(id) ON DELETE CASCADE,
    task_name VARCHAR(255) NOT NULL,
    task_description TEXT,
    assigned_to INTEGER REFERENCES user_management.users(id),
    status VARCHAR(50) DEFAULT 'Pending',
    priority priority_enum DEFAULT 'Medium',
    estimated_duration INTEGER, -- in minutes
    actual_duration INTEGER, -- in minutes
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول تاريخ حالة أمر العمل
CREATE TABLE IF NOT EXISTS work_orders.work_order_status_history (
    id SERIAL PRIMARY KEY,
    work_order_id INTEGER NOT NULL REFERENCES work_orders.work_orders(id) ON DELETE CASCADE,
    old_status work_order_status_enum,
    new_status work_order_status_enum NOT NULL,
    changed_by INTEGER NOT NULL REFERENCES user_management.users(id),
    change_reason TEXT,
    notes TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول تعليقات أمر العمل
CREATE TABLE IF NOT EXISTS work_orders.work_order_comments (
    id SERIAL PRIMARY KEY,
    work_order_id INTEGER NOT NULL REFERENCES work_orders.work_orders(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES user_management.users(id),
    comment TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT FALSE, -- internal comments not visible to customer
    attachments JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول صور أمر العمل
CREATE TABLE IF NOT EXISTS work_orders.work_order_images (
    id SERIAL PRIMARY KEY,
    work_order_id INTEGER NOT NULL REFERENCES work_orders.work_orders(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    image_type VARCHAR(50), -- before, during, after, damage, etc.
    caption TEXT,
    uploaded_by INTEGER NOT NULL REFERENCES user_management.users(id),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء الفهارس
CREATE INDEX IF NOT EXISTS idx_work_orders_order_number ON work_orders.work_orders(order_number);
CREATE INDEX IF NOT EXISTS idx_work_orders_customer_id ON work_orders.work_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_work_orders_assigned_to ON work_orders.work_orders(assigned_to);
CREATE INDEX IF NOT EXISTS idx_work_orders_status ON work_orders.work_orders(status);
CREATE INDEX IF NOT EXISTS idx_work_orders_priority ON work_orders.work_orders(priority);
CREATE INDEX IF NOT EXISTS idx_work_orders_scheduled_date ON work_orders.work_orders(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_work_orders_created_at ON work_orders.work_orders(created_at);
CREATE INDEX IF NOT EXISTS idx_work_orders_tags ON work_orders.work_orders USING GIN(tags);

CREATE INDEX IF NOT EXISTS idx_work_order_services_work_order_id ON work_orders.work_order_services(work_order_id);
CREATE INDEX IF NOT EXISTS idx_work_order_parts_work_order_id ON work_orders.work_order_parts(work_order_id);
CREATE INDEX IF NOT EXISTS idx_work_order_tasks_work_order_id ON work_orders.work_order_tasks(work_order_id);
CREATE INDEX IF NOT EXISTS idx_work_order_tasks_assigned_to ON work_orders.work_order_tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_work_order_status_history_work_order_id ON work_orders.work_order_status_history(work_order_id);
CREATE INDEX IF NOT EXISTS idx_work_order_comments_work_order_id ON work_orders.work_order_comments(work_order_id);
CREATE INDEX IF NOT EXISTS idx_work_order_images_work_order_id ON work_orders.work_order_images(work_order_id);

-- إنشاء triggers لتحديث updated_at
CREATE TRIGGER update_work_orders_updated_at
    BEFORE UPDATE ON work_orders.work_orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_work_order_tasks_updated_at
    BEFORE UPDATE ON work_orders.work_order_tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_work_order_comments_updated_at
    BEFORE UPDATE ON work_orders.work_order_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- دالة لإنشاء رقم أمر العمل
CREATE OR REPLACE FUNCTION generate_work_order_number()
RETURNS TEXT AS $$
DECLARE
    new_number TEXT;
    counter INTEGER;
BEGIN
    -- Get the current year and month
    SELECT COALESCE(MAX(CAST(SUBSTRING(order_number FROM 8 FOR 6) AS INTEGER)), 0) + 1
    INTO counter
    FROM work_orders.work_orders
    WHERE order_number LIKE 'WO-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '%';
    
    -- Format: WO-YYYY-NNNNNN
    new_number := 'WO-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(counter::TEXT, 6, '0');
    
    RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- trigger لإنشاء رقم أمر العمل تلقائياً
CREATE OR REPLACE FUNCTION set_work_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        NEW.order_number := generate_work_order_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_work_order_number_trigger
    BEFORE INSERT ON work_orders.work_orders
    FOR EACH ROW
    EXECUTE FUNCTION set_work_order_number();

-- trigger لتسجيل تغييرات الحالة
CREATE OR REPLACE FUNCTION log_work_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO work_orders.work_order_status_history (
            work_order_id, old_status, new_status, changed_by, change_reason
        ) VALUES (
            NEW.id, OLD.status, NEW.status, NEW.updated_by, 'Status changed'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إضافة عمود updated_by لتتبع من قام بالتحديث
ALTER TABLE work_orders.work_orders ADD COLUMN IF NOT EXISTS updated_by INTEGER REFERENCES user_management.users(id);

-- منح الصلاحيات
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA work_orders TO yaman_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA work_orders TO yaman_user;

-- إظهار رسالة نجاح
DO $$
BEGIN
    RAISE NOTICE 'تم إعداد جداول أوامر العمل بنجاح - Work orders tables setup completed successfully';
END $$;

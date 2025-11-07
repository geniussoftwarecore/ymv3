-- إعداد جداول نظام الدردشة
-- Chat System Tables Setup

-- جدول غرف الدردشة
CREATE TABLE IF NOT EXISTS chat_system.chat_rooms (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    room_type VARCHAR(50) DEFAULT 'private', -- private, group, support, work_order
    is_active BOOLEAN DEFAULT TRUE,
    max_participants INTEGER DEFAULT 10,
    work_order_id INTEGER REFERENCES work_orders.work_orders(id),
    created_by INTEGER NOT NULL REFERENCES user_management.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول المشاركين في غرف الدردشة
CREATE TABLE IF NOT EXISTS chat_system.chat_participants (
    id SERIAL PRIMARY KEY,
    room_id INTEGER NOT NULL REFERENCES chat_system.chat_rooms(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES user_management.users(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'member', -- admin, moderator, member
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(room_id, user_id)
);

-- جدول الرسائل
CREATE TABLE IF NOT EXISTS chat_system.messages (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    room_id INTEGER NOT NULL REFERENCES chat_system.chat_rooms(id) ON DELETE CASCADE,
    sender_id INTEGER NOT NULL REFERENCES user_management.users(id),
    parent_message_id INTEGER REFERENCES chat_system.messages(id), -- for replies
    
    -- محتوى الرسالة
    message_text TEXT,
    message_type VARCHAR(50) DEFAULT 'text', -- text, image, file, system, location
    
    -- المرفقات
    attachments JSONB, -- array of attachment objects
    
    -- معلومات إضافية
    metadata JSONB, -- additional message metadata
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- التوقيتات
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول حالة قراءة الرسائل
CREATE TABLE IF NOT EXISTS chat_system.message_read_status (
    id SERIAL PRIMARY KEY,
    message_id INTEGER NOT NULL REFERENCES chat_system.messages(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES user_management.users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id)
);

-- جدول المرفقات
CREATE TABLE IF NOT EXISTS chat_system.message_attachments (
    id SERIAL PRIMARY KEY,
    message_id INTEGER NOT NULL REFERENCES chat_system.messages(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    mime_type VARCHAR(100),
    thumbnail_path VARCHAR(500),
    uploaded_by INTEGER NOT NULL REFERENCES user_management.users(id),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول ردود الفعل على الرسائل
CREATE TABLE IF NOT EXISTS chat_system.message_reactions (
    id SERIAL PRIMARY KEY,
    message_id INTEGER NOT NULL REFERENCES chat_system.messages(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES user_management.users(id) ON DELETE CASCADE,
    reaction_type VARCHAR(50) NOT NULL, -- like, love, laugh, angry, sad, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id, reaction_type)
);

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS chat_system.notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES user_management.users(id) ON DELETE CASCADE,
    room_id INTEGER REFERENCES chat_system.chat_rooms(id) ON DELETE CASCADE,
    message_id INTEGER REFERENCES chat_system.messages(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL, -- new_message, mention, room_invite, etc.
    title VARCHAR(255) NOT NULL,
    content TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول الرسائل المحذوفة (للأرشفة)
CREATE TABLE IF NOT EXISTS chat_system.deleted_messages (
    id SERIAL PRIMARY KEY,
    original_message_id INTEGER NOT NULL,
    room_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    message_text TEXT,
    message_type VARCHAR(50),
    attachments JSONB,
    deleted_by INTEGER NOT NULL REFERENCES user_management.users(id),
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deletion_reason TEXT
);

-- إنشاء الفهارس
CREATE INDEX IF NOT EXISTS idx_chat_rooms_type ON chat_system.chat_rooms(room_type);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_work_order_id ON chat_system.chat_rooms(work_order_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_created_by ON chat_system.chat_rooms(created_by);

CREATE INDEX IF NOT EXISTS idx_chat_participants_room_id ON chat_system.chat_participants(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_user_id ON chat_system.chat_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_active ON chat_system.chat_participants(is_active);

CREATE INDEX IF NOT EXISTS idx_messages_room_id ON chat_system.messages(room_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON chat_system.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON chat_system.messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_parent_id ON chat_system.messages(parent_message_id);
CREATE INDEX IF NOT EXISTS idx_messages_type ON chat_system.messages(message_type);

CREATE INDEX IF NOT EXISTS idx_message_read_status_message_id ON chat_system.message_read_status(message_id);
CREATE INDEX IF NOT EXISTS idx_message_read_status_user_id ON chat_system.message_read_status(user_id);

CREATE INDEX IF NOT EXISTS idx_message_attachments_message_id ON chat_system.message_attachments(message_id);

CREATE INDEX IF NOT EXISTS idx_message_reactions_message_id ON chat_system.message_reactions(message_id);
CREATE INDEX IF NOT EXISTS idx_message_reactions_user_id ON chat_system.message_reactions(user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON chat_system.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON chat_system.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON chat_system.notifications(created_at);

-- إنشاء triggers لتحديث updated_at
CREATE TRIGGER update_chat_rooms_updated_at
    BEFORE UPDATE ON chat_system.chat_rooms
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at
    BEFORE UPDATE ON chat_system.messages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- دالة لإنشاء غرفة دردشة لأمر العمل
CREATE OR REPLACE FUNCTION create_work_order_chat_room()
RETURNS TRIGGER AS $$
DECLARE
    room_id INTEGER;
BEGIN
    -- إنشاء غرفة دردشة لأمر العمل الجديد
    INSERT INTO chat_system.chat_rooms (
        name, 
        description, 
        room_type, 
        work_order_id, 
        created_by
    ) VALUES (
        'Work Order #' || NEW.order_number,
        'Chat room for work order: ' || NEW.title,
        'work_order',
        NEW.id,
        NEW.created_by
    ) RETURNING id INTO room_id;
    
    -- إضافة العميل كمشارك
    INSERT INTO chat_system.chat_participants (room_id, user_id, role)
    VALUES (room_id, NEW.customer_id, 'member');
    
    -- إضافة منشئ أمر العمل كمشارك
    INSERT INTO chat_system.chat_participants (room_id, user_id, role)
    VALUES (room_id, NEW.created_by, 'admin');
    
    -- إضافة المُكلف بالعمل إذا كان موجوداً
    IF NEW.assigned_to IS NOT NULL THEN
        INSERT INTO chat_system.chat_participants (room_id, user_id, role)
        VALUES (room_id, NEW.assigned_to, 'moderator');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger لإنشاء غرفة دردشة عند إنشاء أمر عمل جديد
CREATE TRIGGER create_work_order_chat_trigger
    AFTER INSERT ON work_orders.work_orders
    FOR EACH ROW
    EXECUTE FUNCTION create_work_order_chat_room();

-- دالة لتحديث آخر قراءة للمشارك
CREATE OR REPLACE FUNCTION update_participant_last_read()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chat_system.chat_participants
    SET last_read_at = CURRENT_TIMESTAMP
    WHERE room_id = NEW.room_id 
    AND user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger لتحديث آخر قراءة عند قراءة رسالة
CREATE TRIGGER update_last_read_trigger
    AFTER INSERT ON chat_system.message_read_status
    FOR EACH ROW
    EXECUTE FUNCTION update_participant_last_read();

-- دالة لأرشفة الرسائل المحذوفة
CREATE OR REPLACE FUNCTION archive_deleted_message()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE THEN
        INSERT INTO chat_system.deleted_messages (
            original_message_id,
            room_id,
            sender_id,
            message_text,
            message_type,
            attachments,
            deleted_by,
            deletion_reason
        ) VALUES (
            OLD.id,
            OLD.room_id,
            OLD.sender_id,
            OLD.message_text,
            OLD.message_type,
            OLD.attachments,
            NEW.sender_id, -- assuming the sender is deleting their own message
            'Message deleted by user'
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger لأرشفة الرسائل المحذوفة
CREATE TRIGGER archive_deleted_message_trigger
    AFTER UPDATE ON chat_system.messages
    FOR EACH ROW
    EXECUTE FUNCTION archive_deleted_message();

-- منح الصلاحيات
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA chat_system TO yaman_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA chat_system TO yaman_user;

-- إظهار رسالة نجاح
DO $$
BEGIN
    RAISE NOTICE 'تم إعداد جداول نظام الدردشة بنجاح - Chat system tables setup completed successfully';
END $$;

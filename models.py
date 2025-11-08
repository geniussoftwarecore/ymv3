"""
Unified ORM Models for Yaman Workshop Management System
These models map to the PostgreSQL database schemas created in database initialization
"""
from sqlalchemy import (
    Boolean, Column, Integer, String, DateTime, Text, Enum as SQLEnum,
    ForeignKey, DECIMAL, ARRAY, TIMESTAMP, BigInteger
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import UUID, JSONB, INET, ENUM
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
import enum
import uuid as uuid_pkg

Base = declarative_base()

user_role_enum = ENUM('Admin', 'Supervisor', 'Engineer', 'Sales', 'Customer', name='user_role_enum', create_type=False)
user_status_enum = ENUM('Active', 'Inactive', 'Suspended', 'Pending', name='user_status_enum', create_type=False)
work_order_status_enum = ENUM('Draft', 'Pending', 'In_Progress', 'On_Hold', 'Completed', 'Cancelled', name='work_order_status_enum', create_type=False)
priority_enum = ENUM('Low', 'Medium', 'High', 'Critical', name='priority_enum', create_type=False)
service_status_enum = ENUM('Available', 'Unavailable', 'Discontinued', name='service_status_enum', create_type=False)


class UserRole(str, enum.Enum):
    ADMIN = "Admin"
    SUPERVISOR = "Supervisor"
    ENGINEER = "Engineer"
    SALES = "Sales"
    CUSTOMER = "Customer"


class UserStatus(str, enum.Enum):
    ACTIVE = "Active"
    INACTIVE = "Inactive"
    SUSPENDED = "Suspended"
    PENDING = "Pending"


class WorkOrderStatus(str, enum.Enum):
    DRAFT = "Draft"
    PENDING = "Pending"
    IN_PROGRESS = "In_Progress"
    ON_HOLD = "On_Hold"
    COMPLETED = "Completed"
    CANCELLED = "Cancelled"


class Priority(str, enum.Enum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"
    CRITICAL = "Critical"


class ServiceStatus(str, enum.Enum):
    AVAILABLE = "Available"
    UNAVAILABLE = "Unavailable"
    DISCONTINUED = "Discontinued"


class User(Base):
    __tablename__ = "users"
    __table_args__ = {'schema': 'user_management'}

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid_pkg.uuid4, unique=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    username = Column(String(100), unique=True, index=True, nullable=False)
    full_name = Column(String(255), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    phone = Column(String(20), nullable=True)
    address = Column(Text, nullable=True)
    role = Column(user_role_enum, default='Customer', nullable=False)
    status = Column(user_status_enum, default='Pending', nullable=False)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    profile_image = Column(String(500), nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    last_login = Column(TIMESTAMP(timezone=True), nullable=True)


class UserSession(Base):
    __tablename__ = "user_sessions"
    __table_args__ = {'schema': 'user_management'}

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('user_management.users.id', ondelete='CASCADE'), nullable=False, index=True)
    token = Column(String(500), nullable=False, unique=True, index=True)
    refresh_token = Column(String(500), nullable=True)
    expires_at = Column(TIMESTAMP(timezone=True), nullable=False, index=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    is_active = Column(Boolean, default=True)
    ip_address = Column(INET, nullable=True)
    user_agent = Column(Text, nullable=True)
    device_info = Column(Text, nullable=True)


class ServiceCategory(Base):
    __tablename__ = "service_categories"
    __table_args__ = {'schema': 'service_catalog'}

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid_pkg.uuid4, unique=True, nullable=False)
    name = Column(String(255), nullable=False, index=True)
    name_ar = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    description_ar = Column(Text, nullable=True)
    icon = Column(String(255), nullable=True)
    color = Column(String(7), nullable=True)
    is_active = Column(Boolean, default=True, index=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())


class Service(Base):
    __tablename__ = "services"
    __table_args__ = {'schema': 'service_catalog'}

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid_pkg.uuid4, unique=True, nullable=False)
    category_id = Column(Integer, ForeignKey('service_catalog.service_categories.id'), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    name_ar = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    description_ar = Column(Text, nullable=True)
    service_code = Column(String(50), unique=True, nullable=False, index=True)
    base_price = Column(DECIMAL(10, 2), default=0.00)
    currency = Column(String(3), default='YER')
    estimated_duration = Column(Integer, nullable=True)
    status = Column(service_status_enum, default='Available', index=True)
    is_featured = Column(Boolean, default=False, index=True)
    images = Column(JSONB, nullable=True)
    specifications = Column(JSONB, nullable=True)
    requirements = Column(JSONB, nullable=True)
    tags = Column(ARRAY(Text), nullable=True)
    created_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())


class ServicePricing(Base):
    __tablename__ = "service_pricing"
    __table_args__ = {'schema': 'service_catalog'}

    id = Column(Integer, primary_key=True, index=True)
    service_id = Column(Integer, ForeignKey('service_catalog.services.id', ondelete='CASCADE'), nullable=False, index=True)
    tier_name = Column(String(100), nullable=False)
    tier_name_ar = Column(String(100), nullable=False)
    min_quantity = Column(Integer, default=1)
    max_quantity = Column(Integer, nullable=True)
    price = Column(DECIMAL(10, 2), nullable=False)
    currency = Column(String(3), default='YER')
    is_active = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class ServiceSpecification(Base):
    __tablename__ = "service_specifications"
    __table_args__ = {'schema': 'service_catalog'}

    id = Column(Integer, primary_key=True, index=True)
    service_id = Column(Integer, ForeignKey('service_catalog.services.id', ondelete='CASCADE'), nullable=False, index=True)
    spec_name = Column(String(255), nullable=False)
    spec_name_ar = Column(String(255), nullable=False)
    spec_value = Column(Text, nullable=False)
    spec_value_ar = Column(Text, nullable=True)
    spec_type = Column(String(50), default='text')
    is_required = Column(Boolean, default=False)
    sort_order = Column(Integer, default=0)


class WorkOrder(Base):
    __tablename__ = "work_orders"
    __table_args__ = {'schema': 'work_orders'}

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid_pkg.uuid4, unique=True, nullable=False)
    order_number = Column(String(50), unique=True, nullable=False, index=True)
    customer_id = Column(Integer, ForeignKey('user_management.users.id'), nullable=False, index=True)
    assigned_to = Column(Integer, ForeignKey('user_management.users.id'), nullable=True, index=True)
    created_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=False)
    
    vehicle_make = Column(String(100), nullable=True)
    vehicle_model = Column(String(100), nullable=True)
    vehicle_year = Column(Integer, nullable=True)
    vehicle_vin = Column(String(50), nullable=True)
    vehicle_license_plate = Column(String(20), nullable=True)
    vehicle_mileage = Column(Integer, nullable=True)
    vehicle_color = Column(String(50), nullable=True)
    
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    customer_complaint = Column(Text, nullable=True)
    diagnosis = Column(Text, nullable=True)
    
    status = Column(work_order_status_enum, default='Draft', index=True)
    priority = Column(priority_enum, default='Medium', index=True)
    
    scheduled_date = Column(TIMESTAMP(timezone=True), nullable=True, index=True)
    started_at = Column(TIMESTAMP(timezone=True), nullable=True)
    completed_at = Column(TIMESTAMP(timezone=True), nullable=True)
    estimated_completion = Column(TIMESTAMP(timezone=True), nullable=True)
    
    estimated_cost = Column(DECIMAL(12, 2), default=0.00)
    actual_cost = Column(DECIMAL(12, 2), default=0.00)
    labor_cost = Column(DECIMAL(12, 2), default=0.00)
    parts_cost = Column(DECIMAL(12, 2), default=0.00)
    tax_amount = Column(DECIMAL(12, 2), default=0.00)
    discount_amount = Column(DECIMAL(12, 2), default=0.00)
    total_amount = Column(DECIMAL(12, 2), default=0.00)
    currency = Column(String(3), default='YER')
    
    notes = Column(Text, nullable=True)
    internal_notes = Column(Text, nullable=True)
    attachments = Column(JSONB, nullable=True)
    tags = Column(ARRAY(Text), nullable=True)
    
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    updated_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=True)
    
    closed_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=True)
    closed_at = Column(TIMESTAMP(timezone=True), nullable=True)
    closure_reason = Column(Text, nullable=True)


class WorkOrderService(Base):
    __tablename__ = "work_order_services"
    __table_args__ = {'schema': 'work_orders'}

    id = Column(Integer, primary_key=True, index=True)
    work_order_id = Column(Integer, ForeignKey('work_orders.work_orders.id', ondelete='CASCADE'), nullable=False, index=True)
    service_id = Column(Integer, ForeignKey('service_catalog.services.id'), nullable=True)
    service_name = Column(String(255), nullable=False)
    service_description = Column(Text, nullable=True)
    quantity = Column(Integer, default=1)
    unit_price = Column(DECIMAL(10, 2), nullable=False)
    total_price = Column(DECIMAL(10, 2), nullable=False)
    estimated_duration = Column(Integer, nullable=True)
    actual_duration = Column(Integer, nullable=True)
    status = Column(String(50), default='Pending')
    notes = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class WorkOrderPart(Base):
    __tablename__ = "work_order_parts"
    __table_args__ = {'schema': 'work_orders'}

    id = Column(Integer, primary_key=True, index=True)
    work_order_id = Column(Integer, ForeignKey('work_orders.work_orders.id', ondelete='CASCADE'), nullable=False, index=True)
    part_number = Column(String(100), nullable=True)
    part_name = Column(String(255), nullable=False)
    part_description = Column(Text, nullable=True)
    quantity = Column(Integer, nullable=False, default=1)
    unit_cost = Column(DECIMAL(10, 2), nullable=False)
    total_cost = Column(DECIMAL(10, 2), nullable=False)
    supplier = Column(String(255), nullable=True)
    warranty_period = Column(Integer, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class WorkOrderTask(Base):
    __tablename__ = "work_order_tasks"
    __table_args__ = {'schema': 'work_orders'}

    id = Column(Integer, primary_key=True, index=True)
    work_order_id = Column(Integer, ForeignKey('work_orders.work_orders.id', ondelete='CASCADE'), nullable=False, index=True)
    task_name = Column(String(255), nullable=False)
    task_description = Column(Text, nullable=True)
    assigned_to = Column(Integer, ForeignKey('user_management.users.id'), nullable=True, index=True)
    status = Column(String(50), default='Pending')
    priority = Column(priority_enum, default='Medium')
    estimated_duration = Column(Integer, nullable=True)
    actual_duration = Column(Integer, nullable=True)
    started_at = Column(TIMESTAMP(timezone=True), nullable=True)
    completed_at = Column(TIMESTAMP(timezone=True), nullable=True)
    notes = Column(Text, nullable=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())


class WorkOrderStatusHistory(Base):
    __tablename__ = "work_order_status_history"
    __table_args__ = {'schema': 'work_orders'}

    id = Column(Integer, primary_key=True, index=True)
    work_order_id = Column(Integer, ForeignKey('work_orders.work_orders.id', ondelete='CASCADE'), nullable=False, index=True)
    old_status = Column(work_order_status_enum, nullable=True)
    new_status = Column(work_order_status_enum, nullable=False)
    changed_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=False)
    change_reason = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    changed_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class WorkOrderComment(Base):
    __tablename__ = "work_order_comments"
    __table_args__ = {'schema': 'work_orders'}

    id = Column(Integer, primary_key=True, index=True)
    work_order_id = Column(Integer, ForeignKey('work_orders.work_orders.id', ondelete='CASCADE'), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey('user_management.users.id'), nullable=False)
    comment = Column(Text, nullable=False)
    is_internal = Column(Boolean, default=False)
    attachments = Column(JSONB, nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())


class WorkOrderImage(Base):
    __tablename__ = "work_order_images"
    __table_args__ = {'schema': 'work_orders'}

    id = Column(Integer, primary_key=True, index=True)
    work_order_id = Column(Integer, ForeignKey('work_orders.work_orders.id', ondelete='CASCADE'), nullable=False, index=True)
    image_url = Column(String(500), nullable=False)
    image_type = Column(String(50), nullable=True)
    caption = Column(Text, nullable=True)
    uploaded_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=False)
    uploaded_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class ChatRoom(Base):
    __tablename__ = "chat_rooms"
    __table_args__ = {'schema': 'chat_system'}

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid_pkg.uuid4, unique=True, nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    room_type = Column(String(50), default='private', index=True)
    is_active = Column(Boolean, default=True)
    max_participants = Column(Integer, default=10)
    work_order_id = Column(Integer, ForeignKey('work_orders.work_orders.id'), nullable=True, index=True)
    created_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=False, index=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())


class ChatParticipant(Base):
    __tablename__ = "chat_participants"
    __table_args__ = {'schema': 'chat_system'}

    id = Column(Integer, primary_key=True, index=True)
    room_id = Column(Integer, ForeignKey('chat_system.chat_rooms.id', ondelete='CASCADE'), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey('user_management.users.id', ondelete='CASCADE'), nullable=False, index=True)
    role = Column(String(50), default='member')
    joined_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    left_at = Column(TIMESTAMP(timezone=True), nullable=True)
    is_active = Column(Boolean, default=True)
    notifications_enabled = Column(Boolean, default=True)
    last_read_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class Message(Base):
    __tablename__ = "messages"
    __table_args__ = {'schema': 'chat_system'}

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid_pkg.uuid4, unique=True, nullable=False)
    room_id = Column(Integer, ForeignKey('chat_system.chat_rooms.id', ondelete='CASCADE'), nullable=False, index=True)
    sender_id = Column(Integer, ForeignKey('user_management.users.id'), nullable=False, index=True)
    parent_message_id = Column(Integer, ForeignKey('chat_system.messages.id'), nullable=True)
    message_text = Column(Text, nullable=True)
    message_type = Column(String(50), default='text')
    attachments = Column(JSONB, nullable=True)
    message_metadata = Column(JSONB, nullable=True)
    is_edited = Column(Boolean, default=False)
    is_deleted = Column(Boolean, default=False)
    deleted_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=True)
    edited_at = Column(TIMESTAMP(timezone=True), nullable=True)
    deleted_at = Column(TIMESTAMP(timezone=True), nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())


class MessageReadStatus(Base):
    __tablename__ = "message_read_status"
    __table_args__ = {'schema': 'chat_system'}

    id = Column(Integer, primary_key=True, index=True)
    message_id = Column(Integer, ForeignKey('chat_system.messages.id', ondelete='CASCADE'), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey('user_management.users.id', ondelete='CASCADE'), nullable=False, index=True)
    read_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class MessageAttachment(Base):
    __tablename__ = "message_attachments"
    __table_args__ = {'schema': 'chat_system'}

    id = Column(Integer, primary_key=True, index=True)
    message_id = Column(Integer, ForeignKey('chat_system.messages.id', ondelete='CASCADE'), nullable=False, index=True)
    file_name = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=False)
    file_type = Column(String(100), nullable=True)
    file_size = Column(BigInteger, nullable=True)
    mime_type = Column(String(100), nullable=True)
    thumbnail_path = Column(String(500), nullable=True)
    uploaded_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=False)
    uploaded_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class MessageReaction(Base):
    __tablename__ = "message_reactions"
    __table_args__ = {'schema': 'chat_system'}

    id = Column(Integer, primary_key=True, index=True)
    message_id = Column(Integer, ForeignKey('chat_system.messages.id', ondelete='CASCADE'), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey('user_management.users.id', ondelete='CASCADE'), nullable=False, index=True)
    reaction_type = Column(String(50), nullable=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class Notification(Base):
    __tablename__ = "notifications"
    __table_args__ = {'schema': 'chat_system'}

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('user_management.users.id', ondelete='CASCADE'), nullable=False, index=True)
    room_id = Column(Integer, ForeignKey('chat_system.chat_rooms.id', ondelete='CASCADE'), nullable=True)
    message_id = Column(Integer, ForeignKey('chat_system.messages.id', ondelete='CASCADE'), nullable=True)
    notification_type = Column(String(50), nullable=False)
    title = Column(String(255), nullable=False)
    content = Column(Text, nullable=True)
    is_read = Column(Boolean, default=False, index=True)
    read_at = Column(TIMESTAMP(timezone=True), nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class DeletedMessage(Base):
    __tablename__ = "deleted_messages"
    __table_args__ = {'schema': 'chat_system'}

    id = Column(Integer, primary_key=True, index=True)
    original_message_id = Column(Integer, nullable=False)
    room_id = Column(Integer, nullable=False)
    sender_id = Column(Integer, nullable=False)
    message_text = Column(Text, nullable=True)
    message_type = Column(String(50), nullable=True)
    attachments = Column(JSONB, nullable=True)
    deleted_by = Column(Integer, ForeignKey('user_management.users.id'), nullable=False)
    deleted_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    deletion_reason = Column(Text, nullable=True)


class AuditTrail(Base):
    __tablename__ = "audit_trail"
    __table_args__ = {'schema': 'audit_logs'}

    id = Column(Integer, primary_key=True, index=True)
    table_name = Column(String(100), nullable=False, index=True)
    operation = Column(String(20), nullable=False, index=True)
    record_id = Column(Integer, nullable=True)
    old_values = Column(JSONB, nullable=True)
    new_values = Column(JSONB, nullable=True)
    user_id = Column(Integer, nullable=True, index=True)
    timestamp = Column(TIMESTAMP(timezone=True), server_default=func.now(), index=True)
    ip_address = Column(INET, nullable=True)
    user_agent = Column(Text, nullable=True)

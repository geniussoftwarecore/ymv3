from fastapi import FastAPI, HTTPException, Depends, Query, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from enum import Enum
import asyncpg
import json
import uuid
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Work Order Management Service", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database connection
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://yaman_user:yaman_password@localhost:5432/yaman_workshop_db")

class InspectionType(str, Enum):
    STANDARD = "Standard"
    CUSTOM = "Custom"

class InspectionStatus(str, Enum):
    DRAFT = "Draft"
    IN_PROGRESS = "In_Progress"
    COMPLETED = "Completed"
    CONVERTED_TO_WORK_ORDER = "Converted_to_Work_Order"

class Priority(str, Enum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"
    CRITICAL = "Critical"

# Pydantic Models
class VehicleTypeBase(BaseModel):
    make: str
    model: str
    year: Optional[int] = None
    trim_level: Optional[str] = None
    engine_type: Optional[str] = None
    transmission: Optional[str] = None
    fuel_type: Optional[str] = None

class VehicleTypeCreate(VehicleTypeBase):
    pass

class VehicleType(VehicleTypeBase):
    id: int
    uuid: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

class InspectionFaultBase(BaseModel):
    fault_category: str
    fault_description: str
    severity: str = "Medium"
    photos: Optional[List[Dict[str, Any]]] = None
    notes: Optional[str] = None

class InspectionServiceBase(BaseModel):
    service_id: Optional[int] = None
    service_name: str
    estimated_cost: Optional[float] = None
    estimated_duration: Optional[int] = None
    assigned_engineer_id: Optional[int] = None
    priority: Priority = Priority.MEDIUM
    notes: Optional[str] = None

class InspectionBase(BaseModel):
    customer_id: int
    vehicle_type_id: Optional[int] = None
    vehicle_make: Optional[str] = None
    vehicle_model: Optional[str] = None
    vehicle_year: Optional[int] = None
    vehicle_vin: Optional[str] = None
    vehicle_license_plate: Optional[str] = None
    vehicle_mileage: Optional[int] = None
    vehicle_color: Optional[str] = None
    vehicle_trim: Optional[str] = None
    inspection_type: InspectionType = InspectionType.STANDARD
    customer_complaint: Optional[str] = None
    observations: Optional[str] = None
    recommendations: Optional[str] = None
    attachments: Optional[List[Dict[str, Any]]] = None
    scheduled_date: Optional[datetime] = None

class InspectionCreate(InspectionBase):
    created_by: int

class InspectionUpdate(BaseModel):
    status: Optional[InspectionStatus] = None
    inspector_id: Optional[int] = None
    customer_complaint: Optional[str] = None
    observations: Optional[str] = None
    recommendations: Optional[str] = None
    attachments: Optional[List[Dict[str, Any]]] = None
    scheduled_date: Optional[datetime] = None
    updated_by: int

class Inspection(InspectionBase):
    id: int
    uuid: str
    inspection_number: str
    status: InspectionStatus
    inspector_id: Optional[int] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    converted_to_work_order_id: Optional[int] = None
    converted_by: Optional[int] = None
    converted_at: Optional[datetime] = None
    created_by: int
    created_at: datetime
    updated_at: datetime

class QuoteItemBase(BaseModel):
    service_name: str
    description: Optional[str] = None
    quantity: int = 1
    unit_price: float
    total_price: float
    estimated_duration: Optional[int] = None
    notes: Optional[str] = None

class QuoteBase(BaseModel):
    inspection_id: Optional[int] = None
    work_order_id: Optional[int] = None
    customer_id: int
    total_amount: float
    currency: str = "YER"
    valid_until: Optional[datetime] = None
    notes: Optional[str] = None

class QuoteCreate(QuoteBase):
    items: List[QuoteItemBase]
    created_by: int

class Quote(QuoteBase):
    id: int
    uuid: str
    quote_number: str
    status: str
    sent_at: Optional[datetime] = None
    accepted_at: Optional[datetime] = None
    rejected_at: Optional[datetime] = None
    created_by: int
    accepted_by: Optional[int] = None
    created_at: datetime
    updated_at: datetime

class ElectronicSignatureBase(BaseModel):
    reference_type: str
    reference_id: int
    signer_id: int
    signer_name: str
    signer_email: Optional[str] = None
    signer_phone: Optional[str] = None
    signature_data: str
    signature_method: str = "digital"
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None
    expires_at: Optional[datetime] = None

class ElectronicSignatureCreate(ElectronicSignatureBase):
    pass

class ElectronicSignature(ElectronicSignatureBase):
    id: int
    uuid: str
    status: str
    signed_at: Optional[datetime] = None
    verification_code: Optional[str] = None
    verified_at: Optional[datetime] = None
    created_at: datetime

class NotificationBase(BaseModel):
    recipient_id: int
    recipient_email: Optional[str] = None
    recipient_phone: Optional[str] = None
    notification_type: str
    title: str
    message: str
    priority: str = "Normal"
    reference_type: Optional[str] = None
    reference_id: Optional[int] = None
    metadata: Optional[Dict[str, Any]] = None

class NotificationCreate(NotificationBase):
    sent_by: Optional[int] = None

class Notification(NotificationBase):
    id: int
    uuid: str
    status: str
    sent_at: Optional[datetime] = None
    delivered_at: Optional[datetime] = None
    read_at: Optional[datetime] = None
    error_message: Optional[str] = None
    sent_by: Optional[int] = None
    created_at: datetime
    updated_at: datetime

class FileAttachmentBase(BaseModel):
    reference_type: str
    reference_id: int
    file_name: str
    file_path: str
    file_type: Optional[str] = None
    file_size: Optional[int] = None
    mime_type: Optional[str] = None
    thumbnail_path: Optional[str] = None
    processed_path: Optional[str] = None
    category: str = "document"
    tags: Optional[List[str]] = None

class FileAttachmentCreate(FileAttachmentBase):
    uploaded_by: int

class FileAttachment(FileAttachmentBase):
    id: int
    uuid: str
    uploaded_by: int
    uploaded_at: datetime
    is_active: bool
    deleted_at: Optional[datetime] = None

# Database connection functions
async def get_db():
    conn = await asyncpg.connect(DATABASE_URL)
    try:
        yield conn
    finally:
        await conn.close()

# Vehicle Types Endpoints
@app.post("/vehicle-types/", response_model=VehicleType)
async def create_vehicle_type(vehicle_type: VehicleTypeCreate, conn=Depends(get_db)):
    query = """
    INSERT INTO work_orders.vehicle_types (make, model, year, trim_level, engine_type, transmission, fuel_type)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id, uuid, make, model, year, trim_level, engine_type, transmission, fuel_type, is_active, created_at, updated_at
    """
    row = await conn.fetchrow(query, vehicle_type.make, vehicle_type.model, vehicle_type.year,
                             vehicle_type.trim_level, vehicle_type.engine_type, vehicle_type.transmission, vehicle_type.fuel_type)
    return dict(row)

@app.get("/vehicle-types/", response_model=List[VehicleType])
async def get_vehicle_types(skip: int = 0, limit: int = 100, conn=Depends(get_db)):
    query = """
    SELECT id, uuid, make, model, year, trim_level, engine_type, transmission, fuel_type, is_active, created_at, updated_at
    FROM work_orders.vehicle_types
    WHERE is_active = true
    ORDER BY make, model, year
    LIMIT $1 OFFSET $2
    """
    rows = await conn.fetch(query, limit, skip)
    return [dict(row) for row in rows]

# Inspection Endpoints
@app.post("/inspections/", response_model=Inspection)
async def create_inspection(inspection: InspectionCreate, conn=Depends(get_db)):
    query = """
    INSERT INTO work_orders.inspections (
        customer_id, vehicle_type_id, vehicle_make, vehicle_model, vehicle_year,
        vehicle_vin, vehicle_license_plate, vehicle_mileage, vehicle_color, vehicle_trim,
        inspection_type, customer_complaint, observations, recommendations, attachments,
        scheduled_date, created_by
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)
    RETURNING id, uuid, inspection_number, customer_id, vehicle_type_id, vehicle_make, vehicle_model,
             vehicle_year, vehicle_vin, vehicle_license_plate, vehicle_mileage, vehicle_color, vehicle_trim,
             inspection_type, status, inspector_id, customer_complaint, observations, recommendations,
             attachments, scheduled_date, started_at, completed_at, converted_to_work_order_id,
             converted_by, converted_at, created_by, created_at, updated_at
    """
    row = await conn.fetchrow(query, inspection.customer_id, inspection.vehicle_type_id, inspection.vehicle_make,
                             inspection.vehicle_model, inspection.vehicle_year, inspection.vehicle_vin,
                             inspection.vehicle_license_plate, inspection.vehicle_mileage, inspection.vehicle_color,
                             inspection.vehicle_trim, inspection.inspection_type, inspection.customer_complaint,
                             inspection.observations, inspection.recommendations, json.dumps(inspection.attachments) if inspection.attachments else None,
                             inspection.scheduled_date, inspection.created_by)
    return dict(row)

@app.get("/inspections/", response_model=List[Inspection])
async def get_inspections(
    skip: int = 0,
    limit: int = 100,
    customer_id: Optional[int] = None,
    status: Optional[InspectionStatus] = None,
    inspector_id: Optional[int] = None,
    conn=Depends(get_db)
):
    conditions = []
    params = []
    param_count = 0

    if customer_id:
        param_count += 1
        conditions.append(f"customer_id = ${param_count}")
        params.append(customer_id)

    if status:
        param_count += 1
        conditions.append(f"status = ${param_count}")
        params.append(status)

    if inspector_id:
        param_count += 1
        conditions.append(f"inspector_id = ${param_count}")
        params.append(inspector_id)

    where_clause = " AND ".join(conditions) if conditions else "TRUE"

    query = f"""
    SELECT id, uuid, inspection_number, customer_id, vehicle_type_id, vehicle_make, vehicle_model,
           vehicle_year, vehicle_vin, vehicle_license_plate, vehicle_mileage, vehicle_color, vehicle_trim,
           inspection_type, status, inspector_id, customer_complaint, observations, recommendations,
           attachments, scheduled_date, started_at, completed_at, converted_to_work_order_id,
           converted_by, converted_at, created_by, created_at, updated_at
    FROM work_orders.inspections
    WHERE {where_clause}
    ORDER BY created_at DESC
    LIMIT ${param_count + 1} OFFSET ${param_count + 2}
    """
    params.extend([limit, skip])
    rows = await conn.fetch(query, *params)
    return [dict(row) for row in rows]

@app.get("/inspections/{inspection_id}", response_model=Inspection)
async def get_inspection(inspection_id: int, conn=Depends(get_db)):
    query = """
    SELECT id, uuid, inspection_number, customer_id, vehicle_type_id, vehicle_make, vehicle_model,
           vehicle_year, vehicle_vin, vehicle_license_plate, vehicle_mileage, vehicle_color, vehicle_trim,
           inspection_type, status, inspector_id, customer_complaint, observations, recommendations,
           attachments, scheduled_date, started_at, completed_at, converted_to_work_order_id,
           converted_by, converted_at, created_by, created_at, updated_at
    FROM work_orders.inspections
    WHERE id = $1
    """
    row = await conn.fetchrow(query, inspection_id)
    if not row:
        raise HTTPException(status_code=404, detail="Inspection not found")
    return dict(row)

@app.put("/inspections/{inspection_id}", response_model=Inspection)
async def update_inspection(inspection_id: int, inspection_update: InspectionUpdate, conn=Depends(get_db)):
    # First check if inspection exists
    existing = await conn.fetchrow("SELECT * FROM work_orders.inspections WHERE id = $1", inspection_id)
    if not existing:
        raise HTTPException(status_code=404, detail="Inspection not found")

    # Build update query dynamically
    update_fields = []
    params = []
    param_count = 0

    update_data = inspection_update.dict(exclude_unset=True, exclude={'updated_by'})
    for field, value in update_data.items():
        if field == 'attachments':
            value = json.dumps(value) if value else None
        param_count += 1
        update_fields.append(f"{field} = ${param_count}")
        params.append(value)

    if update_fields:
        param_count += 1
        update_fields.append(f"updated_by = ${param_count}")
        params.append(inspection_update.updated_by)

        query = f"""
        UPDATE work_orders.inspections
        SET {', '.join(update_fields)}, updated_at = CURRENT_TIMESTAMP
        WHERE id = ${param_count + 1}
        RETURNING id, uuid, inspection_number, customer_id, vehicle_type_id, vehicle_make, vehicle_model,
                 vehicle_year, vehicle_vin, vehicle_license_plate, vehicle_mileage, vehicle_color, vehicle_trim,
                 inspection_type, status, inspector_id, customer_complaint, observations, recommendations,
                 attachments, scheduled_date, started_at, completed_at, converted_to_work_order_id,
                 converted_by, converted_at, created_by, created_at, updated_at
        """
        params.append(inspection_id)
        row = await conn.fetchrow(query, *params)
        return dict(row)
    else:
        # No updates, return existing
        return dict(existing)

@app.post("/inspections/{inspection_id}/faults/")
async def add_inspection_fault(inspection_id: int, fault: InspectionFaultBase, conn=Depends(get_db)):
    query = """
    INSERT INTO work_orders.inspection_faults (inspection_id, fault_category, fault_description, severity, photos, notes)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING id, inspection_id, fault_category, fault_description, severity, photos, notes, created_at
    """
    row = await conn.fetchrow(query, inspection_id, fault.fault_category, fault.fault_description,
                             fault.severity, json.dumps(fault.photos) if fault.photos else None, fault.notes)
    return dict(row)

@app.post("/inspections/{inspection_id}/services/")
async def add_inspection_service(inspection_id: int, service: InspectionServiceBase, conn=Depends(get_db)):
    query = """
    INSERT INTO work_orders.inspection_services (inspection_id, service_id, service_name, estimated_cost, estimated_duration, assigned_engineer_id, priority, notes)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING id, inspection_id, service_id, service_name, estimated_cost, estimated_duration, assigned_engineer_id, priority, notes, created_at
    """
    row = await conn.fetchrow(query, inspection_id, service.service_id, service.service_name, service.estimated_cost,
                             service.estimated_duration, service.assigned_engineer_id, service.priority, service.notes)
    return dict(row)

@app.post("/inspections/{inspection_id}/convert-to-work-order")
async def convert_inspection_to_work_order(inspection_id: int, converted_by: int, conn=Depends(get_db)):
    # Get inspection details
    inspection = await conn.fetchrow("""
    SELECT * FROM work_orders.inspections WHERE id = $1
    """, inspection_id)

    if not inspection:
        raise HTTPException(status_code=404, detail="Inspection not found")

    if inspection['status'] == 'Converted_to_Work_Order':
        raise HTTPException(status_code=400, detail="Inspection already converted to work order")

    # Start transaction
    async with conn.transaction():
        # Create work order
        work_order_query = """
        INSERT INTO work_orders.work_orders (
            customer_id, vehicle_make, vehicle_model, vehicle_year, vehicle_vin,
            vehicle_license_plate, vehicle_mileage, vehicle_color, title, description,
            customer_complaint, diagnosis, created_by
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
        RETURNING id
        """
        work_order_id = await conn.fetchval(work_order_query, inspection['customer_id'], inspection['vehicle_make'],
                                          inspection['vehicle_model'], inspection['vehicle_year'], inspection['vehicle_vin'],
                                          inspection['vehicle_license_plate'], inspection['vehicle_mileage'], inspection['vehicle_color'],
                                          f"Work Order from Inspection {inspection['inspection_number']}",
                                          inspection['recommendations'], inspection['customer_complaint'],
                                          inspection['observations'], converted_by)

        # Add services to work order
        services = await conn.fetch("""
        SELECT * FROM work_orders.inspection_services WHERE inspection_id = $1
        """, inspection_id)

        for service in services:
            await conn.execute("""
            INSERT INTO work_orders.work_order_services (
                work_order_id, service_id, service_name, estimated_duration, status, notes, created_at
            ) VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP)
            """, work_order_id, service['service_id'], service['service_name'], service['estimated_duration'],
            'Pending', service['notes'])

            # Create task for assigned engineer
            if service['assigned_engineer_id']:
                await conn.execute("""
                INSERT INTO work_orders.work_order_tasks (
                    work_order_id, task_name, task_description, assigned_to, status, priority,
                    estimated_duration, notes, created_at
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_TIMESTAMP)
                """, work_order_id, service['service_name'], f"Perform {service['service_name']}",
                service['assigned_engineer_id'], 'Pending', service['priority'],
                service['estimated_duration'], service['notes'])

        # Update inspection status
        await conn.execute("""
        UPDATE work_orders.inspections
        SET status = 'Converted_to_Work_Order', converted_to_work_order_id = $1,
            converted_by = $2, converted_at = CURRENT_TIMESTAMP, updated_by = $2
        WHERE id = $3
        """, work_order_id, converted_by, inspection_id)

        return {"work_order_id": work_order_id, "message": "Inspection converted to work order successfully"}

# Quotes Endpoints
@app.post("/quotes/", response_model=Quote)
async def create_quote(quote: QuoteCreate, conn=Depends(get_db)):
    async with conn.transaction():
        # Create quote
        quote_query = """
        INSERT INTO work_orders.quotes (
            inspection_id, work_order_id, customer_id, total_amount, currency, valid_until, notes, created_by
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id, uuid, quote_number, inspection_id, work_order_id, customer_id, total_amount,
                 currency, valid_until, notes, status, sent_at, accepted_at, rejected_at,
                 created_by, accepted_by, created_at, updated_at
        """
        row = await conn.fetchrow(quote_query, quote.inspection_id, quote.work_order_id, quote.customer_id,
                                 quote.total_amount, quote.currency, quote.valid_until, quote.notes, quote.created_by)

        # Add quote items
        for item in quote.items:
            await conn.execute("""
            INSERT INTO work_orders.quote_items (
                quote_id, service_name, description, quantity, unit_price, total_price,
                estimated_duration, notes
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            """, row['id'], item.service_name, item.description, item.quantity, item.unit_price,
            item.total_price, item.estimated_duration, item.notes)

        return dict(row)

@app.get("/quotes/", response_model=List[Quote])
async def get_quotes(
    skip: int = 0,
    limit: int = 100,
    customer_id: Optional[int] = None,
    status: Optional[str] = None,
    conn=Depends(get_db)
):
    conditions = []
    params = []
    param_count = 0

    if customer_id:
        param_count += 1
        conditions.append(f"customer_id = ${param_count}")
        params.append(customer_id)

    if status:
        param_count += 1
        conditions.append(f"status = ${param_count}")
        params.append(status)

    where_clause = " AND ".join(conditions) if conditions else "TRUE"

    query = f"""
    SELECT id, uuid, quote_number, inspection_id, work_order_id, customer_id, total_amount,
           currency, valid_until, notes, status, sent_at, accepted_at, rejected_at,
           created_by, accepted_by, created_at, updated_at
    FROM work_orders.quotes
    WHERE {where_clause}
    ORDER BY created_at DESC
    LIMIT ${param_count + 1} OFFSET ${param_count + 2}
    """
    params.extend([limit, skip])
    rows = await conn.fetch(query, *params)
    return [dict(row) for row in rows]

# Electronic Signatures Endpoints
@app.post("/signatures/", response_model=ElectronicSignature)
async def create_electronic_signature(signature: ElectronicSignatureCreate, conn=Depends(get_db)):
    verification_code = str(uuid.uuid4())[:8].upper()

    query = """
    INSERT INTO work_orders.electronic_signatures (
        reference_type, reference_id, signer_id, signer_name, signer_email, signer_phone,
        signature_data, signature_method, ip_address, user_agent, expires_at, verification_code
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
    RETURNING id, uuid, reference_type, reference_id, signer_id, signer_name, signer_email,
             signer_phone, signature_data, signature_method, ip_address, user_agent, status,
             signed_at, expires_at, verification_code, verified_at, created_at
    """
    row = await conn.fetchrow(query, signature.reference_type, signature.reference_id, signature.signer_id,
                             signature.signer_name, signature.signer_email, signature.signer_phone,
                             signature.signature_data, signature.signature_method, signature.ip_address,
                             signature.user_agent, signature.expires_at, verification_code)
    return dict(row)

@app.put("/signatures/{signature_id}/verify")
async def verify_signature(signature_id: int, verification_code: str, conn=Depends(get_db)):
    query = """
    UPDATE work_orders.electronic_signatures
    SET status = 'Signed', signed_at = CURRENT_TIMESTAMP, verified_at = CURRENT_TIMESTAMP
    WHERE id = $1 AND verification_code = $2 AND status = 'Pending'
    RETURNING id
    """
    result = await conn.fetchval(query, signature_id, verification_code)
    if not result:
        raise HTTPException(status_code=400, detail="Invalid verification code or signature already processed")

    return {"message": "Signature verified successfully"}

# Notifications Endpoints
@app.post("/notifications/", response_model=Notification)
async def create_notification(notification: NotificationCreate, background_tasks: BackgroundTasks, conn=Depends(get_db)):
    query = """
    INSERT INTO work_orders.notifications (
        recipient_id, recipient_email, recipient_phone, notification_type, title, message,
        priority, reference_type, reference_id, metadata, sent_by
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    RETURNING id, uuid, recipient_id, recipient_email, recipient_phone, notification_type,
             title, message, priority, reference_type, reference_id, metadata, status,
             sent_at, delivered_at, read_at, error_message, sent_by, created_at, updated_at
    """
    row = await conn.fetchrow(query, notification.recipient_id, notification.recipient_email,
                             notification.recipient_phone, notification.notification_type, notification.title,
                             notification.message, notification.priority, notification.reference_type,
                             notification.reference_id, json.dumps(notification.metadata) if notification.metadata else None,
                             notification.sent_by)

    # Add background task to send notification
    background_tasks.add_task(send_notification, dict(row))

    return dict(row)

# File Attachments Endpoints
@app.post("/attachments/", response_model=FileAttachment)
async def create_file_attachment(attachment: FileAttachmentCreate, conn=Depends(get_db)):
    query = """
    INSERT INTO work_orders.file_attachments (
        reference_type, reference_id, file_name, file_path, file_type, file_size,
        mime_type, thumbnail_path, processed_path, category, tags, uploaded_by
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
    RETURNING id, uuid, reference_type, reference_id, file_name, file_path, file_type,
             file_size, mime_type, thumbnail_path, processed_path, category, tags,
             uploaded_by, uploaded_at, is_active, deleted_at
    """
    row = await conn.fetchrow(query, attachment.reference_type, attachment.reference_id, attachment.file_name,
                             attachment.file_path, attachment.file_type, attachment.file_size, attachment.mime_type,
                             attachment.thumbnail_path, attachment.processed_path, attachment.category,
                             attachment.tags, attachment.uploaded_by)
    return dict(row)

# Background task for sending notifications
async def send_notification(notification_data: dict):
    # This would integrate with email/WhatsApp services
    # For now, just mark as sent
    conn = await asyncpg.connect(DATABASE_URL)
    try:
        await conn.execute("""
        UPDATE work_orders.notifications
        SET status = 'Sent', sent_at = CURRENT_TIMESTAMP
        WHERE id = $1
        """, notification_data['id'])
    finally:
        await conn.close()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "Work Order Management", "version": "2.0.0"}

@app.get("/")
async def root():
    return {"message": "Work Order Management Service v2.0.0 - Enhanced Workflow Support"}
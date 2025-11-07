from fastapi import FastAPI, HTTPException, Depends, File, UploadFile, BackgroundTasks
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from enum import Enum
import asyncpg
import json
import uuid
import os
from dotenv import load_dotenv
import aiofiles

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://yaman_user:yaman_password@localhost:5432/yaman_workshop_db")
UPLOAD_DIR = os.getenv("UPLOAD_DIR", "./uploads")

class InspectionPhase(str, Enum):
    INITIAL = "initial_inspection"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    AWAITING_APPROVAL = "awaiting_approval"
    CONVERTED = "converted_to_work_order"

class FaultSeverity(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class FaultCategory(str, Enum):
    MECHANICAL = "mechanical"
    ELECTRICAL = "electrical"
    STRUCTURAL = "structural"
    PAINT = "paint"
    INTERIOR = "interior"
    SUSPENSION = "suspension"
    ENGINE = "engine"
    OTHER = "other"

class QuoteStatus(str, Enum):
    DRAFT = "draft"
    SENT = "sent"
    PENDING_APPROVAL = "pending_approval"
    APPROVED = "approved"
    REJECTED = "rejected"
    CONVERTED = "converted_to_order"

class VehicleInfoRequest(BaseModel):
    make: str
    model: str
    year: int
    vin: str
    license_plate: str
    mileage: int
    color: str
    trim: Optional[str] = None

class CustomerInfoRequest(BaseModel):
    name: str
    phone: str
    email: str
    address: Optional[str] = None

class InitialInspectionRequest(BaseModel):
    customer_id: int
    vehicle_id: int
    vehicle_info: VehicleInfoRequest
    inspection_type: str
    customer_complaint: str
    scheduled_date: Optional[datetime] = None

class InspectionFaultRequest(BaseModel):
    category: FaultCategory
    description: str
    severity: FaultSeverity
    estimated_cost: Optional[float] = None
    notes: Optional[str] = None

class ServiceAssignmentRequest(BaseModel):
    service_id: int
    service_name: str
    engineer_id: int
    estimated_duration: Optional[int] = None
    estimated_cost: float
    notes: Optional[str] = None

class InspectionSubmissionRequest(BaseModel):
    inspection_id: int
    faults: List[InspectionFaultRequest]
    proposed_services: List[ServiceAssignmentRequest]
    general_notes: Optional[str] = None
    submitted_by: int

class QuoteItemRequest(BaseModel):
    service_name: str
    description: Optional[str] = None
    quantity: int = 1
    unit_price: float
    estimated_duration: Optional[int] = None

class QuoteGenerationRequest(BaseModel):
    inspection_id: int
    items: List[QuoteItemRequest]
    notes: Optional[str] = None
    valid_until_days: int = 7
    created_by: int

class QuoteApprovalRequest(BaseModel):
    quote_id: int
    approved_by: int
    approval_notes: Optional[str] = None

class ElectronicSignatureRequest(BaseModel):
    quote_id: int
    signature_data: str
    signer_name: str
    signer_email: Optional[str] = None
    signer_phone: Optional[str] = None

class PhaseOneService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()

    async def create_initial_inspection(
        self,
        customer_id: int,
        vehicle_info: Dict[str, Any],
        inspection_type: str,
        customer_complaint: str,
        created_by: int,
        conn=None
    ) -> Dict[str, Any]:

        inspection_id = str(uuid.uuid4())
        inspection_number = f"INS-{datetime.now().strftime('%Y%m%d%H%M%S')}"

        query = """
        INSERT INTO work_orders.inspections (
            uuid, inspection_number, customer_id, vehicle_make, vehicle_model,
            vehicle_year, vehicle_vin, vehicle_license_plate, vehicle_mileage,
            vehicle_color, vehicle_trim, inspection_type, status,
            customer_complaint, created_by, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, NOW(), NOW())
        RETURNING id, uuid, inspection_number, status, created_at
        """

        try:
            row = await conn.fetchrow(
                query,
                inspection_id,
                inspection_number,
                customer_id,
                vehicle_info.get('make'),
                vehicle_info.get('model'),
                vehicle_info.get('year'),
                vehicle_info.get('vin'),
                vehicle_info.get('license_plate'),
                vehicle_info.get('mileage'),
                vehicle_info.get('color'),
                vehicle_info.get('trim'),
                inspection_type,
                InspectionPhase.INITIAL.value,
                customer_complaint,
                created_by
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إنشاء الفحص الأولي: {str(e)}")

    async def add_fault(
        self,
        inspection_id: int,
        category: str,
        description: str,
        severity: str,
        estimated_cost: Optional[float],
        created_by: int,
        conn=None
    ) -> Dict[str, Any]:

        fault_id = str(uuid.uuid4())

        query = """
        INSERT INTO work_orders.inspection_faults (
            uuid, inspection_id, category, description, severity,
            estimated_cost, created_by, created_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
        RETURNING id, uuid, category, description, severity, estimated_cost
        """

        try:
            row = await conn.fetchrow(
                query,
                fault_id,
                inspection_id,
                category,
                description,
                severity,
                estimated_cost,
                created_by
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إضافة العيب: {str(e)}")

    async def assign_service_to_inspection(
        self,
        inspection_id: int,
        service_id: int,
        service_name: str,
        engineer_id: int,
        estimated_duration: Optional[int],
        estimated_cost: float,
        notes: Optional[str],
        created_by: int,
        conn=None
    ) -> Dict[str, Any]:

        assignment_id = str(uuid.uuid4())

        query = """
        INSERT INTO work_orders.inspection_service_assignments (
            uuid, inspection_id, service_id, service_name, engineer_id,
            estimated_duration, estimated_cost, notes, created_by, created_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW())
        RETURNING id, uuid, service_name, engineer_id, estimated_cost
        """

        try:
            row = await conn.fetchrow(
                query,
                assignment_id,
                inspection_id,
                service_id,
                service_name,
                engineer_id,
                estimated_duration,
                estimated_cost,
                notes,
                created_by
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إسناد الخدمة: {str(e)}")

    async def submit_inspection(
        self,
        inspection_id: int,
        submitted_by: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        UPDATE work_orders.inspections
        SET status = $1, updated_at = NOW()
        WHERE id = $2
        RETURNING id, inspection_number, status, updated_at
        """

        try:
            row = await conn.fetchrow(
                query,
                InspectionPhase.AWAITING_APPROVAL.value,
                inspection_id
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إرسال الفحص: {str(e)}")

    async def upload_inspection_file(
        self,
        inspection_id: int,
        file: UploadFile,
        file_type: str,
        uploaded_by: int,
        conn=None
    ) -> Dict[str, Any]:

        file_id = str(uuid.uuid4())
        file_name = f"{file_id}_{file.filename}"
        file_path = os.path.join(UPLOAD_DIR, file_name)

        os.makedirs(UPLOAD_DIR, exist_ok=True)

        try:
            contents = await file.read()
            async with aiofiles.open(file_path, 'wb') as f:
                await f.write(contents)

            query = """
            INSERT INTO work_orders.file_attachments (
                uuid, reference_type, reference_id, file_name, file_path,
                mime_type, file_type, category, uploaded_by, uploaded_at, is_active
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), true)
            RETURNING id, uuid, file_name, file_path
            """

            row = await conn.fetchrow(
                query,
                file_id,
                "inspection",
                inspection_id,
                file.filename,
                file_path,
                file.content_type,
                file_type,
                "document",
                uploaded_by
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في رفع الملف: {str(e)}")


class PhaseTwoService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()

    async def get_inspection_details(
        self,
        inspection_id: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        SELECT id, inspection_number, customer_id, vehicle_make, vehicle_model,
               vehicle_year, vehicle_vin, vehicle_license_plate, vehicle_mileage,
               vehicle_color, status, customer_complaint, created_at
        FROM work_orders.inspections
        WHERE id = $1
        """

        try:
            row = await conn.fetchrow(query, inspection_id)
            if not row:
                return None

            inspection = dict(row)

            faults_query = """
            SELECT id, category, description, severity, estimated_cost
            FROM work_orders.inspection_faults
            WHERE inspection_id = $1
            """
            faults = await conn.fetch(faults_query, inspection_id)
            inspection['faults'] = [dict(f) for f in faults]

            services_query = """
            SELECT id, service_name, engineer_id, estimated_duration, estimated_cost
            FROM work_orders.inspection_service_assignments
            WHERE inspection_id = $1
            """
            services = await conn.fetch(services_query, inspection_id)
            inspection['services'] = [dict(s) for s in services]

            return inspection
        except Exception as e:
            raise Exception(f"خطأ في جلب تفاصيل الفحص: {str(e)}")

    async def generate_quote(
        self,
        inspection_id: int,
        items: List[Dict[str, Any]],
        notes: Optional[str],
        valid_until_days: int,
        created_by: int,
        conn=None
    ) -> Dict[str, Any]:

        quote_id = str(uuid.uuid4())
        quote_number = f"QT-{datetime.now().strftime('%Y%m%d%H%M%S')}"

        total_amount = sum(item.get('quantity', 1) * item.get('unit_price', 0) for item in items)
        valid_until = datetime.now() + timedelta(days=valid_until_days)

        query = """
        INSERT INTO work_orders.quotes (
            uuid, quote_number, inspection_id, total_amount, currency,
            status, valid_until, notes, created_by, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())
        RETURNING id, uuid, quote_number, total_amount, status, valid_until
        """

        try:
            row = await conn.fetchrow(
                query,
                quote_id,
                quote_number,
                inspection_id,
                total_amount,
                "YER",
                QuoteStatus.DRAFT.value,
                valid_until,
                notes,
                created_by
            )

            quote = dict(row) if row else None

            for idx, item in enumerate(items):
                item_id = str(uuid.uuid4())
                item_total = item.get('quantity', 1) * item.get('unit_price', 0)

                item_query = """
                INSERT INTO work_orders.quote_items (
                    uuid, quote_id, service_name, description, quantity,
                    unit_price, total_price, estimated_duration, created_at
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
                """

                await conn.execute(
                    item_query,
                    item_id,
                    quote['id'],
                    item.get('service_name'),
                    item.get('description'),
                    item.get('quantity', 1),
                    item.get('unit_price', 0),
                    item_total,
                    item.get('estimated_duration')
                )

            return quote
        except Exception as e:
            raise Exception(f"خطأ في إنشاء عرض السعر: {str(e)}")

    async def send_quote(
        self,
        quote_id: int,
        customer_email: str,
        customer_phone: Optional[str],
        delivery_method: str,
        sent_by: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        UPDATE work_orders.quotes
        SET status = $1, sent_at = NOW(), updated_at = NOW()
        WHERE id = $2
        RETURNING id, quote_number, status, sent_at
        """

        try:
            row = await conn.fetchrow(
                query,
                QuoteStatus.SENT.value,
                quote_id
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إرسال عرض السعر: {str(e)}")

    async def save_electronic_signature(
        self,
        quote_id: int,
        signer_name: str,
        signer_email: Optional[str],
        signer_phone: Optional[str],
        signature_data: str,
        conn=None
    ) -> Dict[str, Any]:

        signature_id = str(uuid.uuid4())

        query = """
        INSERT INTO work_orders.electronic_signatures (
            uuid, reference_type, reference_id, signer_name, signer_email,
            signer_phone, signature_data, signature_method, status, signed_at, created_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())
        RETURNING id, uuid, signed_at
        """

        quote_update = """
        UPDATE work_orders.quotes
        SET status = $1, accepted_at = NOW(), updated_at = NOW()
        WHERE id = $2
        RETURNING id, quote_number, status
        """

        try:
            sig_row = await conn.fetchrow(
                query,
                signature_id,
                "quote",
                quote_id,
                signer_name,
                signer_email,
                signer_phone,
                signature_data,
                "digital",
                "verified"
            )

            quote_row = await conn.fetchrow(
                quote_update,
                QuoteStatus.APPROVED.value,
                quote_id
            )

            return {
                "signature": dict(sig_row) if sig_row else None,
                "quote": dict(quote_row) if quote_row else None
            }
        except Exception as e:
            raise Exception(f"خطأ في حفظ التوقيع الإلكتروني: {str(e)}")

    async def convert_inspection_to_work_order(
        self,
        inspection_id: int,
        quote_id: int,
        converted_by: int,
        conn=None
    ) -> Dict[str, Any]:

        work_order_id = str(uuid.uuid4())
        work_order_number = f"WO-{datetime.now().strftime('%Y%m%d%H%M%S')}"

        query = """
        INSERT INTO work_orders.work_orders (
            uuid, work_order_number, inspection_id, quote_id, status,
            created_by, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
        RETURNING id, uuid, work_order_number, status
        """

        inspect_update = """
        UPDATE work_orders.inspections
        SET status = $1, converted_to_work_order_id = $2,
            converted_by = $3, converted_at = NOW(), updated_at = NOW()
        WHERE id = $4
        """

        try:
            row = await conn.fetchrow(
                query,
                work_order_id,
                work_order_number,
                inspection_id,
                quote_id,
                "pending_execution",
                converted_by
            )

            await conn.execute(
                inspect_update,
                InspectionPhase.CONVERTED.value,
                row['id'] if row else None,
                converted_by,
                inspection_id
            )

            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في تحويل الفحص إلى أمر عمل: {str(e)}")

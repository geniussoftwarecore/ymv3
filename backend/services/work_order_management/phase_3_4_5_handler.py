from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
import asyncpg
import json
import uuid
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://yaman_user:yaman_password@localhost:5432/yaman_workshop_db")

class TaskStatus(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    BLOCKED = "blocked"
    FAILED = "failed"
    NEEDS_REVIEW = "needs_review"

class WorkOrderStatus(str, Enum):
    PENDING_EXECUTION = "pending_execution"
    IN_PROGRESS = "in_progress"
    AWAITING_FINAL_INSPECTION = "awaiting_final_inspection"
    PASSED_INSPECTION = "passed_inspection"
    FAILED_INSPECTION = "failed_inspection"
    READY_FOR_DELIVERY = "ready_for_delivery"
    DELIVERED = "delivered"
    CLOSED = "closed"

class TaskRequest(BaseModel):
    work_order_id: int
    service_name: str
    engineer_id: int
    estimated_duration: Optional[int] = None
    priority: str = "medium"
    notes: Optional[str] = None
    created_by: int

class TaskUpdateRequest(BaseModel):
    task_id: int
    status: TaskStatus
    progress_notes: Optional[str] = None
    updated_by: int

class TaskPhotoRequest(BaseModel):
    task_id: int
    photo_type: str
    photo_path: str
    uploaded_by: int

class InspectionChecklistItem(BaseModel):
    item_name: str
    is_passed: bool
    notes: Optional[str] = None

class FinalInspectionRequest(BaseModel):
    work_order_id: int
    checklist_items: List[InspectionChecklistItem]
    overall_quality_assessment: str
    inspector_id: int
    inspection_date: datetime

class DeliverySignatureRequest(BaseModel):
    work_order_id: int
    customer_id: int
    customer_name: str
    delivery_notes: Optional[str] = None
    signature_data: str
    delivered_by: int

class PhaseThreeService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()

    async def convert_quote_to_work_order(
        self,
        quote_id: int,
        inspection_id: int,
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

        try:
            row = await conn.fetchrow(
                query,
                work_order_id,
                work_order_number,
                inspection_id,
                quote_id,
                WorkOrderStatus.PENDING_EXECUTION.value,
                converted_by
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في تحويل عرض السعر إلى أمر عمل: {str(e)}")

    async def create_tasks_from_work_order(
        self,
        work_order_id: int,
        created_by: int,
        conn=None
    ) -> List[Dict[str, Any]]:

        quote_query = """
        SELECT q.id as quote_id
        FROM work_orders.quotes q
        JOIN work_orders.work_orders wo ON wo.quote_id = q.id
        WHERE wo.id = $1
        """

        try:
            quote_row = await conn.fetchrow(quote_query, work_order_id)
            if not quote_row:
                return []

            quote_id = quote_row['quote_id']

            items_query = """
            SELECT service_name, unit_price, estimated_duration
            FROM work_orders.quote_items
            WHERE quote_id = $1
            """

            items = await conn.fetch(items_query, quote_id)
            tasks = []

            for item in items:
                task_id = str(uuid.uuid4())
                task_query = """
                INSERT INTO work_orders.tasks (
                    uuid, work_order_id, service_name, estimated_duration,
                    status, created_by, created_at, updated_at
                )
                VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
                RETURNING id, uuid, service_name, status
                """

                task_row = await conn.fetchrow(
                    task_query,
                    task_id,
                    work_order_id,
                    item['service_name'],
                    item['estimated_duration'],
                    TaskStatus.PENDING.value,
                    created_by
                )

                tasks.append(dict(task_row) if task_row else None)

            return tasks
        except Exception as e:
            raise Exception(f"خطأ في إنشاء المهام: {str(e)}")

    async def assign_engineer_to_task(
        self,
        task_id: int,
        engineer_id: int,
        assigned_by: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        UPDATE work_orders.tasks
        SET engineer_id = $1, assigned_at = NOW(), updated_at = NOW()
        WHERE id = $2
        RETURNING id, service_name, engineer_id, assigned_at
        """

        try:
            row = await conn.fetchrow(query, engineer_id, task_id)
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إسناد المهندس: {str(e)}")

    async def start_task(
        self,
        task_id: int,
        engineer_id: int,
        started_by: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        UPDATE work_orders.tasks
        SET status = $1, started_at = NOW(), updated_at = NOW()
        WHERE id = $2 AND engineer_id = $3
        RETURNING id, service_name, status, started_at
        """

        try:
            row = await conn.fetchrow(
                query,
                TaskStatus.IN_PROGRESS.value,
                task_id,
                engineer_id
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في بدء المهمة: {str(e)}")

    async def upload_task_photo(
        self,
        task_id: int,
        photo_type: str,
        photo_path: str,
        uploaded_by: int,
        conn=None
    ) -> Dict[str, Any]:

        photo_id = str(uuid.uuid4())

        query = """
        INSERT INTO work_orders.task_photos (
            uuid, task_id, photo_type, photo_path, uploaded_by, uploaded_at
        )
        VALUES ($1, $2, $3, $4, $5, NOW())
        RETURNING id, uuid, photo_type, photo_path
        """

        try:
            row = await conn.fetchrow(
                query,
                photo_id,
                task_id,
                photo_type,
                photo_path,
                uploaded_by
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في رفع الصورة: {str(e)}")

    async def complete_task(
        self,
        task_id: int,
        engineer_id: int,
        completion_notes: Optional[str],
        completed_by: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        UPDATE work_orders.tasks
        SET status = $1, completed_at = NOW(), completion_notes = $2,
            updated_at = NOW()
        WHERE id = $3 AND engineer_id = $4
        RETURNING id, service_name, status, completed_at
        """

        try:
            row = await conn.fetchrow(
                query,
                TaskStatus.COMPLETED.value,
                completion_notes,
                task_id,
                engineer_id
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إكمال المهمة: {str(e)}")

    async def check_all_tasks_completed(
        self,
        work_order_id: int,
        conn=None
    ) -> bool:

        query = """
        SELECT COUNT(*) as pending_count
        FROM work_orders.tasks
        WHERE work_order_id = $1 AND status != $2
        """

        try:
            row = await conn.fetchrow(
                query,
                work_order_id,
                TaskStatus.COMPLETED.value
            )
            return row['pending_count'] == 0 if row else False
        except Exception as e:
            raise Exception(f"خطأ في التحقق من المهام: {str(e)}")

    async def update_work_order_status(
        self,
        work_order_id: int,
        status: str,
        updated_by: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        UPDATE work_orders.work_orders
        SET status = $1, updated_at = NOW()
        WHERE id = $2
        RETURNING id, work_order_number, status
        """

        try:
            row = await conn.fetchrow(query, status, work_order_id)
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في تحديث حالة أمر العمل: {str(e)}")


class PhaseFourService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()

    async def get_work_order_for_inspection(
        self,
        work_order_id: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        SELECT id, work_order_number, status, created_at
        FROM work_orders.work_orders
        WHERE id = $1 AND status = $2
        """

        try:
            work_order = await conn.fetchrow(
                query,
                work_order_id,
                WorkOrderStatus.AWAITING_FINAL_INSPECTION.value
            )

            if not work_order:
                return None

            work_order_data = dict(work_order)

            tasks_query = """
            SELECT id, service_name, status, started_at, completed_at
            FROM work_orders.tasks
            WHERE work_order_id = $1
            """

            tasks = await conn.fetch(tasks_query, work_order_id)
            work_order_data['tasks'] = [dict(t) for t in tasks]

            return work_order_data
        except Exception as e:
            raise Exception(f"خطأ في جلب بيانات أمر العمل: {str(e)}")

    async def save_final_inspection(
        self,
        work_order_id: int,
        checklist_items: List[Dict[str, Any]],
        overall_assessment: str,
        inspector_id: int,
        conn=None
    ) -> Dict[str, Any]:

        inspection_id = str(uuid.uuid4())
        all_passed = all(item.get('is_passed', False) for item in checklist_items)

        inspection_query = """
        INSERT INTO work_orders.final_inspections (
            uuid, work_order_id, overall_assessment, all_passed,
            inspector_id, inspection_date, created_at
        )
        VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
        RETURNING id, uuid, all_passed
        """

        try:
            inspection_row = await conn.fetchrow(
                inspection_query,
                inspection_id,
                work_order_id,
                overall_assessment,
                all_passed,
                inspector_id
            )

            for item in checklist_items:
                item_id = str(uuid.uuid4())
                item_query = """
                INSERT INTO work_orders.inspection_checklist_items (
                    uuid, inspection_id, item_name, is_passed, notes, created_at
                )
                VALUES ($1, $2, $3, $4, $5, NOW())
                """

                await conn.execute(
                    item_query,
                    item_id,
                    inspection_row['id'],
                    item.get('item_name'),
                    item.get('is_passed'),
                    item.get('notes')
                )

            new_status = WorkOrderStatus.PASSED_INSPECTION.value if all_passed else WorkOrderStatus.FAILED_INSPECTION.value

            status_query = """
            UPDATE work_orders.work_orders
            SET status = $1, updated_at = NOW()
            WHERE id = $2
            """

            await conn.execute(status_query, new_status, work_order_id)

            return dict(inspection_row)
        except Exception as e:
            raise Exception(f"خطأ في حفظ الفحص النهائي: {str(e)}")

    async def approve_for_delivery(
        self,
        work_order_id: int,
        approved_by: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        UPDATE work_orders.work_orders
        SET status = $1, updated_at = NOW()
        WHERE id = $2
        RETURNING id, work_order_number, status
        """

        try:
            row = await conn.fetchrow(
                query,
                WorkOrderStatus.READY_FOR_DELIVERY.value,
                work_order_id
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في الموافقة للتسليم: {str(e)}")


class PhaseFiveService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()

    async def get_work_order_for_delivery(
        self,
        work_order_id: int,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        SELECT wo.id, wo.work_order_number, wo.status, q.total_amount,
               c.name as customer_name, c.phone as customer_phone, c.email as customer_email
        FROM work_orders.work_orders wo
        JOIN work_orders.quotes q ON wo.quote_id = q.id
        JOIN customers.customers c ON q.customer_id = c.id
        WHERE wo.id = $1
        """

        try:
            row = await conn.fetchrow(query, work_order_id)
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في جلب بيانات التسليم: {str(e)}")

    async def save_delivery_signature(
        self,
        work_order_id: int,
        customer_id: int,
        customer_name: str,
        delivery_notes: Optional[str],
        signature_data: str,
        delivered_by: int,
        conn=None
    ) -> Dict[str, Any]:

        signature_id = str(uuid.uuid4())

        signature_query = """
        INSERT INTO work_orders.delivery_signatures (
            uuid, work_order_id, customer_id, customer_name, signature_data,
            delivery_notes, signed_at, delivered_by, created_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, NOW(), $7, NOW())
        RETURNING id, uuid, signed_at
        """

        close_query = """
        UPDATE work_orders.work_orders
        SET status = $1, closed_at = NOW(), updated_at = NOW()
        WHERE id = $2
        RETURNING id, work_order_number, status, closed_at
        """

        try:
            sig_row = await conn.fetchrow(
                signature_query,
                signature_id,
                work_order_id,
                customer_id,
                customer_name,
                signature_data,
                delivery_notes,
                delivered_by
            )

            close_row = await conn.fetchrow(
                close_query,
                WorkOrderStatus.CLOSED.value,
                work_order_id
            )

            return {
                "signature": dict(sig_row) if sig_row else None,
                "work_order": dict(close_row) if close_row else None,
            }
        except Exception as e:
            raise Exception(f"خطأ في حفظ بيانات التسليم: {str(e)}")

    async def send_post_delivery_survey(
        self,
        customer_id: int,
        work_order_id: int,
        customer_email: str,
        sent_by: int,
        conn=None
    ) -> Dict[str, Any]:

        survey_id = str(uuid.uuid4())

        query = """
        INSERT INTO work_orders.customer_surveys (
            uuid, customer_id, work_order_id, status, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, NOW(), NOW())
        RETURNING id, uuid
        """

        try:
            row = await conn.fetchrow(
                query,
                survey_id,
                customer_id,
                work_order_id,
                "sent"
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إرسال استبيان الرضا: {str(e)}")

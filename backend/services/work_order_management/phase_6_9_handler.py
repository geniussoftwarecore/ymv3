from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from enum import Enum
import asyncpg
import json
import uuid
import os
from dotenv import load_dotenv
import hashlib

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://yaman_user:yaman_password@localhost:5432/yaman_workshop_db")

class UserRole(str, Enum):
    ADMIN = "admin"
    SUPERVISOR = "supervisor"
    ENGINEER = "engineer"
    SALES = "sales"
    CUSTOMER = "customer"

class ChatType(str, Enum):
    INTERNAL = "internal"
    CUSTOMER = "customer"
    TEAM = "team"

class MessageType(str, Enum):
    TEXT = "text"
    IMAGE = "image"
    FILE = "file"
    NOTIFICATION = "notification"

class ReportType(str, Enum):
    VEHICLES_REPAIRED = "vehicles_repaired"
    RETURN_RATE = "return_rate"
    ENGINEER_PERFORMANCE = "engineer_performance"
    REVENUE = "revenue"
    SYSTEM_HEALTH = "system_health"

class AIQueryRequest(BaseModel):
    customer_id: Optional[int] = None
    work_order_id: Optional[int] = None
    query: str
    context: Optional[Dict[str, Any]] = None

class ChatMessageRequest(BaseModel):
    chat_room_id: int
    sender_id: int
    message_text: str
    message_type: str = "text"
    attachments: Optional[List[str]] = None

class PermissionRequest(BaseModel):
    user_id: int
    resource: str
    action: str

class PhasesSixNineService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()


class PhaseSixService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()

    async def get_customer_context(
        self,
        customer_id: int,
        conn=None
    ) -> Dict[str, Any]:

        context_query = """
        SELECT c.id, c.name, c.phone, c.email,
               COUNT(DISTINCT wo.id) as total_orders,
               COUNT(DISTINCT CASE WHEN wo.status = 'closed' THEN 1 END) as completed_orders,
               AVG(EXTRACT(EPOCH FROM (wo.closed_at - wo.created_at))/86400) as avg_days
        FROM customers.customers c
        LEFT JOIN work_orders.work_orders wo ON wo.customer_id = c.id
        WHERE c.id = $1
        GROUP BY c.id, c.name, c.phone, c.email
        """

        try:
            row = await conn.fetchrow(context_query, customer_id)
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في جلب سياق العميل: {str(e)}")

    async def get_work_order_context(
        self,
        work_order_id: int,
        conn=None
    ) -> Dict[str, Any]:

        context_query = """
        SELECT wo.id, wo.work_order_number, wo.status,
               q.total_amount, q.currency,
               c.name as customer_name,
               COUNT(t.id) as total_tasks,
               COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as completed_tasks
        FROM work_orders.work_orders wo
        JOIN work_orders.quotes q ON wo.quote_id = q.id
        JOIN customers.customers c ON q.customer_id = c.id
        LEFT JOIN work_orders.tasks t ON t.work_order_id = wo.id
        WHERE wo.id = $1
        GROUP BY wo.id, wo.work_order_number, wo.status, q.total_amount,
                 q.currency, c.name
        """

        try:
            row = await conn.fetchrow(context_query, work_order_id)
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في جلب سياق أمر العمل: {str(e)}")

    async def save_ai_conversation(
        self,
        reference_type: str,
        reference_id: int,
        query: str,
        response: str,
        user_id: int,
        conn=None
    ) -> Dict[str, Any]:

        conv_id = str(uuid.uuid4())

        query_text = """
        INSERT INTO work_orders.ai_conversations (
            uuid, reference_type, reference_id, query, response,
            user_id, created_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, NOW())
        RETURNING id, uuid, created_at
        """

        try:
            row = await conn.fetchrow(
                query_text,
                conv_id,
                reference_type,
                reference_id,
                query,
                response,
                user_id
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في حفظ المحادثة: {str(e)}")


class PhaseSevenService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()

    async def create_chat_room(
        self,
        work_order_id: int,
        room_type: str,
        participants: List[int],
        created_by: int,
        conn=None
    ) -> Dict[str, Any]:

        room_id = str(uuid.uuid4())

        query = """
        INSERT INTO work_orders.chat_rooms (
            uuid, work_order_id, room_type, room_name,
            created_by, created_at
        )
        VALUES ($1, $2, $3, $4, $5, NOW())
        RETURNING id, uuid, room_type, created_at
        """

        try:
            row = await conn.fetchrow(
                query,
                room_id,
                work_order_id,
                room_type,
                f"{room_type}-{work_order_id}",
                created_by
            )

            chat_room = dict(row) if row else None

            for participant_id in participants:
                part_query = """
                INSERT INTO work_orders.chat_participants (
                    room_id, user_id, joined_at
                )
                VALUES ($1, $2, NOW())
                """
                await conn.execute(part_query, chat_room['id'], participant_id)

            return chat_room
        except Exception as e:
            raise Exception(f"خطأ في إنشاء غرفة الدردشة: {str(e)}")

    async def send_message(
        self,
        room_id: int,
        sender_id: int,
        message_text: str,
        message_type: str = "text",
        attachments: Optional[List[str]] = None,
        conn=None
    ) -> Dict[str, Any]:

        msg_id = str(uuid.uuid4())

        query = """
        INSERT INTO work_orders.chat_messages (
            uuid, room_id, sender_id, message_text, message_type,
            attachments, sent_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, NOW())
        RETURNING id, uuid, sent_at
        """

        try:
            row = await conn.fetchrow(
                query,
                msg_id,
                room_id,
                sender_id,
                message_text,
                message_type,
                json.dumps(attachments) if attachments else None
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إرسال الرسالة: {str(e)}")

    async def get_chat_history(
        self,
        room_id: int,
        limit: int = 50,
        conn=None
    ) -> List[Dict[str, Any]]:

        query = """
        SELECT id, uuid, sender_id, message_text, message_type,
               attachments, sent_at
        FROM work_orders.chat_messages
        WHERE room_id = $1
        ORDER BY sent_at DESC
        LIMIT $2
        """

        try:
            rows = await conn.fetch(query, room_id, limit)
            return [dict(row) for row in rows]
        except Exception as e:
            raise Exception(f"خطأ في جلب سجل الرسائل: {str(e)}")

    async def mark_message_read(
        self,
        message_id: int,
        reader_id: int,
        conn=None
    ) -> bool:

        query = """
        UPDATE work_orders.chat_messages
        SET is_read = true, read_at = NOW()
        WHERE id = $1
        """

        try:
            await conn.execute(query, message_id)
            return True
        except Exception as e:
            raise Exception(f"خطأ في وضع علامة القراءة: {str(e)}")


class PhaseEightService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()

    async def get_vehicles_repaired_report(
        self,
        start_date: datetime,
        end_date: datetime,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        SELECT 
            DATE(wo.created_at) as date,
            COUNT(DISTINCT wo.id) as count,
            SUM(q.total_amount) as revenue
        FROM work_orders.work_orders wo
        JOIN work_orders.quotes q ON wo.quote_id = q.id
        WHERE wo.status = 'closed'
        AND wo.closed_at BETWEEN $1 AND $2
        GROUP BY DATE(wo.created_at)
        ORDER BY date DESC
        """

        try:
            rows = await conn.fetch(query, start_date, end_date)
            return {
                'report_type': 'vehicles_repaired',
                'data': [dict(row) for row in rows],
                'generated_at': datetime.now()
            }
        except Exception as e:
            raise Exception(f"خطأ في إنشاء التقرير: {str(e)}")

    async def get_engineer_performance_report(
        self,
        engineer_id: Optional[int] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        conn=None
    ) -> Dict[str, Any]:

        query = """
        SELECT 
            u.id,
            u.full_name,
            COUNT(t.id) as tasks_completed,
            AVG(EXTRACT(EPOCH FROM (t.completed_at - t.started_at))/3600) as avg_hours,
            COUNT(CASE WHEN t.status = 'failed' THEN 1 END) as failed_tasks,
            SUM(CASE WHEN fi.all_passed THEN 1 ELSE 0 END) as passed_inspections
        FROM users.users u
        LEFT JOIN work_orders.tasks t ON t.engineer_id = u.id
        LEFT JOIN work_orders.final_inspections fi ON fi.work_order_id = t.work_order_id
        WHERE u.role = $1
        AND (u.id = $2 OR $2 IS NULL)
        AND (t.completed_at BETWEEN $3 AND $4 OR $3 IS NULL)
        GROUP BY u.id, u.full_name
        ORDER BY tasks_completed DESC
        """

        try:
            rows = await conn.fetch(
                query,
                UserRole.ENGINEER.value,
                engineer_id,
                start_date,
                end_date
            )
            return {
                'report_type': 'engineer_performance',
                'data': [dict(row) for row in rows],
                'generated_at': datetime.now()
            }
        except Exception as e:
            raise Exception(f"خطأ في إنشاء التقرير: {str(e)}")

    async def get_revenue_report(
        self,
        start_date: datetime,
        end_date: datetime,
        group_by: str = "day",
        conn=None
    ) -> Dict[str, Any]:

        if group_by == "day":
            date_format = "DATE(wo.closed_at)"
        elif group_by == "month":
            date_format = "DATE_TRUNC('month', wo.closed_at)"
        else:
            date_format = "DATE_TRUNC('year', wo.closed_at)"

        query = f"""
        SELECT 
            {date_format} as period,
            COUNT(DISTINCT wo.id) as orders_count,
            SUM(q.total_amount) as total_revenue,
            AVG(q.total_amount) as avg_order_value
        FROM work_orders.work_orders wo
        JOIN work_orders.quotes q ON wo.quote_id = q.id
        WHERE wo.closed_at BETWEEN $1 AND $2
        GROUP BY {date_format}
        ORDER BY period DESC
        """

        try:
            rows = await conn.fetch(query, start_date, end_date)
            return {
                'report_type': 'revenue',
                'group_by': group_by,
                'data': [dict(row) for row in rows],
                'generated_at': datetime.now()
            }
        except Exception as e:
            raise Exception(f"خطأ في إنشاء التقرير: {str(e)}")


class PhaseNineService:
    def __init__(self, db_url: str):
        self.db_url = db_url

    async def get_db(self):
        conn = await asyncpg.connect(self.db_url)
        try:
            yield conn
        finally:
            await conn.close()

    async def create_user(
        self,
        username: str,
        email: str,
        password: str,
        full_name: str,
        role: str,
        department: Optional[str],
        created_by: int,
        conn=None
    ) -> Dict[str, Any]:

        user_id = str(uuid.uuid4())
        password_hash = hashlib.sha256(password.encode()).hexdigest()

        query = """
        INSERT INTO users.users (
            uuid, username, email, password_hash, full_name,
            role, department, is_active, created_by, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, true, $8, NOW(), NOW())
        RETURNING id, uuid, username, email, full_name, role
        """

        try:
            row = await conn.fetchrow(
                query,
                user_id,
                username,
                email,
                password_hash,
                full_name,
                role,
                department,
                created_by
            )
            return dict(row) if row else None
        except Exception as e:
            raise Exception(f"خطأ في إنشاء المستخدم: {str(e)}")

    async def assign_permissions(
        self,
        user_id: int,
        resource: str,
        actions: List[str],
        assigned_by: int,
        conn=None
    ) -> List[Dict[str, Any]]:

        permissions = []

        try:
            for action in actions:
                perm_id = str(uuid.uuid4())
                perm_query = """
                INSERT INTO users.permissions (
                    uuid, user_id, resource, action, assigned_by, created_at
                )
                VALUES ($1, $2, $3, $4, $5, NOW())
                RETURNING id, resource, action
                """

                perm_row = await conn.fetchrow(
                    perm_query,
                    perm_id,
                    user_id,
                    resource,
                    action,
                    assigned_by
                )

                permissions.append(dict(perm_row) if perm_row else None)

            return permissions
        except Exception as e:
            raise Exception(f"خطأ في إسناد الصلاحيات: {str(e)}")

    async def check_permission(
        self,
        user_id: int,
        resource: str,
        action: str,
        conn=None
    ) -> bool:

        query = """
        SELECT EXISTS (
            SELECT 1 FROM users.permissions
            WHERE user_id = $1 AND resource = $2 AND action = $3
        ) as has_permission
        """

        try:
            row = await conn.fetchrow(query, user_id, resource, action)
            return row['has_permission'] if row else False
        except Exception as e:
            raise Exception(f"خطأ في التحقق من الصلاحيات: {str(e)}")

    async def get_user_roles_and_permissions(
        self,
        user_id: int,
        conn=None
    ) -> Dict[str, Any]:

        user_query = """
        SELECT id, username, full_name, role, department, is_active
        FROM users.users WHERE id = $1
        """

        perms_query = """
        SELECT resource, action
        FROM users.permissions WHERE user_id = $1
        """

        try:
            user = await conn.fetchrow(user_query, user_id)
            perms = await conn.fetch(perms_query, user_id)

            return {
                'user': dict(user) if user else None,
                'permissions': [dict(p) for p in perms] if perms else []
            }
        except Exception as e:
            raise Exception(f"خطأ في جلب الأدوار والصلاحيات: {str(e)}")

from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from datetime import datetime

from db.models import User, UserRole, UserStatus
from schemas.user import UserCreate, UserUpdate
from core.security import get_password_hash, verify_password

class CRUDUser:
    def get(self, db: Session, id: int) -> Optional[User]:
        """الحصول على مستخدم بواسطة ID"""
        return db.query(User).filter(User.id == id).first()

    def get_by_email(self, db: Session, email: str) -> Optional[User]:
        """الحصول على مستخدم بواسطة البريد الإلكتروني"""
        return db.query(User).filter(User.email == email).first()

    def get_by_username(self, db: Session, username: str) -> Optional[User]:
        """الحصول على مستخدم بواسطة اسم المستخدم"""
        return db.query(User).filter(User.username == username).first()

    def get_multi(
        self, 
        db: Session, 
        skip: int = 0, 
        limit: int = 100,
        role: Optional[UserRole] = None,
        status: Optional[UserStatus] = None,
        search: Optional[str] = None
    ) -> List[User]:
        """الحصول على قائمة المستخدمين مع الفلترة"""
        query = db.query(User)
        
        if role:
            query = query.filter(User.role == role)
        
        if status:
            query = query.filter(User.status == status)
        
        if search:
            search_filter = or_(
                User.full_name.ilike(f"%{search}%"),
                User.email.ilike(f"%{search}%"),
                User.username.ilike(f"%{search}%")
            )
            query = query.filter(search_filter)
        
        return query.offset(skip).limit(limit).all()

    def create(self, db: Session, obj_in: UserCreate) -> User:
        """إنشاء مستخدم جديد"""
        hashed_password = get_password_hash(obj_in.password)
        db_obj = User(
            email=obj_in.email,
            username=obj_in.username,
            full_name=obj_in.full_name,
            hashed_password=hashed_password,
            phone=obj_in.phone,
            address=obj_in.address,
            role=obj_in.role,
            status=obj_in.status,
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def update(self, db: Session, db_obj: User, obj_in: UserUpdate) -> User:
        """تحديث بيانات المستخدم"""
        update_data = obj_in.dict(exclude_unset=True)
        
        for field, value in update_data.items():
            setattr(db_obj, field, value)
        
        db_obj.updated_at = datetime.utcnow()
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def delete(self, db: Session, id: int) -> User:
        """حذف مستخدم"""
        obj = db.query(User).get(id)
        db.delete(obj)
        db.commit()
        return obj

    def authenticate(self, db: Session, username: str, password: str) -> Optional[User]:
        """التحقق من صحة بيانات المستخدم"""
        user = self.get_by_username(db, username=username)
        if not user:
            user = self.get_by_email(db, email=username)
        
        if not user:
            return None
        
        if not verify_password(password, user.hashed_password):
            return None
        
        return user

    def is_active(self, user: User) -> bool:
        """التحقق من أن المستخدم نشط"""
        return user.is_active and user.status == UserStatus.ACTIVE

    def is_verified(self, user: User) -> bool:
        """التحقق من أن المستخدم مُتحقق منه"""
        return user.is_verified

    def update_last_login(self, db: Session, user: User) -> User:
        """تحديث آخر تسجيل دخول"""
        user.last_login = datetime.utcnow()
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    def change_password(self, db: Session, user: User, new_password: str) -> User:
        """تغيير كلمة المرور"""
        user.hashed_password = get_password_hash(new_password)
        user.updated_at = datetime.utcnow()
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    def get_count(self, db: Session, **filters) -> int:
        """الحصول على عدد المستخدمين"""
        query = db.query(User)
        
        if filters.get('role'):
            query = query.filter(User.role == filters['role'])
        
        if filters.get('status'):
            query = query.filter(User.status == filters['status'])
        
        if filters.get('is_active') is not None:
            query = query.filter(User.is_active == filters['is_active'])
        
        return query.count()

    def get_stats(self, db: Session) -> Dict[str, Any]:
        """الحصول على إحصائيات المستخدمين"""
        total_users = db.query(User).count()
        active_users = db.query(User).filter(User.is_active == True).count()
        verified_users = db.query(User).filter(User.is_verified == True).count()
        
        role_stats = {}
        for role in UserRole:
            role_stats[role.value] = db.query(User).filter(User.role == role).count()
        
        status_stats = {}
        for status in UserStatus:
            status_stats[status.value] = db.query(User).filter(User.status == status).count()
        
        return {
            "total_users": total_users,
            "active_users": active_users,
            "verified_users": verified_users,
            "role_distribution": role_stats,
            "status_distribution": status_stats
        }

user = CRUDUser()

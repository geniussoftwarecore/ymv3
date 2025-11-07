from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session

from ..deps import (
    get_db,
    get_current_active_user,
    get_current_admin_user,
    get_current_supervisor_user
)
from ...crud.user import user as crud_user
from ...db.models import User as DBUser, UserRole, UserStatus
from ...schemas.user import User, UserCreate, UserUpdate, UserProfile, PasswordChange

router = APIRouter()

@router.get("/", response_model=List[User])
def read_users(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = Query(default=100, le=100),
    role: Optional[UserRole] = None,
    status: Optional[UserStatus] = None,
    search: Optional[str] = None,
    current_user: DBUser = Depends(get_current_supervisor_user),
) -> Any:
    """الحصول على قائمة المستخدمين (للمشرفين والإداريين فقط)"""
    users = crud_user.get_multi(
        db, 
        skip=skip, 
        limit=limit,
        role=role,
        status=status,
        search=search
    )
    return users

@router.post("/", response_model=User, status_code=status.HTTP_201_CREATED)
def create_user(
    *,
    db: Session = Depends(get_db),
    user_in: UserCreate,
    current_user: DBUser = Depends(get_current_admin_user),
) -> Any:
    """إنشاء مستخدم جديد (للإداريين فقط)"""
    user = crud_user.get_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="البريد الإلكتروني مسجل مسبقاً"
        )
    
    user = crud_user.get_by_username(db, username=user_in.username)
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="اسم المستخدم مستخدم مسبقاً"
        )
    
    user = crud_user.create(db, obj_in=user_in)
    return user

@router.get("/me", response_model=UserProfile)
def read_user_me(
    current_user: DBUser = Depends(get_current_active_user),
) -> Any:
    """الحصول على ملف المستخدم الشخصي"""
    return current_user

@router.put("/me", response_model=User)
def update_user_me(
    *,
    db: Session = Depends(get_db),
    user_in: UserUpdate,
    current_user: DBUser = Depends(get_current_active_user),
) -> Any:
    """تحديث ملف المستخدم الشخصي"""
    # Users can only update certain fields of their own profile
    allowed_fields = {
        'full_name', 'phone', 'address', 'profile_image'
    }
    update_data = user_in.dict(exclude_unset=True)
    
    # Filter out fields that users cannot update themselves
    filtered_data = {k: v for k, v in update_data.items() if k in allowed_fields}
    
    if not filtered_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="لا توجد حقول صالحة للتحديث"
        )
    
    user_update = UserUpdate(**filtered_data)
    user = crud_user.update(db, db_obj=current_user, obj_in=user_update)
    return user

@router.get("/{user_id}", response_model=User)
def read_user(
    user_id: int,
    current_user: DBUser = Depends(get_current_supervisor_user),
    db: Session = Depends(get_db),
) -> Any:
    """الحصول على مستخدم محدد بواسطة ID"""
    user = crud_user.get(db, id=user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المستخدم غير موجود"
        )
    return user

@router.put("/{user_id}", response_model=User)
def update_user(
    *,
    db: Session = Depends(get_db),
    user_id: int,
    user_in: UserUpdate,
    current_user: DBUser = Depends(get_current_admin_user),
) -> Any:
    """تحديث مستخدم (للإداريين فقط)"""
    user = crud_user.get(db, id=user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المستخدم غير موجود"
        )
    
    user = crud_user.update(db, db_obj=user, obj_in=user_in)
    return user

@router.delete("/{user_id}")
def delete_user(
    *,
    db: Session = Depends(get_db),
    user_id: int,
    current_user: DBUser = Depends(get_current_admin_user),
) -> Any:
    """حذف مستخدم (للإداريين فقط)"""
    user = crud_user.get(db, id=user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المستخدم غير موجود"
        )
    
    if user.id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="لا يمكن حذف حسابك الخاص"
        )
    
    user = crud_user.delete(db, id=user_id)
    return {"message": "تم حذف المستخدم بنجاح"}

@router.post("/change-password")
def change_password(
    *,
    db: Session = Depends(get_db),
    password_data: PasswordChange,
    current_user: DBUser = Depends(get_current_active_user),
) -> Any:
    """تغيير كلمة المرور"""
    from ...core.security import verify_password
    
    # Verify current password
    if not verify_password(password_data.current_password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="كلمة المرور الحالية غير صحيحة"
        )
    
    # Update password
    crud_user.change_password(db, current_user, password_data.new_password)
    
    return {"message": "تم تغيير كلمة المرور بنجاح"}

@router.get("/stats/overview")
def get_user_stats(
    db: Session = Depends(get_db),
    current_user: DBUser = Depends(get_current_supervisor_user),
) -> Any:
    """الحصول على إحصائيات المستخدمين"""
    stats = crud_user.get_stats(db)
    return stats

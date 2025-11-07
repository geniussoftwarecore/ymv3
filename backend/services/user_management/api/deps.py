from typing import Generator, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from pydantic import ValidationError
from sqlalchemy.orm import Session

from db.session import SessionLocal, get_db
from db.models import User, UserRole
from core.config import settings
from core.security import ALGORITHM
from schemas.token import TokenPayload
from crud.user import user as crud_user

# OAuth2 scheme
reusable_oauth2 = OAuth2PasswordBearer(
    tokenUrl=f"{settings.API_V1_STR}/auth/login"
)

def get_current_user(
    db: Session = Depends(get_db),
    token: str = Depends(reusable_oauth2)
) -> User:
    """الحصول على المستخدم الحالي من الرمز المميز"""
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[ALGORITHM]
        )
        token_data = TokenPayload(**payload)
    except (JWTError, ValidationError):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user = crud_user.get(db, id=int(token_data.sub))
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return user

def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """الحصول على المستخدم النشط الحالي"""
    if not crud_user.is_active(current_user):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    return current_user

def get_current_verified_user(
    current_user: User = Depends(get_current_active_user),
) -> User:
    """الحصول على المستخدم المُتحقق منه"""
    if not crud_user.is_verified(current_user):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User not verified"
        )
    return current_user

def get_current_admin_user(
    current_user: User = Depends(get_current_active_user),
) -> User:
    """الحصول على المستخدم الإداري"""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="The user doesn't have enough privileges"
        )
    return current_user

def get_current_supervisor_user(
    current_user: User = Depends(get_current_active_user),
) -> User:
    """الحصول على المستخدم المشرف أو الإداري"""
    if current_user.role not in [UserRole.ADMIN, UserRole.SUPERVISOR]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="The user doesn't have enough privileges"
        )
    return current_user

def get_current_engineer_user(
    current_user: User = Depends(get_current_active_user),
) -> User:
    """الحصول على المستخدم المهندس أو أعلى"""
    if current_user.role not in [UserRole.ADMIN, UserRole.SUPERVISOR, UserRole.ENGINEER]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="The user doesn't have enough privileges"
        )
    return current_user

def get_current_sales_user(
    current_user: User = Depends(get_current_active_user),
) -> User:
    """الحصول على مستخدم المبيعات أو أعلى"""
    if current_user.role not in [UserRole.ADMIN, UserRole.SUPERVISOR, UserRole.SALES]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="The user doesn't have enough privileges"
        )
    return current_user

def check_user_permissions(
    required_roles: list[UserRole],
    current_user: User = Depends(get_current_active_user)
) -> User:
    """التحقق من صلاحيات المستخدم"""
    if current_user.role not in required_roles:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions"
        )
    return current_user

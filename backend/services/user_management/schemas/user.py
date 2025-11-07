from typing import Optional
from pydantic import BaseModel, EmailStr, validator
from datetime import datetime
from ..db.models import UserRole, UserStatus

# Base User Schema
class UserBase(BaseModel):
    email: EmailStr
    username: str
    full_name: str
    phone: Optional[str] = None
    address: Optional[str] = None
    role: UserRole = UserRole.CUSTOMER
    status: UserStatus = UserStatus.PENDING

# User Create Schema
class UserCreate(UserBase):
    password: str
    
    @validator('password')
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError('كلمة المرور يجب أن تكون 8 أحرف على الأقل')
        return v
    
    @validator('username')
    def validate_username(cls, v):
        if len(v) < 3:
            raise ValueError('اسم المستخدم يجب أن يكون 3 أحرف على الأقل')
        return v

# User Update Schema
class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    full_name: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    role: Optional[UserRole] = None
    status: Optional[UserStatus] = None
    is_active: Optional[bool] = None
    is_verified: Optional[bool] = None
    profile_image: Optional[str] = None
    notes: Optional[str] = None

# User Response Schema
class User(UserBase):
    id: int
    is_active: bool
    is_verified: bool
    created_at: datetime
    updated_at: Optional[datetime] = None
    last_login: Optional[datetime] = None
    profile_image: Optional[str] = None
    notes: Optional[str] = None
    
    class Config:
        from_attributes = True

# User Login Schema
class UserLogin(BaseModel):
    username: str
    password: str

# User Profile Schema
class UserProfile(BaseModel):
    id: int
    email: EmailStr
    username: str
    full_name: str
    phone: Optional[str] = None
    role: UserRole
    status: UserStatus
    profile_image: Optional[str] = None
    created_at: datetime
    last_login: Optional[datetime] = None
    
    class Config:
        from_attributes = True

# Password Change Schema
class PasswordChange(BaseModel):
    current_password: str
    new_password: str
    confirm_password: str
    
    @validator('confirm_password')
    def passwords_match(cls, v, values, **kwargs):
        if 'new_password' in values and v != values['new_password']:
            raise ValueError('كلمات المرور غير متطابقة')
        return v

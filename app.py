"""
Yaman Hybrid Workshop Management System - Consolidated Backend
This is a consolidated FastAPI application for running on Replit with PostgreSQL
"""
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import func, text
import bcrypt
from jose import JWTError, jwt
from datetime import datetime, timedelta
import os
from pathlib import Path

from database import get_db, SessionLocal
from models import (
    User as UserModel,
    Service as ServiceModel,
    ServiceCategory as ServiceCategoryModel,
    WorkOrder as WorkOrderModel,
    ChatRoom as ChatRoomModel,
    Inspection as InspectionModel,
    InspectionFault as InspectionFaultModel,
    InspectionPhoto as InspectionPhotoModel,
    UserRole,
    UserStatus,
    WorkOrderStatus
)
from file_utils import save_inspection_photo
from fastapi import File, UploadFile

app = FastAPI(
    title="Yaman Workshop Management System",
    description="نظام إدارة ورش يمن الهجين - Workshop Management System",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


class LoginRequest(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    role: str
    full_name: str
    phone: Optional[str] = None
    is_active: bool

    class Config:
        from_attributes = True


class ServiceResponse(BaseModel):
    id: int
    name: str
    name_ar: str
    base_price: float
    estimated_duration: Optional[int]
    status: str

    class Config:
        from_attributes = True


class WorkOrderResponse(BaseModel):
    id: int
    order_number: str
    title: str
    status: str
    priority: str
    customer_id: int
    created_at: datetime

    class Config:
        from_attributes = True


class DashboardStats(BaseModel):
    total_customers: int
    total_work_orders: int
    total_services: int
    active_work_orders: int
    completed_today: int


class InspectionCreate(BaseModel):
    customer_id: int
    vehicle_make: Optional[str] = None
    vehicle_model: Optional[str] = None
    vehicle_year: Optional[int] = None
    vehicle_vin: Optional[str] = None
    vehicle_license_plate: Optional[str] = None
    vehicle_mileage: Optional[int] = None
    vehicle_color: Optional[str] = None
    inspection_type: str = "General Inspection"
    customer_complaint: Optional[str] = None
    priority: str = "Medium"


class InspectionFaultCreate(BaseModel):
    inspection_id: int
    category: str
    description: str
    severity: str = "Medium"
    location: Optional[str] = None
    estimated_cost: Optional[float] = None
    estimated_duration: Optional[int] = None
    requires_immediate_attention: bool = False
    is_safety_critical: bool = False
    recommended_action: Optional[str] = None


class InspectionStatusUpdate(BaseModel):
    status: str
    notes: Optional[str] = None


class InspectionResponse(BaseModel):
    id: int
    inspection_number: str
    customer_id: int
    status: str
    priority: str
    vehicle_make: Optional[str]
    vehicle_model: Optional[str]
    vehicle_year: Optional[int]
    created_at: datetime

    class Config:
        from_attributes = True


class InspectionDetailResponse(BaseModel):
    id: int
    inspection_number: str
    customer_id: int
    inspector_id: Optional[int]
    status: str
    priority: str
    vehicle_make: Optional[str]
    vehicle_model: Optional[str]
    vehicle_year: Optional[int]
    vehicle_vin: Optional[str]
    vehicle_license_plate: Optional[str]
    vehicle_mileage: Optional[int]
    customer_complaint: Optional[str]
    initial_assessment: Optional[str]
    recommendations: Optional[str]
    estimated_repair_cost: float
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
    except Exception:
        return False


@app.get("/", response_class=HTMLResponse)
async def root():
    frontend_path = Path("static/index.html")
    if frontend_path.exists():
        return FileResponse(frontend_path)
    
    return """
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>نظام إدارة ورش يمن الهجين</title>
        <style>
            body {
                font-family: 'Arial', sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                margin: 0;
                padding: 20px;
            }
            .container {
                max-width: 800px;
                background: rgba(255, 255, 255, 0.1);
                padding: 40px;
                border-radius: 20px;
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            }
            h1 {
                font-size: 2.5em;
                margin-bottom: 20px;
                text-align: center;
            }
            .subtitle {
                font-size: 1.5em;
                text-align: center;
                margin-bottom: 30px;
                opacity: 0.9;
            }
            .info {
                background: rgba(255, 255, 255, 0.2);
                padding: 20px;
                border-radius: 10px;
                margin: 20px 0;
            }
            .endpoint {
                margin: 10px 0;
                padding: 10px;
                background: rgba(0, 0, 0, 0.2);
                border-radius: 5px;
            }
            .endpoint a {
                color: #ffeb3b;
                text-decoration: none;
            }
            .endpoint a:hover {
                text-decoration: underline;
            }
            .status {
                display: inline-block;
                padding: 5px 15px;
                background: #4caf50;
                border-radius: 20px;
                font-weight: bold;
                margin: 5px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🔧 نظام إدارة ورش يمن الهجين</h1>
            <p class="subtitle">Yaman Hybrid Workshop Management System</p>
            
            <div class="info">
                <h2>✅ System Status</h2>
                <p><span class="status">🟢 Backend Running</span></p>
                <p><span class="status">🗄️ Database Connected</span></p>
                <p>Version: 1.0.0</p>
                <p>Environment: Replit Production</p>
            </div>
            
            <div class="info">
                <h2>📚 API Documentation</h2>
                <div class="endpoint">
                    <strong>Swagger UI:</strong> <a href="/docs" target="_blank">/docs</a>
                </div>
                <div class="endpoint">
                    <strong>ReDoc:</strong> <a href="/redoc" target="_blank">/redoc</a>
                </div>
                <div class="endpoint">
                    <strong>Health Check:</strong> <a href="/health" target="_blank">/health</a>
                </div>
            </div>
            
            <div class="info">
                <h2>🚀 Available Services</h2>
                <ul>
                    <li>👥 User Management (Authentication & Authorization)</li>
                    <li>📋 Service Catalog</li>
                    <li>🔧 Work Order Management</li>
                    <li>✅ Inspections</li>
                    <li>💬 Internal Communications</li>
                    <li>📊 Reports & Analytics</li>
                </ul>
            </div>
            
            <div class="info">
                <h2>🔑 Demo Credentials</h2>
                <p><strong>Username:</strong> admin</p>
                <p><strong>Password:</strong> admin123</p>
            </div>
        </div>
    </body>
    </html>
    """


@app.get("/health")
async def health_check(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
        db_status = "connected"
        user_count = db.query(UserModel).count()
    except Exception as e:
        db_status = f"error: {str(e)}"
        user_count = 0
    
    return {
        "status": "healthy",
        "service": "yaman_workshop_system",
        "version": "1.0.0",
        "database": db_status,
        "users_in_db": user_count
    }


@app.post("/api/v1/auth/login")
async def login(credentials: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.username == credentials.username).first()
    
    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    if not user.is_active:
        raise HTTPException(status_code=403, detail="User account is inactive")
    
    user.last_login = datetime.utcnow()
    db.commit()
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = jwt.encode(
        {"sub": user.username, "exp": datetime.utcnow() + access_token_expires},
        SECRET_KEY,
        algorithm=ALGORITHM
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "role": user.role,
            "full_name": user.full_name
        }
    }


@app.get("/api/v1/users", response_model=List[UserResponse])
async def get_users(db: Session = Depends(get_db)):
    users = db.query(UserModel).filter(UserModel.is_active == True).all()
    return users


@app.get("/api/v1/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@app.get("/api/v1/customers", response_model=List[UserResponse])
async def get_customers(db: Session = Depends(get_db)):
    customers = db.query(UserModel).filter(
        UserModel.role == 'Customer',
        UserModel.is_active == True
    ).all()
    return customers


@app.get("/api/v1/customers/{customer_id}", response_model=UserResponse)
async def get_customer(customer_id: int, db: Session = Depends(get_db)):
    customer = db.query(UserModel).filter(
        UserModel.id == customer_id,
        UserModel.role == 'Customer'
    ).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    return customer


@app.get("/api/v1/services", response_model=List[ServiceResponse])
async def get_services(db: Session = Depends(get_db)):
    services = db.query(ServiceModel).filter(ServiceModel.status == 'Available').all()
    return services


@app.get("/api/v1/services/{service_id}", response_model=ServiceResponse)
async def get_service(service_id: int, db: Session = Depends(get_db)):
    service = db.query(ServiceModel).filter(ServiceModel.id == service_id).first()
    if not service:
        raise HTTPException(status_code=404, detail="Service not found")
    return service


@app.get("/api/v1/work-orders", response_model=List[WorkOrderResponse])
async def get_work_orders(db: Session = Depends(get_db)):
    work_orders = db.query(WorkOrderModel).order_by(WorkOrderModel.created_at.desc()).all()
    return work_orders


@app.get("/api/v1/work-orders/{work_order_id}", response_model=WorkOrderResponse)
async def get_work_order(work_order_id: int, db: Session = Depends(get_db)):
    work_order = db.query(WorkOrderModel).filter(WorkOrderModel.id == work_order_id).first()
    if not work_order:
        raise HTTPException(status_code=404, detail="Work order not found")
    return work_order


@app.post("/api/v1/inspections", response_model=InspectionResponse)
async def create_inspection(inspection_data: InspectionCreate, db: Session = Depends(get_db)):
    from datetime import datetime as dt
    import uuid
    
    timestamp = dt.now().strftime('%Y%m%d%H%M%S')
    unique_id = str(uuid.uuid4())[:8]
    inspection_number = f"INS-{timestamp}-{unique_id}"
    
    new_inspection = InspectionModel(
        inspection_number=inspection_number,
        customer_id=inspection_data.customer_id,
        created_by=1,
        vehicle_make=inspection_data.vehicle_make,
        vehicle_model=inspection_data.vehicle_model,
        vehicle_year=inspection_data.vehicle_year,
        vehicle_vin=inspection_data.vehicle_vin,
        vehicle_license_plate=inspection_data.vehicle_license_plate,
        vehicle_mileage=inspection_data.vehicle_mileage,
        vehicle_color=inspection_data.vehicle_color,
        inspection_type=inspection_data.inspection_type,
        customer_complaint=inspection_data.customer_complaint,
        priority=inspection_data.priority,
        status="Draft"
    )
    
    db.add(new_inspection)
    db.commit()
    db.refresh(new_inspection)
    
    return new_inspection


@app.get("/api/v1/inspections", response_model=List[InspectionResponse])
async def get_inspections(
    status: Optional[str] = None,
    customer_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    query = db.query(InspectionModel)
    
    if status:
        query = query.filter(InspectionModel.status == status)
    if customer_id:
        query = query.filter(InspectionModel.customer_id == customer_id)
    
    inspections = query.order_by(InspectionModel.created_at.desc()).all()
    return inspections


@app.get("/api/v1/inspections/{inspection_id}", response_model=InspectionDetailResponse)
async def get_inspection(inspection_id: int, db: Session = Depends(get_db)):
    inspection = db.query(InspectionModel).filter(InspectionModel.id == inspection_id).first()
    if not inspection:
        raise HTTPException(status_code=404, detail="Inspection not found")
    return inspection


@app.put("/api/v1/inspections/{inspection_id}/status")
async def update_inspection_status(
    inspection_id: int,
    status_update: InspectionStatusUpdate,
    db: Session = Depends(get_db)
):
    ALLOWED_STATUSES = ["Draft", "Pending", "In_Progress", "Completed", "Approved", "Rejected"]
    
    if status_update.status not in ALLOWED_STATUSES:
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid status. Allowed values: {', '.join(ALLOWED_STATUSES)}"
        )
    
    inspection = db.query(InspectionModel).filter(InspectionModel.id == inspection_id).first()
    if not inspection:
        raise HTTPException(status_code=404, detail="Inspection not found")
    
    inspection.status = status_update.status
    if status_update.notes:
        inspection.notes = status_update.notes
    
    db.commit()
    db.refresh(inspection)
    
    return {"message": "Status updated successfully", "inspection_id": inspection_id, "new_status": status_update.status}


@app.post("/api/v1/inspections/{inspection_id}/faults")
async def add_inspection_fault(inspection_id: int, fault_data: InspectionFaultCreate, db: Session = Depends(get_db)):
    inspection = db.query(InspectionModel).filter(InspectionModel.id == inspection_id).first()
    if not inspection:
        raise HTTPException(status_code=404, detail="Inspection not found")
    
    if fault_data.inspection_id != inspection_id:
        raise HTTPException(status_code=400, detail="Inspection ID mismatch between path and body")
    
    new_fault = InspectionFaultModel(
        inspection_id=inspection_id,
        category=fault_data.category,
        description=fault_data.description,
        severity=fault_data.severity,
        location=fault_data.location,
        estimated_cost=fault_data.estimated_cost,
        estimated_duration=fault_data.estimated_duration,
        requires_immediate_attention=fault_data.requires_immediate_attention,
        is_safety_critical=fault_data.is_safety_critical,
        recommended_action=fault_data.recommended_action,
        created_by=1
    )
    
    db.add(new_fault)
    db.commit()
    db.refresh(new_fault)
    
    return {"message": "Fault added successfully", "fault_id": new_fault.id}


@app.get("/api/v1/inspections/{inspection_id}/faults")
async def get_inspection_faults(inspection_id: int, db: Session = Depends(get_db)):
    faults = db.query(InspectionFaultModel).filter(
        InspectionFaultModel.inspection_id == inspection_id
    ).all()
    return faults


@app.post("/api/v1/inspections/{inspection_id}/photos")
async def upload_inspection_photo(
    inspection_id: int,
    file: UploadFile = File(...),
    caption: Optional[str] = None,
    photo_type: str = "general",
    db: Session = Depends(get_db)
):
    inspection = db.query(InspectionModel).filter(InspectionModel.id == inspection_id).first()
    if not inspection:
        raise HTTPException(status_code=404, detail="Inspection not found")
    
    file_info = await save_inspection_photo(file)
    
    photo = InspectionPhotoModel(
        inspection_id=inspection_id,
        file_path=file_info["file_path"],
        file_name=file_info["file_name"],
        file_size=file_info["file_size"],
        mime_type=file_info["mime_type"],
        photo_type=photo_type,
        caption=caption,
        uploaded_by=1
    )
    
    db.add(photo)
    db.commit()
    db.refresh(photo)
    
    return {
        "message": "Photo uploaded successfully",
        "photo_id": photo.id,
        "file_name": file_info["file_name"]
    }


@app.get("/api/v1/inspections/{inspection_id}/photos")
async def get_inspection_photos(inspection_id: int, db: Session = Depends(get_db)):
    photos = db.query(InspectionPhotoModel).filter(
        InspectionPhotoModel.inspection_id == inspection_id
    ).all()
    return photos


@app.get("/api/v1/dashboard/stats", response_model=DashboardStats)
async def get_dashboard_stats(db: Session = Depends(get_db)):
    total_customers = db.query(UserModel).filter(UserModel.role == 'Customer').count()
    total_work_orders = db.query(WorkOrderModel).count()
    total_services = db.query(ServiceModel).count()
    active_work_orders = db.query(WorkOrderModel).filter(
        WorkOrderModel.status == 'In_Progress'
    ).count()
    
    today = datetime.utcnow().date()
    completed_today = db.query(WorkOrderModel).filter(
        WorkOrderModel.status == 'Completed',
        func.date(WorkOrderModel.completed_at) == today
    ).count()
    
    return {
        "total_customers": total_customers,
        "total_work_orders": total_work_orders,
        "total_services": total_services,
        "active_work_orders": active_work_orders,
        "completed_today": completed_today
    }


@app.get("/api/v1/reports/summary")
async def get_reports_summary(db: Session = Depends(get_db)):
    top_services = db.query(ServiceModel).filter(
        ServiceModel.is_featured == True
    ).limit(3).all()
    
    recent_work_orders = db.query(WorkOrderModel).order_by(
        WorkOrderModel.created_at.desc()
    ).limit(5).all()
    
    return {
        "daily_revenue": 0,
        "weekly_revenue": 0,
        "monthly_revenue": 0,
        "top_services": [
            {"id": s.id, "name": s.name, "name_ar": s.name_ar, "base_price": float(s.base_price)}
            for s in top_services
        ],
        "recent_work_orders": [
            {"id": wo.id, "order_number": wo.order_number, "title": wo.title, "status": wo.status}
            for wo in recent_work_orders
        ]
    }


@app.post("/api/v1/ai/ask")
async def ai_chatbot_ask(question: dict):
    return {
        "answer": "شكراً لسؤالك. نظام الذكاء الاصطناعي قيد التطوير حالياً. (AI system is under development)",
        "confidence": 0.5
    }


static_dir = Path("static")
if static_dir.exists():
    app.mount("/static", StaticFiles(directory="static"), name="static")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)

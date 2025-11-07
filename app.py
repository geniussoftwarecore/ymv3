"""
Yaman Hybrid Workshop Management System - Consolidated Backend
This is a consolidated FastAPI application for running on Replit without Docker
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
import os
from pathlib import Path

# Initialize FastAPI app
app = FastAPI(
    title="Yaman Workshop Management System",
    description="نظام إدارة ورش يمن الهجين - Workshop Management System",
    version="1.0.0"
)

# CORS middleware - allow all origins for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mock data storage (will be replaced with database later)
users_db = [
    {"id": 1, "username": "admin", "email": "admin@yaman.com", "role": "Admin", "full_name": "System Administrator"},
    {"id": 2, "username": "engineer1", "email": "eng1@yaman.com", "role": "Engineer", "full_name": "محمد أحمد"},
]

customers_db = [
    {"id": 1, "name": "أحمد محمد", "phone": "+967771234567", "email": "ahmed@example.com"},
    {"id": 2, "name": "فاطمة علي", "phone": "+967771234568", "email": "fatima@example.com"},
]

work_orders_db = []
inspections_db = []
services_db = [
    {"id": 1, "name": "Oil Change", "name_ar": "تغيير الزيت", "price": 5000, "duration": 30},
    {"id": 2, "name": "Brake Service", "name_ar": "خدمة الفرامل", "price": 15000, "duration": 120},
]

# Pydantic Models
class LoginRequest(BaseModel):
    username: str
    password: str

class User(BaseModel):
    id: int
    username: str
    email: str
    role: str
    full_name: str

class Customer(BaseModel):
    id: int
    name: str
    phone: str
    email: Optional[str] = None

class Service(BaseModel):
    id: int
    name: str
    name_ar: str
    price: float
    duration: int

# Root endpoint - serve frontend
@app.get("/", response_class=HTMLResponse)
async def root():
    """Serve the main frontend page"""
    frontend_path = Path("static/index.html")
    if frontend_path.exists():
        return FileResponse(frontend_path)
    
    # If no frontend file, return welcome message
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
                <p>Version: 1.0.0</p>
                <p>Environment: Replit Development</p>
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
                <h2>ℹ️ Setup Information</h2>
                <p>This system is running on Replit with a consolidated backend.</p>
                <p>📝 <strong>Note:</strong> Database setup is required for persistent data storage.</p>
                <p>The system currently uses mock data for demonstration purposes.</p>
            </div>
        </div>
    </body>
    </html>
    """

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "yaman_workshop_system",
        "version": "1.0.0",
        "database": "mock_data" if os.getenv("DATABASE_URL") is None else "connected"
    }

# API v1 Endpoints

# Authentication
@app.post("/api/v1/auth/login")
async def login(credentials: LoginRequest):
    """User login endpoint"""
    # Mock authentication - will be replaced with real auth
    for user in users_db:
        if user["username"] == credentials.username:
            # In real app, verify password hash
            return {
                "access_token": "mock_token_" + user["username"],
                "token_type": "bearer",
                "user": user
            }
    raise HTTPException(status_code=401, detail="Invalid credentials")

# Users
@app.get("/api/v1/users", response_model=List[User])
async def get_users():
    """Get all users"""
    return users_db

@app.get("/api/v1/users/{user_id}", response_model=User)
async def get_user(user_id: int):
    """Get user by ID"""
    for user in users_db:
        if user["id"] == user_id:
            return user
    raise HTTPException(status_code=404, detail="User not found")

# Customers
@app.get("/api/v1/customers", response_model=List[Customer])
async def get_customers():
    """Get all customers"""
    return customers_db

@app.get("/api/v1/customers/{customer_id}", response_model=Customer)
async def get_customer(customer_id: int):
    """Get customer by ID"""
    for customer in customers_db:
        if customer["id"] == customer_id:
            return customer
    raise HTTPException(status_code=404, detail="Customer not found")

# Services
@app.get("/api/v1/services", response_model=List[Service])
async def get_services():
    """Get all services"""
    return services_db

@app.get("/api/v1/services/{service_id}", response_model=Service)
async def get_service(service_id: int):
    """Get service by ID"""
    for service in services_db:
        if service["id"] == service_id:
            return service
    raise HTTPException(status_code=404, detail="Service not found")

# Work Orders
@app.get("/api/v1/work-orders")
async def get_work_orders():
    """Get all work orders"""
    return work_orders_db

# Inspections
@app.get("/api/v1/inspections")
async def get_inspections():
    """Get all inspections"""
    return inspections_db

# Dashboard stats
@app.get("/api/v1/dashboard/stats")
async def get_dashboard_stats():
    """Get dashboard statistics"""
    return {
        "total_customers": len(customers_db),
        "total_work_orders": len(work_orders_db),
        "total_inspections": len(inspections_db),
        "total_services": len(services_db),
        "active_work_orders": 0,
        "pending_inspections": 0,
        "completed_today": 0,
        "revenue_today": 0
    }

# Reports
@app.get("/api/v1/reports/summary")
async def get_reports_summary():
    """Get reports summary"""
    return {
        "daily_revenue": 0,
        "weekly_revenue": 0,
        "monthly_revenue": 0,
        "top_services": services_db[:3],
        "recent_work_orders": work_orders_db[:5]
    }

# AI Chatbot
@app.post("/api/v1/ai/ask")
async def ai_chatbot_ask(question: dict):
    """AI Chatbot endpoint - will integrate with OpenAI later"""
    return {
        "answer": "شكراً لسؤالك. نظام الذكاء الاصطناعي قيد التطوير حالياً. (AI system is under development)",
        "confidence": 0.5
    }

# Serve static files if they exist
static_dir = Path("static")
if static_dir.exists():
    app.mount("/static", StaticFiles(directory="static"), name="static")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)

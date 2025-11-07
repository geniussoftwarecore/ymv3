# Yaman Hybrid Workshop Management System - Replit Setup

## Project Overview
This is a comprehensive workshop management system with a microservices architecture:
- **Frontend**: HTML/JavaScript web application (Multi-language: Arabic/English)
- **Backend**: Consolidated Python FastAPI application
- **Database**: PostgreSQL (optional - currently using mock data)

## Original Architecture
The project was designed with Docker Compose running:
- PostgreSQL Database (port 5433)
- User Management Service (port 8001)
- Service Catalog Service (port 8002)
- Work Order Management Service (port 8003)
- Chat Service (port 8004)
- AI Chatbot Service (port 8005)
- Reporting Service (port 8006)
- Nginx API Gateway (port 80)

## Replit Adaptation
Since Replit doesn't support Docker or Flutter, we've adapted the project to:
1. **Consolidated Backend**: Single FastAPI app (`app.py`) running on port 5000
2. **Simple Frontend**: HTML/JavaScript web interface served by FastAPI
3. **Mock Data**: System works with in-memory data initially
4. **Database Ready**: PostgreSQL initialization script available when needed

## Current Status
- **Date**: November 7, 2025
- **Environment**: Replit (No Docker, No Flutter)
- **Setup Stage**: ✅ Basic System Running
- **Frontend**: HTML/JavaScript dashboard running on port 5000
- **Backend**: FastAPI consolidated application running on port 5000
- **Database**: Mock data (PostgreSQL initialization available)

## What's Working
- ✅ Python 3.11 with all FastAPI dependencies installed
- ✅ Consolidated FastAPI backend serving API and frontend
- ✅ HTML/JavaScript dashboard with bilingual support (Arabic/English)
- ✅ User authentication (mock)
- ✅ Customer management endpoints
- ✅ Service catalog endpoints
- ✅ Dashboard statistics
- ✅ Workflow configured and running on port 5000
- ✅ CORS configured for development

## Features Available
### Backend API Endpoints
- `GET /` - Frontend dashboard
- `GET /health` - Health check
- `POST /api/v1/auth/login` - User login
- `GET /api/v1/users` - Get all users
- `GET /api/v1/customers` - Get all customers
- `GET /api/v1/services` - Get all services
- `GET /api/v1/dashboard/stats` - Dashboard statistics
- `GET /docs` - Swagger API documentation
- `GET /redoc` - ReDoc API documentation

### Frontend Features
- Login page with demo credentials
- Dashboard with statistics cards
- Customer list view
- Service catalog view
- User management view
- Bilingual interface (Arabic/English)

## Optional: Database Setup
To enable PostgreSQL database instead of mock data:

1. **Create Database**: Use Replit's Database tab to create PostgreSQL
2. **Run Init Script**: `python init_database.py`
3. **Update app.py**: Connect to DATABASE_URL environment variable
4. **Restart**: The system will use real database

## Structure
```
/
├── backend/              # Python microservices
│   ├── services/
│   │   ├── user_management/
│   │   ├── service_catalog/
│   │   ├── work_order_management/
│   │   ├── chat/
│   │   ├── ai_chatbot/
│   │   └── reporting/
│   └── .env             # Environment variables
├── frontend/
│   └── yaman_hybrid_flutter_app/  # Flutter web app
└── database/
    └── init-scripts/    # PostgreSQL initialization
```

## Technologies
- **Frontend**: Flutter 3.0+, Dart, Riverpod
- **Backend**: Python 3.11, FastAPI, SQLAlchemy
- **Database**: PostgreSQL
- **Auth**: JWT tokens

## User Preferences
- Project supports both Arabic and English
- Focus on workshop/automotive service management
- Multi-role system (Admin, Supervisor, Engineer, Sales, Customer)

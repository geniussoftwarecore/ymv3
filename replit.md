# Yaman Hybrid Workshop Management System - Replit Setup

## Project Overview
This is a comprehensive workshop management system with a microservices architecture:
- **Frontend**: Flutter web application (Multi-language: Arabic/English)
- **Backend**: Multiple Python FastAPI microservices
- **Database**: PostgreSQL

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
Since Replit doesn't support Docker, we've adapted the project to:
1. Use Replit's built-in PostgreSQL database
2. Run backend services directly with Python/FastAPI
3. Run Flutter web app on port 5000 (frontend)
4. Backend services run on localhost with different ports

## Current Status
- **Date**: November 7, 2025
- **Environment**: Replit (No Docker)
- **Setup Stage**: ✅ Import Complete - Frontend Running
- **Frontend**: Flutter web app is building and serving on port 5000
- **Backend**: Python/FastAPI services ready, need database setup
- **Database**: Needs to be created manually via Replit Database tool

## What's Working
- ✅ Flutter SDK installed (v3.24.5)
- ✅ Python 3.11 with all FastAPI dependencies
- ✅ Frontend workflow configured and running
- ✅ Placeholder page serving while Flutter builds
- ✅ Auto-refresh mechanism (rebuilds in background)
- ✅ CORS configured for local development

## Next Steps
1. **Create Database**: Use Replit's Database tab to create PostgreSQL
2. **Run Init Scripts**: Execute SQL files from `database/init-scripts/`
3. **Start Backend**: Configure backend services to use Replit database
4. **Update API URLs**: Modify Flutter app to point to backend services
5. **Test Full Stack**: Verify frontend-backend communication

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

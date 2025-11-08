# Yaman Hybrid Workshop Management System

## Overview
Complete workshop management system for hybrid vehicle services with multi-role support, workflow automation, AI chatbot, and comprehensive reporting.

**Current Status**: Phase 2.1 Complete ✅ - Inspection System Operational
**Version**: 1.1.0
**Last Updated**: November 8, 2025

## Quick Start
- **Application URL**: Running on port 5000
- **Admin Login**: username: `admin`, password: `admin123`
- **API Documentation**: `/docs` (Swagger UI) or `/redoc`
- **Health Check**: `/health`

## Database Setup ✅
### PostgreSQL Schemas (All Created)
- `user_management` - 2 tables (users, user_sessions)
- `service_catalog` - 4 tables (categories, services, pricing, specifications)
- `work_orders` - 7 tables (work orders, tasks, inspections, quotes, signatures)
- `chat_system` - 8 tables (chat rooms, messages, notifications)
- `reporting` - Analytics and reports
- `audit_logs` - 1 table (audit trail)

**Total**: 22 database tables across 6 schemas

### Enum Types
- `user_role_enum`: Admin, Supervisor, Engineer, Sales, Customer
- `user_status_enum`: Active, Inactive, Suspended, Pending
- `work_order_status_enum`: Draft, Pending, In_Progress, On_Hold, Completed, Cancelled
- `priority_enum`: Low, Medium, High, Critical
- `service_status_enum`: Available, Unavailable, Discontinued

## Technology Stack
### Backend
- **Framework**: FastAPI 0.121.0
- **Database**: PostgreSQL (Replit managed)
- **ORM**: SQLAlchemy 2.0.44
- **Authentication**: JWT (python-jose)
- **Password Hashing**: bcrypt
- **Server**: Uvicorn (ASGI)

### Key Packages
- pydantic (validation)
- psycopg2-binary (PostgreSQL adapter)
- python-multipart (file uploads)
- httpx, requests (HTTP clients)

## Development Roadmap

### ✅ Phase 1: Foundation & Database (COMPLETE)
- [x] PostgreSQL setup with all schemas
- [x] Complete data models (22 tables)
- [x] Admin user created
- [x] Sample data loaded

### 🚀 Phase 2: Core Workflow (IN PROGRESS)
- [x] 2.1: Inspection system with file uploads ✅
  - Collision-resistant inspection numbering (UUID-based)
  - File upload system with validation
  - Fault tracking and photo management
  - 8 REST API endpoints operational
- [ ] 2.2: Sales & quote generation with e-signatures
- [ ] 2.3: Work order execution with engineer task tracking
- [ ] 2.4: Supervisor quality check
- [ ] 2.5: Delivery with customer signature

### 📋 Phase 3: Communication & AI
- [ ] 3.1: AI chatbot integration (OpenAI/Gemini)
- [ ] 3.2: Internal chat system (Engineer ↔ Sales ↔ Supervisor ↔ Admin)
- [ ] 3.3: Customer ↔ Sales chat
- [ ] 3.4: WhatsApp & Email notifications

### 📋 Phase 4: Analytics & Reporting
- [ ] 4.1: Dashboard statistics
- [ ] 4.2: Performance reports
- [ ] 4.3: Revenue analytics
- [ ] 4.4: Engineer performance tracking

### 📋 Phase 5: Role-Based UI
- [ ] 5.1: Custom dashboards for each role
- [ ] 5.2: Permissions system
- [ ] 5.3: All workflow screens

### 📋 Phase 6: External Integrations
- [ ] 6.1: WhatsApp API (use Replit integrations)
- [ ] 6.2: Gmail/Email service
- [ ] 6.3: OpenAI/Gemini for chatbot

## Project Structure
```
/
├── app.py              # Main FastAPI application (600+ lines)
├── database.py         # Database connection & session management
├── models.py           # SQLAlchemy ORM models (500+ lines)
├── file_utils.py       # File upload utilities & validation
├── init_database.py    # Database initialization script
├── uploads/            # File storage
│   └── inspections/    # Inspection photos & attachments
├── database/
│   └── init-scripts/   # SQL initialization scripts
├── static/             # Frontend static files
│   └── index.html      # Login page
└── backend/            # Microservices (legacy structure)
    └── services/       # Individual service components
```

## API Endpoints (Current)
### Authentication
- `POST /api/v1/auth/login` - User login with JWT

### Users & Customers
- `GET /api/v1/users` - List all users
- `GET /api/v1/users/{id}` - Get user by ID
- `GET /api/v1/customers` - List customers
- `GET /api/v1/customers/{id}` - Get customer by ID

### Services
- `GET /api/v1/services` - List available services
- `GET /api/v1/services/{id}` - Get service details

### Work Orders
- `GET /api/v1/work-orders` - List work orders
- `GET /api/v1/work-orders/{id}` - Get work order details

### Inspections ✨ NEW
- `POST /api/v1/inspections` - Create new inspection
- `GET /api/v1/inspections` - List all inspections
- `GET /api/v1/inspections/{id}` - Get inspection details with faults
- `PUT /api/v1/inspections/{id}/status` - Update inspection status
- `POST /api/v1/inspections/{id}/faults` - Add fault to inspection
- `GET /api/v1/inspections/{id}/faults` - List inspection faults
- `POST /api/v1/inspections/{id}/photos` - Upload inspection photo
- `GET /api/v1/inspections/{id}/photos` - Get inspection photos

### Dashboard & Reports
- `GET /api/v1/dashboard/stats` - Dashboard statistics
- `GET /api/v1/reports/summary` - Reports summary

### System
- `GET /` - Landing page with system info
- `GET /health` - Health check endpoint
- `GET /docs` - Swagger API documentation
- `GET /redoc` - ReDoc API documentation

## Environment Variables (Available)
- `DATABASE_URL` - PostgreSQL connection string
- `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE` - DB credentials
- `SECRET_KEY` - JWT secret (update in production)

## User Roles & Permissions (Planned)
1. **Admin**: Full system access, user management, system configuration
2. **Supervisor**: Quality checks, approval workflows, team oversight
3. **Engineer**: Work order execution, task completion, technical updates
4. **Sales**: Customer interaction, quote generation, service catalog
5. **Customer**: View work orders, chat with sales, approve quotes, signatures

## Workflow Phases (Planned)
1. **Inspection** → 2. **Quote** → 3. **Approval** → 4. **Work Order** → 5. **Quality Check** → 6. **Delivery** → 7. **Payment**

## Development Notes
- Application binds to `0.0.0.0:5000` (required for Replit)
- CORS enabled for all origins (configure for production)
- Database uses connection pooling (10 connections, 20 max overflow)
- JWT tokens expire after 30 minutes

## Implementation Details

### Phase 2.1: Inspection System
**Architecture Decisions:**
- Collision-resistant inspection numbering: `INS-YYYYMMDDHHMMSS-UUID8`
- Status workflow validation: Draft → Pending → In_Progress → Completed → Approved/Rejected
- Path/body ID validation for security
- File upload with size limits (10MB) and type validation (images only)

**Models Created:**
1. `Inspection` - Main inspection record with vehicle details
2. `InspectionFault` - Individual faults/issues found during inspection
3. `InspectionPhoto` - Photo attachments with metadata

**File Upload System:**
- Supported formats: JPEG, PNG, GIF, WebP
- Max file size: 10MB per file
- Storage: `/uploads/inspections/`
- Validation: MIME type checking, file extension verification

## Next Steps
1. Phase 2.2: Build quote generation system with e-signatures
2. Search for Replit integrations for e-signature service
3. Implement role-based access control middleware
4. Build frontend UI for inspection workflow

## Notes
- Replit PostgreSQL database is development only
- Use Replit integrations for API keys (WhatsApp, OpenAI, Email)
- LSP warnings about imports are normal and don't affect runtime

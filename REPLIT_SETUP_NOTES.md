# Yaman Workshop System - Replit Setup Notes

## Overview
This project has been successfully imported into Replit from GitHub. The original architecture used Docker Compose to run multiple microservices, which is not supported in Replit. The setup has been adapted to work within Replit's constraints.

## What's Currently Running ✅

### Frontend (Port 5000)
- **Flutter Web Application**: Building and serving on port 5000
- **Status**: RUNNING
- **URL**: Accessible via the Replit webview
- **Build Process**: Flutter is compiling the web app in the background
  - Initial placeholder page shows while building
  - Auto-refreshes every 10 seconds
  - Full app will be available once build completes

## Original Architecture (Docker-based)

The project was designed with these microservices:
1. **PostgreSQL Database** (port 5433)
2. **User Management Service** (port 8001) - Python/FastAPI
3. **Service Catalog Service** (port 8002) - Python/FastAPI
4. **Work Order Management** (port 8003) - Python/FastAPI
5. **Chat Service** (port 8004) - Python/FastAPI
6. **AI Chatbot Service** (port 8005) - Python/FastAPI
7. **Reporting Service** (port 8006) - Python/FastAPI
8. **Nginx API Gateway** (port 80)

## Replit Adaptations

### What's Working
- ✅ Flutter SDK installed and configured
- ✅ Python 3.11 with all backend dependencies installed
- ✅ Frontend workflow configured and running on port 5000
- ✅ Build script handles Flutter compilation
- ✅ Simple Python HTTP server serves the Flutter web build

### What Needs Configuration
- ⚠️ **Database**: Replit's PostgreSQL database needs to be manually created
  - Go to the "Database" tab in Replit
  - Create a PostgreSQL database
  - Database credentials will be auto-injected as environment variables
  
- ⚠️ **Backend Services**: The microservices need to be adapted
  - Option 1: Run a single unified FastAPI service
  - Option 2: Set up additional workflows for individual services
  - Services are ready in `backend/services/` but need database setup

- ⚠️ **API Configuration**: Flutter app needs backend URL updates
  - File: `frontend/yaman_hybrid_flutter_app/lib/core/api/api_constants.dart`
  - Currently points to localhost:8001, 8002, etc.
  - Should be updated to use Replit's environment variables

## File Structure

```
/
├── build_and_serve.sh          # Main build and server script
├── serve_frontend.py            # Python HTTP server for Flutter web
├── backend/
│   ├── .env                     # Environment variables (CORS updated)
│   └── services/                # FastAPI microservices (ready to run)
├── frontend/
│   └── yaman_hybrid_flutter_app/
│       ├── lib/                 # Flutter application code
│       ├── pubspec.yaml         # Flutter dependencies
│       └── build/web/           # Compiled web output (generated)
└── database/
    └── init-scripts/            # PostgreSQL initialization scripts
```

## Current Workflow

**Name**: Flutter Web App  
**Command**: `./build_and_serve.sh`  
**Port**: 5000  
**Type**: Webview

### What the workflow does:
1. Sets up Flutter environment (PATH)
2. Checks if Flutter build exists
3. If not, starts background build process
4. Creates placeholder HTML while building
5. Starts Python HTTP server on port 5000
6. Serves the Flutter web app

## Next Steps for Full Functionality

### 1. Set Up Database
```bash
# Use Replit's database tool to create PostgreSQL database
# Then run initialization scripts:
psql $DATABASE_URL < database/init-scripts/01-init-database.sql
psql $DATABASE_URL < database/init-scripts/02-service-catalog.sql
psql $DATABASE_URL < database/init-scripts/03-work-orders.sql
psql $DATABASE_URL < database/init-scripts/04-chat-system.sql
```

### 2. Update Flutter API Configuration
Edit `frontend/yaman_hybrid_flutter_app/lib/core/api/api_constants.dart`:
```dart
class APIConstants {
  // Use Replit environment or unified backend
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8001'
  );
  // ... rest of configuration
}
```

### 3. Run Backend Services
Option A - Unified Service (Recommended for Replit):
```bash
# Create a unified FastAPI app that combines all services
# Run on port 8001
```

Option B - Multiple Services:
```bash
# Set up additional workflows for each service
# Note: Replit has port limitations
```

### 4. Configure Deployment
Once everything works:
```bash
# Use Replit's deployment tool
# Configure for Autoscale (stateless) or VM (stateful)
```

## Environment Variables

Currently configured in `backend/.env`:
- `POSTGRES_DB`: yaman_workshop_db
- `POSTGRES_USER`: yaman_user
- `POSTGRES_PASSWORD`: yaman_password123
- `SECRET_KEY`: (should be changed in production)
- `BACKEND_CORS_ORIGINS`: Updated to include port 5000

## Troubleshooting

### Flutter Build Issues
- Check `/tmp/flutter_build.log` for build progress
- Build can take 5-10 minutes first time
- Placeholder page will show until build completes

### Port 5000 Not Responding
- Check workflow logs in Replit
- Ensure build script has execute permissions: `chmod +x build_and_serve.sh`
- Restart workflow if needed

### Backend Services Not Working
- Database must be created first
- Environment variables must be set
- Check individual service logs

## Technology Stack

- **Frontend**: Flutter 3.24+, Dart 3.8
- **Backend**: Python 3.11, FastAPI, SQLAlchemy
- **Database**: PostgreSQL 16 (Neon-hosted via Replit)
- **Server**: Python HTTP server (development)
- **State Management**: Riverpod
- **Localization**: Arabic + English

## Features Implemented (Frontend)

✅ Authentication system  
✅ Dashboard with stats  
✅ User management (multi-role)  
✅ Work order interface  
✅ Chat system UI  
✅ AI assistant UI  
✅ Reports and analytics  
✅ Bilingual support (AR/EN)  
✅ Responsive design  

## Backend Status

✅ User Management Service - Complete with API  
⚠️ Service Catalog - Basic structure  
⚠️ Work Orders - Basic structure  
⚠️ Chat - Basic structure  
⚠️ AI Chatbot - Basic structure  
⚠️ Reporting - Basic structure  

## Security Notes

⚠️ **Important**: Change these before production:
- `SECRET_KEY` in `.env`
- Default admin password
- Database credentials
- Enable HTTPS for deployment

## Support

For issues:
1. Check workflow logs in Replit
2. Review `/tmp/flutter_build.log` for build issues
3. Check backend service logs
4. Review original documentation in `README.md`

---

**Setup Date**: November 7, 2025  
**Platform**: Replit  
**Original Source**: GitHub Import  
**Status**: Frontend running, backend needs configuration

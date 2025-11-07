# Yaman Workshop Management System - Quick Start Guide

## 🚀 Getting Started

Your Yaman Workshop Management System is now running on Replit!

### ✅ What's Already Set Up

- **Backend API**: FastAPI application running on port 5000
- **Frontend Dashboard**: HTML/JavaScript interface
- **Workflow**: Automatically starts when you run the project
- **API Documentation**: Available at `/docs` and `/redoc`

### 📱 Access the Application

1. **Click the "Webview" button** at the top of Replit
2. **Or visit**: Your Replit URL will be displayed in the webview

### 🔐 Login Credentials

Use these demo credentials to log in:

```
Username: admin
Password: (any password will work in demo mode)
```

### 📚 Available Features

#### Dashboard
- View statistics for customers, work orders, inspections, and services
- Bilingual interface (Arabic/English)

#### Customer Management
- View customer list
- See customer contact information

#### Service Catalog
- Browse available services
- View pricing and duration

#### User Management
- View system users
- See user roles and permissions

### 🔧 API Endpoints

Your API is available at these endpoints:

- **API Documentation**: `/docs` (Swagger UI)
- **Alternative Docs**: `/redoc` (ReDoc)
- **Health Check**: `/health`
- **Login**: `POST /api/v1/auth/login`
- **Users**: `GET /api/v1/users`
- **Customers**: `GET /api/v1/customers`
- **Services**: `GET /api/v1/services`
- **Dashboard Stats**: `GET /api/v1/dashboard/stats`

### 📊 Database Setup (Optional)

Currently, the system uses mock data. To connect to a real PostgreSQL database:

1. **Create Database**:
   - Click on the "Database" tab in Replit
   - Create a PostgreSQL database
   - Replit will automatically set the `DATABASE_URL` environment variable

2. **Initialize Database**:
   ```bash
   python init_database.py
   ```

3. **Update Application**:
   - Modify `app.py` to use the database instead of mock data
   - Restart the application

### 🛠️ Development

#### View Logs
Click on the "Console" tab to see application logs.

#### Restart Application
Click the "Stop" button and then "Run" to restart.

#### API Testing
Use the Swagger UI at `/docs` to test API endpoints interactively.

### 📁 Project Structure

```
/
├── app.py                  # Main application (backend + frontend)
├── static/
│   └── index.html         # Frontend dashboard
├── backend/               # Original microservices (for reference)
│   └── services/
├── database/              # Database initialization scripts
│   └── init-scripts/
└── init_database.py       # Database setup helper
```

### 🎯 Next Steps

1. **Explore the Dashboard**: Log in and check out the features
2. **Test the API**: Visit `/docs` to interact with the API
3. **Add Database**: Set up PostgreSQL for persistent data
4. **Customize**: Modify the frontend or add new API endpoints
5. **Deploy**: Click "Deploy" to publish your app to the internet

### 📖 Documentation

- **API Docs**: Visit `/docs` for interactive API documentation
- **ReDoc**: Visit `/redoc` for detailed API reference
- **Original Docs**: See `README.md` for the full project documentation

### ⚙️ Configuration

The application is configured to:
- Run on port 5000 (required by Replit)
- Accept connections from all hosts (0.0.0.0)
- Enable CORS for development
- Serve both API and frontend from a single process

### 🐛 Troubleshooting

**Application not loading?**
- Check the Console tab for errors
- Click "Stop" and "Run" to restart
- Ensure the workflow is running

**Database errors?**
- The system works without a database using mock data
- Database setup is optional and can be done later

**API not responding?**
- Check `/health` endpoint to verify the server is running
- Look at the Console logs for any errors

### 🤝 Support

For issues or questions:
- Check the API documentation at `/docs`
- Review the logs in the Console tab
- See `README.md` for detailed project information

---

**Made with ❤️ for the Yaman community**

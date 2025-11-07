@echo off
echo ========================================
echo    Yaman Hybrid Workshop Setup Script
echo         Windows Environment
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not in PATH
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

REM Check if Docker Compose is available
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker Compose is not available
    echo Please ensure Docker Desktop is properly installed
    pause
    exit /b 1
)

echo ✓ Docker is installed and available
echo.

REM Create .env file if it doesn't exist
if not exist .env (
    echo Creating .env file with default configuration...
    (
        echo # Database Configuration
        echo POSTGRES_DB=yaman_workshop_db
        echo POSTGRES_USER=yaman_user
        echo POSTGRES_PASSWORD=yaman_password123
        echo.
        echo # Security Configuration
        echo SECRET_KEY=your-super-secret-key-change-in-production-minimum-32-characters
        echo ALGORITHM=HS256
        echo ACCESS_TOKEN_EXPIRE_MINUTES=30
        echo.
        echo # External APIs
        echo OPENAI_API_KEY=your-openai-api-key-here
        echo.
        echo # CORS Configuration
        echo BACKEND_CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080", "http://127.0.0.1:3000"]
    ) > .env
    echo ✓ .env file created
) else (
    echo ✓ .env file already exists
)
echo.

REM Create __init__.py files for Python packages
echo Creating Python package files...
if not exist services\user_management\__init__.py (
    type nul > services\user_management\__init__.py
)
if not exist services\user_management\api\__init__.py (
    type nul > services\user_management\api\__init__.py
)
if not exist services\user_management\api\v1\__init__.py (
    type nul > services\user_management\api\v1\__init__.py
)
if not exist services\user_management\core\__init__.py (
    type nul > services\user_management\core\__init__.py
)
if not exist services\user_management\crud\__init__.py (
    type nul > services\user_management\crud\__init__.py
)
if not exist services\user_management\db\__init__.py (
    type nul > services\user_management\db\__init__.py
)
if not exist services\user_management\schemas\__init__.py (
    type nul > services\user_management\schemas\__init__.py
)
echo ✓ Python package files created
echo.

REM Stop any existing containers
echo Stopping any existing containers...
docker-compose down >nul 2>&1
echo ✓ Existing containers stopped
echo.

REM Build and start services
echo Building and starting services...
echo This may take several minutes on first run...
echo.

docker-compose up --build -d db
if %errorlevel% neq 0 (
    echo ERROR: Failed to start database service
    pause
    exit /b 1
)

echo ✓ Database service started
echo Waiting for database to be ready...
timeout /t 10 /nobreak >nul

docker-compose up --build -d user_management
if %errorlevel% neq 0 (
    echo WARNING: User management service failed to start
    echo Check logs with: docker-compose logs user_management
) else (
    echo ✓ User management service started
)

echo.
echo ========================================
echo           Setup Complete!
echo ========================================
echo.
echo Services Status:
docker-compose ps
echo.
echo Available endpoints:
echo - User Management: http://localhost:8001
echo - Database: localhost:5433
echo.
echo To view logs: docker-compose logs [service_name]
echo To stop all services: docker-compose down
echo.
echo Press any key to exit...
pause >nul

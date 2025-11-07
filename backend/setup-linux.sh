#!/bin/bash

echo "========================================"
echo "   Yaman Hybrid Workshop Setup Script"
echo "       Linux/macOS Environment"
echo "========================================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not available"
    echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
    exit 1
fi

print_success "Docker and Docker Compose are available"
echo

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file with default configuration..."
    cat > .env << EOF
# Database Configuration
POSTGRES_DB=yaman_workshop_db
POSTGRES_USER=yaman_user
POSTGRES_PASSWORD=yaman_password123

# Security Configuration
SECRET_KEY=your-super-secret-key-change-in-production-minimum-32-characters
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# External APIs
OPENAI_API_KEY=your-openai-api-key-here

# CORS Configuration
BACKEND_CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080", "http://127.0.0.1:3000"]
EOF
    print_success ".env file created"
else
    print_success ".env file already exists"
fi
echo

# Create __init__.py files for Python packages
echo "Creating Python package files..."
mkdir -p services/user_management/{api/v1,core,crud,db,schemas}
touch services/user_management/__init__.py
touch services/user_management/api/__init__.py
touch services/user_management/api/v1/__init__.py
touch services/user_management/core/__init__.py
touch services/user_management/crud/__init__.py
touch services/user_management/db/__init__.py
touch services/user_management/schemas/__init__.py
print_success "Python package files created"
echo

# Stop any existing containers
echo "Stopping any existing containers..."
docker-compose down &> /dev/null
print_success "Existing containers stopped"
echo

# Build and start services
echo "Building and starting services..."
echo "This may take several minutes on first run..."
echo

if docker-compose up --build -d db; then
    print_success "Database service started"
else
    print_error "Failed to start database service"
    exit 1
fi

echo "Waiting for database to be ready..."
sleep 10

if docker-compose up --build -d user_management; then
    print_success "User management service started"
else
    print_warning "User management service failed to start"
    echo "Check logs with: docker-compose logs user_management"
fi

echo
echo "========================================"
echo "          Setup Complete!"
echo "========================================"
echo

echo "Services Status:"
docker-compose ps
echo

echo "Available endpoints:"
echo "- User Management: http://localhost:8001"
echo "- Database: localhost:5433"
echo

echo "Useful commands:"
echo "- View logs: docker-compose logs [service_name]"
echo "- Stop all services: docker-compose down"
echo "- Restart services: docker-compose restart"
echo

# Test connection
echo "Testing connection to user management service..."
sleep 5
if curl -s http://localhost:8001/ > /dev/null; then
    print_success "User management service is responding"
else
    print_warning "User management service is not responding yet"
    echo "You may need to check the logs: docker-compose logs user_management"
fi

echo
echo "Setup completed successfully!"

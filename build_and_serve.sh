#!/bin/bash

export PATH="$HOME/flutter/bin:$PATH"

echo "========================================="
echo "Yaman Workshop Management System"
echo "========================================="

cd frontend/yaman_hybrid_flutter_app

# Check if build already exists
if [ ! -d "build/web" ]; then
    echo "Flutter build not found. Building in background..."
    (
        flutter pub get
        flutter build web --release 
        echo "Build completed!"
    ) > /tmp/flutter_build.log 2>&1 &
    
    echo "Build started in background. Serving placeholder..."
    sleep 2
fi

cd ../..

# Create a simple placeholder HTML if build doesn't exist yet
if [ ! -d "frontend/yaman_hybrid_flutter_app/build/web" ]; then
    mkdir -p frontend/yaman_hybrid_flutter_app/build/web
    cat > frontend/yaman_hybrid_flutter_app/build/web/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yaman Workshop - Building...</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        h1 {
            font-size: 2.5em;
            margin-bottom: 20px;
        }
        .spinner {
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top: 4px solid white;
            width: 60px;
            height: 60px;
            animation: spin 1s linear infinite;
            margin: 30px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        p {
            font-size: 1.2em;
            margin-top: 20px;
        }
    </style>
    <script>
        setTimeout(() => window.location.reload(), 10000);
    </script>
</head>
<body>
    <div class="container">
        <h1>🚗 Yaman Workshop Management System</h1>
        <div class="spinner"></div>
        <p>Application is building, please wait...</p>
        <p style="font-size: 0.9em; opacity: 0.8;">This page will auto-refresh in 10 seconds</p>
    </div>
</body>
</html>
EOF
fi

echo "Starting web server on port 5000..."
python3 serve_frontend.py

#!/usr/bin/env python3
import http.server
import socketserver
import os
import sys

PORT = 5000
DIRECTORY = "frontend/yaman_hybrid_flutter_app/build/web"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()

def main():
    if not os.path.exists(DIRECTORY):
        print(f"Error: Build directory '{DIRECTORY}' not found!")
        print("Please build the Flutter web app first with: flutter build web")
        sys.exit(1)
    
    with socketserver.TCPServer(("0.0.0.0", PORT), MyHTTPRequestHandler) as httpd:
        print(f"Serving Flutter web app at http://0.0.0.0:{PORT}")
        print(f"Directory: {DIRECTORY}")
        print("Press Ctrl+C to stop the server")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
            sys.exit(0)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Backend runner script with proper error handling and logging
"""

import uvicorn
import os
import sys
from pathlib import Path

def check_dependencies():
    """Check if required dependencies are installed"""
    required_packages = ['fastapi', 'uvicorn', 'python-multipart', 'requests']
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print(f"❌ Missing required packages: {', '.join(missing_packages)}")
        print("Install them with: pip install " + " ".join(missing_packages))
        return False
    
    print("✅ All required packages are installed")
    return True

def check_environment():
    """Check environment configuration"""
    print("🔍 Checking environment configuration...")
    
    # Check Google Cloud credentials
    creds_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    if creds_path and os.path.exists(creds_path):
        print(f"✅ Google Cloud credentials: {creds_path}")
    else:
        print("⚠️  Google Cloud credentials not found (will use mock responses)")
    
    # Check Gemini API key
    gemini_key = os.getenv("GEMINI_API_KEY")
    if gemini_key and gemini_key != "your-gemini-api-key":
        print("✅ Gemini API key is configured")
    else:
        print("⚠️  Gemini API key not configured (will use mock responses)")
    
    return True

def main():
    """Main function to run the backend server"""
    print("🚀 Starting Senior Medicine App Backend")
    print("=" * 50)
    
    # Check dependencies
    if not check_dependencies():
        sys.exit(1)
    
    # Check environment
    check_environment()
    
    print("\n🌐 Starting server...")
    print("Backend will be available at: http://localhost:8000")
    print("API documentation at: http://localhost:8000/docs")
    print("Health check at: http://localhost:8000/health")
    print("\nPress Ctrl+C to stop the server")
    print("=" * 50)
    
    try:
        # Import and run the FastAPI app
        from main import app
        uvicorn.run(
            app,
            host="0.0.0.0",
            port=8000,
            log_level="info",
            reload=True
        )
    except ImportError as e:
        print(f"❌ Error importing main app: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n👋 Server stopped by user")
    except Exception as e:
        print(f"❌ Server error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

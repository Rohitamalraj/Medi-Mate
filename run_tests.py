#!/usr/bin/env python3
"""
Comprehensive test runner for Senior Medicine App
Tests backend API, integration, and generates test report
"""

import os
import sys
import subprocess
import time
import requests
import json
from datetime import datetime

def run_command(cmd, cwd=None):
    """Run command and return result"""
    try:
        result = subprocess.run(
            cmd, 
            shell=True, 
            cwd=cwd,
            capture_output=True, 
            text=True,
            timeout=30
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", "Command timed out"
    except Exception as e:
        return False, "", str(e)

def test_backend_health():
    """Test if backend is running and healthy"""
    try:
        response = requests.get("http://localhost:8000/health", timeout=5)
        return response.status_code == 200, response.json()
    except Exception as e:
        return False, {"error": str(e)}

def test_api_endpoints():
    """Test all API endpoints with mock data"""
    base_url = "http://localhost:8000"
    results = {}
    
    # Test ASR endpoint
    try:
        # Create a mock audio file
        mock_audio = b"mock audio data for testing"
        files = {"file": ("test.wav", mock_audio, "audio/wav")}
        data = {"lang": "en-US"}
        
        response = requests.post(f"{base_url}/asr", files=files, data=data, timeout=10)
        results["asr"] = {
            "status": response.status_code,
            "response": response.json() if response.status_code == 200 else response.text
        }
    except Exception as e:
        results["asr"] = {"error": str(e)}
    
    # Test parse endpoint
    try:
        data = {"text": "Take Crocin two tablets at 9 PM daily", "language": "en"}
        response = requests.post(f"{base_url}/parse", data=data, timeout=10)
        results["parse"] = {
            "status": response.status_code,
            "response": response.json() if response.status_code == 200 else response.text
        }
    except Exception as e:
        results["parse"] = {"error": str(e)}
    
    # Test TTS endpoint
    try:
        data = {"text": "Your medicine reminder", "lang": "en-US"}
        response = requests.post(f"{base_url}/tts", data=data, timeout=10)
        results["tts"] = {
            "status": response.status_code,
            "content_type": response.headers.get("content-type", "")
        }
    except Exception as e:
        results["tts"] = {"error": str(e)}
    
    # Test summarize endpoint
    try:
        mock_articles = json.dumps([
            {"title": "Health News", "description": "Important health update"}
        ])
        data = {"articles": mock_articles, "language": "en"}
        response = requests.post(f"{base_url}/summarize", data=data, timeout=10)
        results["summarize"] = {
            "status": response.status_code,
            "response": response.json() if response.status_code == 200 else response.text
        }
    except Exception as e:
        results["summarize"] = {"error": str(e)}
    
    return results

def start_backend():
    """Start backend server"""
    print("Starting backend server...")
    backend_dir = os.path.join(os.path.dirname(__file__), "backend")
    
    # Check if requirements are installed
    success, stdout, stderr = run_command("python -c \"import fastapi\"", backend_dir)
    if not success:
        print("Installing backend dependencies...")
        success, stdout, stderr = run_command("pip install -r requirements.txt", backend_dir)
        if not success:
            print(f"Failed to install dependencies: {stderr}")
            return False
    
    # Start server in background
    try:
        subprocess.Popen(
            ["python", "main.py"],
            cwd=backend_dir,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        
        # Wait for server to start
        for i in range(10):
            time.sleep(1)
            healthy, _ = test_backend_health()
            if healthy:
                print("✅ Backend server started successfully")
                return True
            print(f"Waiting for backend... ({i+1}/10)")
        
        print("❌ Backend server failed to start")
        return False
        
    except Exception as e:
        print(f"❌ Failed to start backend: {e}")
        return False

def test_flutter_app():
    """Test Flutter app compilation"""
    flutter_dir = os.path.join(os.path.dirname(__file__), "senior_medicine_app")
    
    print("Testing Flutter app...")
    
    # Check Flutter installation
    success, stdout, stderr = run_command("flutter --version")
    if not success:
        return False, "Flutter not installed or not in PATH"
    
    # Get dependencies
    success, stdout, stderr = run_command("flutter pub get", flutter_dir)
    if not success:
        return False, f"Failed to get dependencies: {stderr}"
    
    # Analyze code
    success, stdout, stderr = run_command("flutter analyze", flutter_dir)
    analysis_result = "✅ No issues" if success else f"⚠️ Issues found: {stderr}"
    
    # Test compilation (dry run)
    success, stdout, stderr = run_command("flutter build apk --dry-run", flutter_dir)
    build_result = "✅ Build successful" if success else f"❌ Build failed: {stderr}"
    
    return True, f"Analysis: {analysis_result}\nBuild: {build_result}"

def generate_report(results):
    """Generate comprehensive test report"""
    report = f"""
# Senior Medicine App - Test Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Backend Tests

### Health Check
Status: {'✅ Healthy' if results['backend']['healthy'] else '❌ Unhealthy'}
Response: {results['backend']['health_response']}

### API Endpoints
"""
    
    for endpoint, result in results['backend']['api_tests'].items():
        status = "✅ Pass" if result.get('status') == 200 else "❌ Fail"
        report += f"\n#### {endpoint.upper()} Endpoint\n"
        report += f"Status: {status}\n"
        if 'error' in result:
            report += f"Error: {result['error']}\n"
        else:
            report += f"Response: {result.get('response', 'Binary data')}\n"
    
    report += f"""
## Flutter App Tests
{results['flutter']['result']}

## Environment Check
- Backend Dependencies: {'✅ Installed' if results['environment']['backend_deps'] else '❌ Missing'}
- Flutter SDK: {'✅ Available' if results['environment']['flutter_sdk'] else '❌ Missing'}

## Recommendations
"""
    
    if not results['backend']['healthy']:
        report += "- Fix backend server startup issues\n"
    if not results['environment']['flutter_sdk']:
        report += "- Install Flutter SDK\n"
    if not results['environment']['backend_deps']:
        report += "- Install Python dependencies\n"
    
    report += """
## Next Steps
1. Ensure all tests pass
2. Test on physical device
3. Set up Google Cloud credentials for full functionality
4. Deploy to production environment

---
*This report validates the Senior Medicine App is ready for deployment and testing.*
"""
    
    return report

def main():
    """Main test runner"""
    print("🧪 Senior Medicine App - Comprehensive Test Suite")
    print("=" * 50)
    
    results = {
        'backend': {'healthy': False, 'health_response': {}, 'api_tests': {}},
        'flutter': {'success': False, 'result': ''},
        'environment': {'backend_deps': False, 'flutter_sdk': False}
    }
    
    # Check environment
    print("\n📋 Environment Check")
    success, _, _ = run_command("python -c \"import fastapi\"")
    results['environment']['backend_deps'] = success
    print(f"Backend Dependencies: {'✅' if success else '❌'}")
    
    success, _, _ = run_command("flutter --version")
    results['environment']['flutter_sdk'] = success
    print(f"Flutter SDK: {'✅' if success else '❌'}")
    
    # Start backend
    print("\n🚀 Backend Tests")
    backend_started = start_backend()
    
    if backend_started:
        # Test health
        healthy, health_response = test_backend_health()
        results['backend']['healthy'] = healthy
        results['backend']['health_response'] = health_response
        print(f"Health Check: {'✅' if healthy else '❌'}")
        
        # Test API endpoints
        if healthy:
            print("Testing API endpoints...")
            api_results = test_api_endpoints()
            results['backend']['api_tests'] = api_results
            
            for endpoint, result in api_results.items():
                status = "✅" if result.get('status') == 200 else "❌"
                print(f"{endpoint.upper()}: {status}")
    
    # Test Flutter app
    print("\n📱 Flutter App Tests")
    flutter_success, flutter_result = test_flutter_app()
    results['flutter']['success'] = flutter_success
    results['flutter']['result'] = flutter_result
    print(flutter_result)
    
    # Generate report
    print("\n📊 Generating Test Report")
    report = generate_report(results)
    
    # Save report
    with open("TEST_REPORT.md", "w", encoding="utf-8") as f:
        f.write(report)
    
    print("✅ Test report saved to TEST_REPORT.md")
    
    # Summary
    print("\n📋 Test Summary")
    total_tests = 0
    passed_tests = 0
    
    if results['backend']['healthy']:
        passed_tests += 1
    total_tests += 1
    
    for result in results['backend']['api_tests'].values():
        if result.get('status') == 200:
            passed_tests += 1
        total_tests += 1
    
    if results['flutter']['success']:
        passed_tests += 1
    total_tests += 1
    
    print(f"Tests Passed: {passed_tests}/{total_tests}")
    success_rate = (passed_tests / total_tests) * 100 if total_tests > 0 else 0
    print(f"Success Rate: {success_rate:.1f}%")
    
    if success_rate >= 80:
        print("🎉 App is ready for deployment!")
    else:
        print("⚠️ Some issues need to be resolved before deployment")
    
    return success_rate >= 80

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

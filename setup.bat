@echo off
echo ===================================================
echo   YouTube Shorts Factory - First-Time Setup
echo ===================================================
echo.

:: Check for Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in your system PATH.
    echo Please install Python 3.10+ from python.org and check "Add to PATH".
    pause
    exit /b 1
)

echo [1/4] Creating virtual environment (venv)...
if not exist "venv" (
    python -m venv venv
) else (
    echo Venv already exists. Skipping.
)

echo.
echo [2/4] Installing dependencies from requirements.txt...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip >nul 2>&1
pip install -r requirements.txt

echo.
echo [3/4] Generating required folder structure...
mkdir assets\backgrounds 2>nul
mkdir assets\music 2>nul
mkdir assets\templates 2>nul
mkdir assets\voices 2>nul
mkdir config 2>nul
mkdir data 2>nul
mkdir logs 2>nul
mkdir output\shorts 2>nul

echo.
echo [4/4] Checking environment configurations...
if not exist ".env" (
    if exist ".env.example" (
        copy .env.example .env >nul
        echo Created .env from .env.example. Please open .env and add your API Keys.
    ) else (
        echo [WARNING] .env.example not found. You will need to create a .env file manually.
    )
) else (
    echo .env already exists.
)

echo.
echo ===================================================
echo   Setup Complete!
echo ===================================================
echo Please ensure you have:
echo 1. Installed FFmpeg and added it to your system PATH.
echo 2. Placed some background videos in assets\backgrounds\
echo 3. Added your Reddit / LLM API credentials to .env
echo.
echo You can test the system by running: test_reddit.bat
echo.
pause

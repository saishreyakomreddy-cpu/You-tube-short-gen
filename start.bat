@echo off
echo ===================================================
echo   YouTube Shorts Factory - Universal Launcher
echo ===================================================
cd /d "%~dp0"

:: Check for Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in your system PATH.
    echo Please install Python 3.10+ from python.org and check "Add to PATH".
    pause
    exit /b 1
)

:: Auto-Setup if venv doesn't exist
if not exist "venv" (
    echo [INFO] First time run detected. Setting up environment...
    python -m venv venv
    call venv\Scripts\activate.bat
    python -m pip install --upgrade pip >nul 2>&1
    pip install -r requirements.txt
    
    mkdir assets\backgrounds 2>nul
    mkdir assets\music 2>nul
    mkdir assets\templates 2>nul
    mkdir assets\voices 2>nul
    mkdir config 2>nul
    mkdir data 2>nul
    mkdir logs 2>nul
    mkdir output\shorts 2>nul
    
    if not exist ".env" (
        if exist ".env.example" (
            copy .env.example .env >nul
            echo [WARNING] Created .env from .env.example.
            echo Please open .env and add your API Keys before continuing!
            pause
            exit /b 1
        )
    )
)

:: Activate and Launch Daemon
echo [INFO] Starting 24/7 Autonomous Daemon...
call venv\Scripts\activate.bat
python scripts/daemon.py
pause

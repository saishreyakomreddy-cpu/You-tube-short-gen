@echo off
echo Starting 24/7 Autonomous Daemon...
cd /d "%~dp0"
call venv\Scripts\activate.bat
python scripts/daemon.py
pause

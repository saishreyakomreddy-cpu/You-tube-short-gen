@echo off
echo Starting 30-Second Shorts Factory...
cd /d "%~dp0"
call venv\Scripts\activate.bat
python -c "from src.config_loader import load_config; from src.pipeline import run_one; run_one(load_config())"
pause

@echo off
echo Starting Reddit Factory Testing Suite...
call .\venv\Scripts\Activate.bat
python scripts/test_run.py
pause

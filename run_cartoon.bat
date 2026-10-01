@echo off
setlocal

echo Starting Cartoon Shorts Factory...

if not exist venv\Scripts\python.exe (
    echo [ERROR] Virtual environment not found. Please set up the environment first.
    exit /b 1
)

call venv\Scripts\activate.bat
python -c "from src.cartoon_pipeline import run_pipeline; run_pipeline()"

if %errorlevel% neq 0 (
    echo [ERROR] Pipeline failed with exit code %errorlevel%.
)

pause

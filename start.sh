#!/bin/bash
echo "==================================================="
echo "  YouTube Shorts Factory - Universal Launcher (Linux)"
echo "==================================================="

# Change to script directory
cd "$(dirname "$0")"

# Check for python3
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] python3 could not be found. Please install Python 3.10+."
    exit 1
fi

# Auto-Setup if venv doesn't exist
if [ ! -d "venv" ]; then
    echo "[INFO] First time run detected. Setting up environment..."
    
    # Optional: try to install venv and ffmpeg if on Debian/Ubuntu
    if command -v apt-get &> /dev/null; then
        echo "[INFO] Detected Debian/Ubuntu. Installing python3-venv and ffmpeg (may require sudo password)..."
        sudo apt-get update && sudo apt-get install -y python3-venv ffmpeg
    elif command -v dnf &> /dev/null; then
        echo "[INFO] Detected Oracle Linux/RHEL. Installing python3.11-venv and ffmpeg..."
        # Oracle Linux 9 usually needs EPEL for ffmpeg, but we will try standard dnf first
        sudo dnf install -y python3-devel python3-pip
        # To get ffmpeg on Oracle Linux, it's safer to download a static build or rely on a generic package
        sudo dnf install -y ffmpeg || echo "[WARNING] Could not install ffmpeg automatically via dnf. You may need to install it manually."
    fi
    
    python3 -m venv venv
    source venv/bin/activate
    python3 -m pip install --upgrade pip
    pip install -r requirements.txt
    
    mkdir -p assets/backgrounds assets/music assets/templates assets/voices config data logs output/shorts
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            echo "[WARNING] Created .env from .env.example."
            echo "Please open .env and add your API Keys before continuing!"
            exit 1
        fi
    fi
fi

# Activate and Launch Daemon
echo "[INFO] Starting 24/7 Autonomous Daemon..."
source venv/bin/activate
python3 scripts/daemon.py

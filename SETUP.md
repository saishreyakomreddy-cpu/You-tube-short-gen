# YouTube Shorts Factory - Setup Guide

Welcome to the automated YouTube Shorts Factory! This tool completely automates the process of fetching top Reddit stories, generating highly dramatic scripts, synthesizing hyper-realistic voiceovers (via Fish Audio or local AI), creating captions, rendering the video with background clips, and uploading directly to YouTube.

## Prerequisites

Before starting, ensure you have the following installed on your system:
1. **[Python 3.10+](https://www.python.org/downloads/)** - Ensure you check the box that says "Add Python to PATH" during installation.
2. **[FFmpeg](https://ffmpeg.org/download.html)** - Download FFmpeg and add its `bin` folder to your system's Environment Variables `PATH`. The rendering engine relies completely on FFmpeg for lightning-fast compilation.

## 1. Quick Setup

We have provided an automated script to handle the virtual environment and folder setup for you.

1. Open the project folder in File Explorer.
2. Double-click the **`setup.bat`** file.
3. The script will:
   - Create an isolated Python virtual environment (`venv`).
   - Install all required packages.
   - Generate all necessary asset directories (`assets/backgrounds`, `logs`, etc.).
   - Create a `.env` file from the example template.

## 2. Configuration & API Keys

The pipeline relies on a few APIs to function (Reddit for content, LLMs for scriptwriting, and Fish Audio for TTS). 

1. Open the `.env` file generated in the root directory.
2. Add your **Reddit Developer Credentials** (Client ID, Secret, User Agent).
3. Add your **NVIDIA / Gemini / Ollama** API keys for the script generation LLM.
4. Open `config/config.yaml`.
5. Under the `tts:` section, add your **Fish Audio API Key** and Voice Reference UUIDs.

## 3. Populating Assets

To compile the videos, the factory needs raw background footage.

1. Download looping background videos (e.g., Minecraft Parkour, Subway Surfers, Satisfying Woodworking).
2. Place these `.mp4` or `.mov` files into the `assets/backgrounds/` folder.
   *Tip: You can organize them into subfolders (e.g., `assets/backgrounds/minecraft`) to allow the pipeline to pick specific categories.*

## 4. Testing the System

Before you let the factory run wild on an automated schedule, it's highly recommended to do a test run.

1. Double-click **`test_reddit.bat`**.
2. This is an interactive testing suite. It will prompt you to manually select your LLM, Story Template, Voice Gender, Background category, and TTS Engine.
3. **Select "No" when asked to upload to YouTube.** This will run the entire pipeline locally, allowing you to review the final `.mp4` generated in the `output/shorts/` folder.

## 5. Automated 24/7 Production

Once you are satisfied with the test results, you can put the factory into full continuous production.

1. Open your `.env` file and optionally configure the **Email Alert System** (`SMTP_EMAIL` and `SMTP_PASSWORD`) so the bot can email you if it encounters a critical error while you are away.
2. Double click **`run_daemon.bat`**.
3. This script launches the autonomous Python daemon. It will sit in the background and automatically generate and upload a video at the exact local times you specified in `config.yaml` (`daily_publish_times_local`). You do not need Windows Task Scheduler! Just leave the terminal open (or run it on a cloud server) and the factory will run forever.

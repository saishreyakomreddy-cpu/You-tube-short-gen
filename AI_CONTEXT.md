# AI Context & Architecture Map

*This document is intended for AI coding assistants. If you are an AI reading this, this is your master blueprint to understanding the YouTube Shorts Factory codebase.*

## Core Purpose
The "YouTube Shorts Factory" is a fully automated, headless video generation pipeline. It mines text stories from Reddit, uses LLMs to convert them into highly dramatic narrative scripts, synthesizes the audio via TTS, burns word-by-word subtitles onto looping background videos using FFmpeg, generates thumbnails, and automatically uploads the result to YouTube Shorts via OAuth.

## Directory Structure
- `/assets/` - Contains raw resources (`/backgrounds/`, `/music/`, `/templates/` for LLM prompt structures, and `/voices/` if local TTS models are used).
- `/config/` - Houses `config.yaml` and `client_secret.json` for YouTube OAuth.
- `/data/` - Contains `factory.db` (SQLite) to track fetched stories to prevent duplicates.
- `/output/shorts/` - Destination for the compiled video folders.
- `/scripts/` - Utility scripts, most notably `test_run.py` for interactive local testing.
- `/src/` - The core application logic (Agents).

## Architecture & Data Flow

The factory can be triggered manually via `run_factory.bat` or allowed to run 24/7 autonomously via `scripts/daemon.py` (launched by `run_daemon.bat`). The daemon monitors the configured `daily_publish_times_local` and triggers `src/pipeline.py` at the designated intervals.

When triggered, the pipeline executes sequentially through specific "Agents":

1. **`reddit_fetcher.py`**:
   - Uses `praw` to pull stories from subreddits configured in `config.yaml`.
   - Connects to SQLite (`db.py`) to ensure the post ID hasn't been processed before.
2. **`script_writer.py`**:
   - Formats the raw Reddit post into a tight, dramatic 3-part script (Title, Hook, Body).
   - Injects a **Critical Style Rule** requiring the LLM (Nvidia/Gemini/Ollama) to write highly visceral, emotional, first-person narration.
   - Utilizes `variable_pools.json` to inject dynamic names, ages, and twists via placeholders (e.g. `{protagonist_name}`) in the templates.
3. **`tts_agent.py`**:
   - Responsible for Text-to-Speech.
   - Primary Engine: **Fish Audio** (Cloud API via `fish-audio-sdk`). Picks UUIDs mapped in `config.yaml`.
   - Fallback/Alternative Engines: **Kokoro** (ONNX local) and **Chatterbox** (PyTorch local).
4. **`caption_agent.py`**:
   - Uses `whisper-timestamped` to analyze the generated `narration.wav`.
   - Outputs an `.ass` (Advanced SubStation Alpha) subtitle file. Captions are timed word-by-word for high viewer retention.
5. **`image_agent.py` & `thumbnail_agent.py`**:
   - Generates a "Reddit Card" PNG (simulating a Reddit post UI) to overlay at the beginning of the video.
   - Extracts a frame from the final video to create a YouTube thumbnail.
6. **`video_agent.py`**:
   - Uses pure `subprocess` calls to `ffmpeg`. **No MoviePy is used** to keep memory usage low and rendering speeds extremely fast.
   - It loops the background video, overlays the Reddit Card for the first 6 seconds, burns the `.ass` subtitles, ducks the background music, and aggressively removes any silences longer than `0.15s` from the narration to enforce rapid-fire pacing.
7. **`upload_agent.py`**:
   - Uses Google's `google-api-python-client` to authenticate and upload the `.mp4` to YouTube.
   - Uploads are marked as 'Public' automatically for immediate publishing.

## State of the Project (As of July 2026)
- **What is Created/Functional:** The entire pipeline is fully operational. Reddit fetching, LLM script generation with templates, Fish Audio TTS integration (with a roster list for random voice picking), Whisper captioning, FFmpeg rendering, and YouTube uploading are completely dialed in and tested.
- **What is Hardcoded:** **Nothing**. All absolute paths have been purged. Everything relies on relative pathing resolved by `src/config_loader.py` which pulls `_root` dynamically.
- **Recent Major Additions:** 
  1. A 24/7 autonomous daemon (`daemon.py`) that handles scheduling internally without relying on Windows Task Scheduler. It features robust `ThreadPoolExecutor` timeouts for LLM API calls and a massive `try...except` block that prevents process crashes. 
  2. If the daemon catches a crash, it uses `smtplib` to send an emergency error log to the configured `SMTP_EMAIL` address, then waits for the next slot.
  3. All network API base URLs (Nvidia, Fish, Ollama) were moved to the `endpoints:` section in `config.yaml`.

## AI Assistant Directives
1. **Never use MoviePy:** Always stick to pure `subprocess.run(["ffmpeg", ...])` for any video manipulation tasks to maintain the strict performance targets.
2. **Avoid Hardcoding:** If you add a new feature, read parameters from `config.yaml` using the `cfg` dict passed to every agent.
3. **Testing:** If asked to verify changes, advise the user to run `test_reddit.bat` and select the `Skip Upload` option to generate a local video safely.

# YouTube Shorts Factory — Reddit Storytelling

Fully automated pipeline: fetches a Reddit story → rewrites it into a narration
script → generates voice + captions → renders a vertical short → generates a
thumbnail + SEO metadata → uploads to YouTube on a schedule. Runs once a day,
unattended, on a 4GB VRAM / 16GB RAM Windows machine, for $0/month.

## What changed vs. the original spec, and why

| Original plan | What's built instead | Why |
|---|---|---|
| n8n + Docker orchestration | Plain Python script + Windows Task Scheduler | One extra moving part (Docker) you don't need to hit 6 videos/day. Add n8n later if you want a visual dashboard. |
| SDXL scene-by-scene AI images | Stock/gameplay-style background footage + burned captions | This *is* the standard "Reddit storytime" format — and SDXL on 4GB VRAM would take minutes per image, killing your automation. |
| Local Llama for all text | Gemini 2.5 Flash (free tier) primary, small local Ollama model as fallback | Free tier comfortably covers ~15-20 calls/day; keeps your GPU free for nothing, since there's no local generation bottleneck. |
| Both channels at once | Reddit Storytelling channel only, for now | Kids Cartoon needs character-consistent image generation, a harder problem on this hardware. The pipeline is modular — bolt it on later. |
| 4 videos per story (multiple lengths) | 1 short per story, 6 stories/day | Matches your "6 videos/day" target directly and gives more content variety instead of 6 similar-length clips from fewer stories. |

Every part of this has been individually tested (ffmpeg render, caption
timing/burn-in, thumbnail compositing, JSON parsing, scheduling math, DB
dedup) — see the code comments. What I *can't* test from here is the live
Reddit/Gemini/YouTube API calls, since those need your credentials.

**One thing worth knowing going in:** YouTube's spam policy specifically
calls out "reused content" (e.g. narrating someone else's text over
generic footage) as something that can get a channel demonetized or
suspended if there's no meaningful original spin. Thousands of channels
run exactly this format successfully, but it helps to add a bit of your
own voice — a consistent narrator persona, on-screen branding, or light
commentary — rather than a 100% mechanical rewrite. Start uploads as
"private"/scheduled (already the default below) and watch a few before
flipping to fully public, hands-off.

---

## Setup steps

### 1. Install Python and ffmpeg

- Python 3.11+: https://www.python.org/downloads/ (check "Add to PATH" during install)
- ffmpeg (Windows build with libass — needed for burned captions): download the
  "full" build from https://www.gyan.dev/ffmpeg/builds/ (ffmpeg-git-full.7z),
  extract it, and add the `bin` folder to your Windows PATH.
- Verify: open a new terminal and run `ffmpeg -version` and `python --version`.

### 2. Unzip this project and install Python packages

```
cd youtube-factory
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Reddit API credentials (free)

1. Go to https://www.reddit.com/prefs/apps → "create another app..."
2. Choose type **script**, any name, redirect URI `http://localhost:8080`
3. Copy the client ID (under the app name) and client secret
4. Copy `.env.example` to `.env` and fill in `REDDIT_CLIENT_ID`, `REDDIT_CLIENT_SECRET`

### 4. Gemini API key (free)

1. Go to https://aistudio.google.com/app/apikey → create a key
2. Put it in `.env` as `GEMINI_API_KEY`

### 5. YouTube upload access (free, one-time OAuth setup)

1. Go to https://console.cloud.google.com/ → create a project
2. Enable the **YouTube Data API v3** (APIs & Services → Library → search it → Enable)
3. Configure the OAuth consent screen (External, add yourself as a test user)
4. Credentials → Create Credentials → OAuth client ID → Application type **Desktop app**
5. Download the JSON and save it as `config/client_secret.json`
6. The first time you run the factory, a browser window will pop up asking you
   to log in and grant access — that's normal, it only happens once (token gets
   cached to `config/token.json`).

Free quota: uploading costs quota points per video, and the default daily
quota easily covers 6 uploads/day. If you ever hit the ceiling, request a
quota increase from the same Cloud Console page (also free).

### 6. Piper voice (free, offline TTS)

```
python -m piper.download_voices en_US-ryan-high --download-dir assets/voices
```

If that command doesn't work on your `piper-tts` version, download the two
files manually (`en_US-ryan-high.onnx` and `en_US-ryan-high.onnx.json`) from
https://huggingface.co/rhasspy/piper-voices and place them in `assets/voices/`.
Browse that repo for other voices/accents if you want a different narrator.

### 7. Background footage (free, one-time)

Grab 15-20 vertical (9:16) clips — nature, abstract, satisfying/oddly-satisfying
loops, or your own gameplay recordings — and drop the `.mp4` files into
`assets/backgrounds/`. Free sources with commercial-use licenses:
- https://www.pexels.com/videos/ (filter by "Portrait")
- https://www.pixabay.com/videos/
- https://mixkit.co/free-stock-video/vertical/

Avoid ripping actual copyrighted game footage (Minecraft/Subway Surfers
streams etc.) if you want to keep monetization/copyright risk low — the
stock sites above are safer and still work great as background motion.

Optional: drop a few royalty-free background music tracks (mp3) into
`assets/music/` — YouTube Audio Library (studio.youtube.com) and
Pixabay Music are good free sources. Skip this if you don't want background
music; the pipeline works fine without it.

### 8. Verify everything

```
python scripts/setup_check.py
```

Fix anything marked `[FAIL]`, then run one video manually to sanity-check the
whole chain before scheduling it:

```
python -c "from src.config_loader import load_config; from src.pipeline import run_one; run_one(load_config())"
```

Check `output/shorts/<id>/final.mp4` and the video's YouTube Studio entry.

### 9. Schedule the daily batch (Windows Task Scheduler)

1. Open Task Scheduler → Create Task
2. Trigger: Daily, at the time set in `config/config.yaml` under `schedule.run_time_local`
3. Action: Start a program
   - Program: `C:\path\to\youtube-factory\venv\Scripts\python.exe`
   - Arguments: `scripts\run_daily_batch.py`
   - Start in: `C:\path\to\youtube-factory`
4. Under Settings, check "Run task as soon as possible after a scheduled start
   is missed" so a sleeping PC still catches up.
5. Your PC needs to be on (or wake-on-schedule) at that time — it does not
   need to be logged in if you check "Run whether user is logged on or not".

That's it — from here it runs itself. Check `logs/factory.log` if a batch
ever comes up short.

---

## Tuning knobs (all in `config/config.yaml`)

- `channel.subreddits` — add/remove source subreddits
- `channel.target_duration_sec` — short length (keep 20-60s)
- `channel.min_score` — raise this if story quality feels inconsistent
- `upload.daily_publish_times_local` — spread of scheduled publish times
- `upload.publish_mode` — `"scheduled"` (recommended) or `"immediate"`
- `video.caption_style`, `video.font`, `video.music_volume` — look and feel

## Adding the Kids Cartoon channel later

The agents are all channel-agnostic except `reddit_fetcher.py` and
`script_writer.py`'s prompt. To add a second channel: duplicate
`config/config.yaml` into `config/channels/kids.yaml`, swap the story source
(an LLM-generated topic instead of Reddit) and script prompt, and point a
second Task Scheduler entry / OAuth channel at it. The TTS, captions,
render, thumbnail, SEO and upload agents can be reused as-is once you're
generating consistent character images (a good next step once this channel
is stable, likely via a hosted SDXL API rather than local — 4GB VRAM won't
render character-consistent scenes fast enough for daily automation).

## Future enhancements (from the original spec, not yet built)

- Long-form videos from the same script (8-15 min versions)
- Automatic background-clip fetching via Pexels' free API
- n8n dashboard on top of this pipeline for visual monitoring
- Multi-platform repost (TikTok, Instagram Reels)
- Analytics-driven title A/B testing

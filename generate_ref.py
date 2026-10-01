from src.config_loader import load_config
from src.tts_agent import _synthesize_kokoro
from pathlib import Path
import os

cfg = load_config()

male_text = "Hi, my name is Adam. I'm going to be your narrator for today's exciting story. So sit back, relax, and let's get into the video!"
female_text = "Hi, my name is Sarah. I'm going to be your narrator for today's exciting story. So sit back, relax, and let's get into the video!"

voices_dir = Path("d:/Projects/youtube-factory/assets/voices")
voices_dir.mkdir(parents=True, exist_ok=True)

print("Generating male reference...")
_synthesize_kokoro(male_text, str(voices_dir / "ref_male.wav"), cfg, "male")

print("Generating female reference...")
_synthesize_kokoro(female_text, str(voices_dir / "ref_female.wav"), cfg, "female")

print("Done! Generated reference audio clips.")

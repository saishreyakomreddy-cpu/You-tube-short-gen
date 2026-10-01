import httpx
from rich import print
import os
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.environ.get("FISH_API_KEY", "")
headers = {"Authorization": f"Bearer {API_KEY}"}

with httpx.Client() as client:
    # Just grab latest models and hope the user just saw it on the front page, or search for "Reddit" case-insensitively
    print("Searching for shOrt Cut...")
    # There's no documented author search, let's just do a text search if possible
    # fish audio doesn't have a known author search in this quick script. 
    # Let's search 'Reddit '
    res = client.get("https://api.fish.audio/model?title=Reddit", headers=headers)
    for m in res.json().get('items', []):
        print(f"[{m['title']}] by {m.get('author', {}).get('nickname')}: {m['_id']}")

# Discord Rich Presence
from discordrp import Presence
import time
import os

# Set title
os.system("title Discord Rich Presence")

# Set time
time_local = time.localtime()
time_current = time.strftime("%H:%M:%S", time_local)

# Discord Client ID
client_id = "000000000000000000"

with Presence(client_id) as presence:
    # Set data
    print("Discord Connected!")
    presence.set(
        {
            "details": "Example Details",
            "state": "Example State",
            "timestamps": {
                "start": int(time.time())
            },
            "assets": {
                "large_image": "example-large-key",
                "large_text": "Large Text Hover",
                "small_image": "example-small-key",
                "small_text": "Small Text Hover",
            },
            "buttons": [
                {
                    "label": "Example Button",
                    "url": "https://github.com/TriForceX",
                },
            ],
        }
    )
    # End
    print(f"Status Started at {time_current}")

    while True:
        time.sleep(15)
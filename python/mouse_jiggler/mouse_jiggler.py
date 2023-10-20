import pyautogui
import time
import os

# Set title
os.system("title Mouse Jiggler")

# Main Function
def mouse_jiggler():
    screen_width, screen_height = pyautogui.size()
    x, y = 0, 0
    step_size = 5

    # Start loop
    while True:
        # Right movement
        while x < screen_width - step_size:
            x += step_size
            pyautogui.moveTo(x, y)
        
        # Downward movement
        while y < screen_height - step_size:
            y += step_size
            pyautogui.moveTo(x, y)

        # Left movement
        while x > step_size:
            x -= step_size
            pyautogui.moveTo(x, y)
        
        # Upward movement
        while y > step_size:
            y -= step_size
            pyautogui.moveTo(x, y)

# Let the user stop the movement anytime
print("Starting Mouse Jiggler in 3 seconds...")
time.sleep(3)
print("Done! To stop it move the cursor to an edge of the screen.")

try:
    mouse_jiggler()
except KeyboardInterrupt:
    print("Mouse Jiggler Stopped.")
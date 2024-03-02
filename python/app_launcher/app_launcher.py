# Imports
import tkinter as tk
import json
import sys
import os
import ctypes
import keyboard

try:
    # Get file data
    file_custom = "C:\\Folder\\example.json"
    file_base = os.path.basename(sys.argv[0])

    if (os.path.exists(file_custom)):
        file_name = file_custom
    elif (os.path.exists(file_base)):
        file_name = os.path.splitext(file_base)[0]+".json"

    # Open & load JSON
    json_file = open(f"{file_name}")
    json_data = json.load(json_file)
    config = json_data["config"];
    executables = json_data["executables"];
    
    # Main window
    window = tk.Tk()
    window.title(config["title"])

    # Console window
    os.system(f"title {config["title"]} - Console")

    # Show hide windows
    def on_window(window, action):
        if (action == "minimize"):
            ctypes.windll.user32.ShowWindow(window, 6)
        else:
            ctypes.windll.user32.ShowWindow(window, 3)

    # Launch function
    def on_launch(target, params):
        path, binary = os.path.split(target)
        name, ext = os.path.splitext(binary)
        
        if not ext:
            binary = False
            path = target
        if not isinstance(params, str):
            params = ''
            
        print(f"\nExecutable: {binary}")
        print(f"Path: {path}")
        print(f"Params: {params if params else False}")
        
        if ("steam://" in target):
            os.system(f'start "" "{target}{'//'+params if params else ''}"')
        elif ("://" in target):
            os.system(f'start "" "{target}{params}"')
        elif (path and binary):
            os.system(f'start "" /D "{path}" "{binary}" {params}')
        else:
            os.system(f'start "" "{target}" {params}')
        if (config["closeOnLaunch"]):
            quit()
        else:
            on_window(ctypes.windll.user32.FindWindowW(None, config["title"]), "minimize")

    # Main frame and labels
    frame = tk.Frame()
    frame.pack(padx=15, pady=15)

    label_title = tk.Label(master=frame, text=f"{config["title"]}", font=("Helvetica", 14, "bold"))
    label_title.pack()
    
    label_desc = tk.Label(master=frame, text=f"{config["description"]}")
    label_desc.pack()

    # Show buttons
    for val in executables:
        button_launch=tk.Button(master=frame, text=val["name"], command=lambda target=val["target"], params=val["params"]:on_launch(target, params))
        button_launch.pack(pady=(5, 0), fill="x")

    # Minimize console
    if (config["minimizeConsole"]):
        on_window(ctypes.windll.kernel32.GetConsoleWindow(), "minimize")

    # Console info
    print(f"{config["title"]}\n{'-' * len(config["title"])}")
    print(f"Total: {len(executables)} buttons")
    print(f"minimizeConsole: {config["minimizeConsole"]}")
    print(f"closeOnLaunch: {config["closeOnLaunch"]}")

    # Close JSON file
    json_file.close()

    # Run app
    window.eval('tk::PlaceWindow . center')
    window.mainloop()
    
except Exception as e:
    # Show error
    error_title = "Unable to execute the program"
    print(f"{error_title}\n{'-' * len(error_title)}")
    print(f"{e}")
    print("Press any key to continue...")
    keyboard.read_key()
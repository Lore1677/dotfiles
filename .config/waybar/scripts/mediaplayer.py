#!/usr/bin/env python3
import subprocess
import json

try:
    # Controlla solo Spotify
    status = subprocess.check_output(['playerctl', '-p', 'spotify', 'status'], stderr=subprocess.DEVNULL).decode('utf-8').strip()
    
    if status in ['Playing', 'Paused']:
        artist = subprocess.check_output(['playerctl', '-p', 'spotify', 'metadata', 'artist'], stderr=subprocess.DEVNULL).decode('utf-8').strip()
        title = subprocess.check_output(['playerctl', '-p', 'spotify', 'metadata', 'title'], stderr=subprocess.DEVNULL).decode('utf-8').strip()
        
        # Icone con larghezza fissa
        status_icon = "󰏤  " if status == "Playing" else "󰐊  "
        
        output = {
            "text": f"{status_icon} {artist} - {title}",
            "tooltip": f"{artist} - {title}",
            "class": status.lower(),
            "alt": status
        }
        print(json.dumps(output))
    else:
        print("")
except:
    print("")
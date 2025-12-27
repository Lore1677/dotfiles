#!/bin/bash

# Script meteo per Waybar - Frosinone
# Usa wttr.in per ottenere i dati meteo

CITY="Frosinone"

# Mappa delle icone meteo
get_icon() {
    case $1 in
        *"Sunny"*|*"Clear"*) echo "☀️" ;;
        *"Partly cloudy"*|*"Partly Cloudy"*) echo "⛅" ;;
        *"Cloudy"*|*"Overcast"*) echo "☁️" ;;
        *"Mist"*|*"Fog"*) echo "🌫️" ;;
        *"rain"*|*"Rain"*|*"Drizzle"*) echo "🌧️" ;;
        *"snow"*|*"Snow"*) echo "❄️" ;;
        *"thunder"*|*"Thunder"*) echo "⛈️" ;;
        *"sleet"*|*"Sleet"*) echo "🌨️" ;;
        *) echo "🌡️" ;;
    esac
}

# Ottieni dati meteo
weather_data=$(curl -s "wttr.in/${CITY}?format=%c+%t+%C" 2>/dev/null)

if [ $? -eq 0 ] && [ ! -z "$weather_data" ]; then
    # Estrai temperatura e condizione
    temp=$(echo "$weather_data" | awk '{print $2}')
    condition=$(echo "$weather_data" | cut -d' ' -f3-)
    
    # Ottieni icona basata sulla condizione
    icon=$(get_icon "$condition")
    
    # Output JSON per Waybar
    echo "{\"text\":\"$icon $temp\", \"tooltip\":\"$CITY: $condition\", \"class\":\"weather\"}"
else
    # Fallback in caso di errore
    echo "{\"text\":\"🌡️ --°C\", \"tooltip\":\"Meteo non disponibile\", \"class\":\"weather-error\"}"
fi
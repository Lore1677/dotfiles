#!/bin/bash

killall -9 waybar
killall -9 wlogout
killall -9 swaync

swaync &
waybar &

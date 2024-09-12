#!/bin/bash

#xrandr --output eDP --mode 1280x720 --rate 60.02
#xrandr --output eDP --primary --mode 1920x1080 --scale 0.65x0.65 --panning 1280x720

# Detect if HDMI-A-0 is connected
HDMI_STATUS=$(xrandr | grep "HDMI-A-0 connected")

if [ -n "$HDMI_STATUS" ]; then
    # HDMI-A-0 is connected, set up dual monitors
    xrandr --output HDMI-A-0 --mode 1366x768 --rate 59.79 --right-of eDP
else
    xrandr --output HDMI-A-0 --off
fi

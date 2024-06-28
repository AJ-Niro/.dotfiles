# Change laptop Resolution
xrandr --output eDP --mode 1280x720 --rate 60.02

# Configure touchpad tap and sroll
TOUCHPAD_NAME="SYNA32AC:00 06CB:CD50 Touchpad"
xinput --set-prop "$TOUCHPAD_NAME" "libinput Natural Scrolling Enabled" 1
xinput --set-prop "$TOUCHPAD_NAME" "libinput Tapping Enabled" 1

# Start Picom
picom &
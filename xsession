# X startup script
# Install this as `~/.xinitrc`

# disable screen blanking
xset s noblank
xset s off
xset -dpms

# run Chromium in kiosk-mode
noclutter &
chromium-browser --kiosk --disable-restore-session-state http://localhost:3030/


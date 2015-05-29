# X startup script
# Install this as `~/.xinitrc`

# disable screen blanking
xset -dpms s noblank

# run Chromium in kiosk-mode
noclutter &
chromium-browser --kiosk --disable-restore-session-state http://localhost:3030/


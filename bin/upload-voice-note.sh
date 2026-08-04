#!/data/data/com.termux/files/usr/bin/env bash
# Uploads one or more voice-note recordings to the remote inbox via
# rsync, removing each local file only after a successful transfer.
#
# Called by voice-capture-foreground.sh with the whole pending queue,
# so a previously failed upload gets retried on the next capture.
#
# Usage: upload-voice-note.sh FILE...

REMOTE="punchagan@muse-amuse.in:~/voice-capture/inbox/"
NOTIF_ID="voice-capture"

if [ "$#" -eq 0 ]; then
    echo "Usage: $(basename "$0") FILE..." >&2
    exit 1
fi

termux-wake-lock
if rsync -az --remove-source-files "$@" "$REMOTE"; then
    termux-notification -i "$NOTIF_ID" -t "Voice capture" -c "Uploaded"
else
    termux-notification -i "$NOTIF_ID" -t "Voice capture" -c "Upload failed, will retry next time"
fi
termux-wake-unlock

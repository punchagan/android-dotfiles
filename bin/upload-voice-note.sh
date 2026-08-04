#!/data/data/com.termux/files/usr/bin/env bash
# Uploads one or more voice-note recordings to the remote inbox via
# rsync, removing each local file only after a successful transfer.
#
# Shared by:
#  - voice-capture-toggle.sh, passing the whole pending queue (so a
#    previously failed upload gets retried on the next capture)
#  - Automate, via a Termux RUN_COMMAND action, for recordings made by
#    a separate voice-memo app in its own dedicated folder -- see
#    doom.org's "Process voice notes from phone" section for why:
#    Termux's own mic recording goes silent when backgrounded on
#    Android 14+ (missing foregroundServiceType="microphone" in
#    termux-api's manifest), that app doesn't have that bug.
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

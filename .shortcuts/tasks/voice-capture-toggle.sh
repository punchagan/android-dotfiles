#!/data/data/com.termux/files/usr/bin/env bash
# One tap starts recording; the next tap stops it and uploads everything in the
# pending queue (this file, plus anything left over from a previous failed
# upload) to the remote server.
#
# Deliberately no cron/background service involved -- Termux's crond depends on
# the app staying alive, which Android's battery/Doze management doesn't
# reliably guarantee (especially on MIUI/OxygenOS/ Samsung). Uploading right
# when a recording finishes is simpler and more trustworthy: one script,
# event-triggered, no polling.

REMOTE="punchagan@muse-amuse.in:~/voice-capture/inbox/"

STAGING_DIR="$HOME/voice-capture/pending"
STATE_FILE="$HOME/.cache/voice-capture-current"

mkdir -p "$STAGING_DIR" "$(dirname "$STATE_FILE")"

IS_RECORDING="$(termux-microphone-record -i | jq -r .isRecording)"

if [ "$IS_RECORDING" = "true" ]; then
    # Already recording -- stop it, then flush the whole pending queue.
    termux-microphone-record -q
    rm -f "$STATE_FILE"
    termux-notification -t "Voice capture" -c "Saved, uploading..."

    termux-wake-lock
    if rsync -az --remove-source-files "$STAGING_DIR"/ "$REMOTE"; then
        termux-notification -t "Voice capture" -c "Uploaded"
    else
        termux-notification -t "Voice capture" -c "Upload failed, will retry next capture"
    fi
    termux-wake-unlock
else
    # Nothing recording -- start one.
    OUTFILE="$STAGING_DIR/voice-$(date +%Y%m%dT%H%M%S).m4a"
    termux-microphone-record -f "$OUTFILE" -l 0 -e aac
    echo "$OUTFILE" > "$STATE_FILE"
    termux-notification -t "Voice capture" -c "Recording... tap again to stop"
fi

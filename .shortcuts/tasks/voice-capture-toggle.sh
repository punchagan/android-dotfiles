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

STAGING_DIR="$HOME/voice-capture/pending"
STATE_FILE="$HOME/.cache/voice-capture-current"
UPLOAD_SCRIPT="$HOME/bin/upload-voice-note.sh"

mkdir -p "$STAGING_DIR" "$(dirname "$STATE_FILE")"

SELF="$(realpath "$0")"
NOTIF_ID="voice-capture"

IS_RECORDING="$(termux-microphone-record -i | jq -r .isRecording)"

if [ "$IS_RECORDING" = "true" ]; then
    # Already recording -- stop it, then flush the whole pending queue
    # (this file, plus anything left over from a previous failed
    # upload) via the shared upload script -- also used by Automate for
    # recordings from a separate voice-memo app (see
    # bin/upload-voice-note.sh for why).
    termux-microphone-record -q
    rm -f "$STATE_FILE"
    termux-notification -i "$NOTIF_ID" -t "Voice capture" -c "Saved, uploading..."

    shopt -s nullglob
    "$UPLOAD_SCRIPT" "$STAGING_DIR"/*.m4a
else
    # Nothing recording -- start one. --ongoing pins the notification so it
    # can't be swiped away mid-recording by accident; tapping it (or the
    # Stop button) just re-runs this same script, which the isRecording
    # check above turns into the stop branch.
    OUTFILE="$STAGING_DIR/voice-$(date +%Y%m%dT%H%M%S).m4a"
    termux-microphone-record -f "$OUTFILE" -l 0 -e aac
    echo "$OUTFILE" > "$STATE_FILE"
    termux-notification -i "$NOTIF_ID" -t "Voice capture" -c "Recording... tap to stop" \
        --ongoing \
        --action "$SELF" \
        --button1 "Stop" --button1-action "$SELF"
fi

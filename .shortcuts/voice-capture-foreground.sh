#!/data/data/com.termux/files/usr/bin/env bash
# Foreground alternative to tasks/voice-capture-toggle.sh: keeps Termux
# open and visible for the whole recording instead of running silently
# in the background. Android mutes the mic once Termux backgrounds --
# see bin/upload-voice-note.sh for why (termux-api's MicRecorderService
# doesn't declare foregroundServiceType="microphone"). This trades the
# one-tap/notification convenience for a guaranteed full-length
# recording: stay in this terminal, don't switch away, until you're
# done talking.
#
# Lives in .shortcuts/ (not .shortcuts/tasks/) on purpose -- that's what
# makes launching it open a visible Termux session instead of running
# silently in the background.

STAGING_DIR="$HOME/voice-capture/pending"
UPLOAD_SCRIPT="$HOME/bin/upload-voice-note.sh"

mkdir -p "$STAGING_DIR"

OUTFILE="$STAGING_DIR/voice-$(date +%Y%m%dT%H%M%S).m4a"

termux-microphone-record -f "$OUTFILE" -l 0 -e aac
echo "Recording... stay in this session, don't switch away."
read -rp "Press Enter to stop. "

termux-microphone-record -q
echo "Saved. Uploading..."

# Flush the whole pending queue, not just this file, so anything left
# over from a previous failed upload gets retried too.
shopt -s nullglob
"$UPLOAD_SCRIPT" "$STAGING_DIR"/*.m4a

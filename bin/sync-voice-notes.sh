#!/usr/bin/env bash
# Uploads finished recordings from the Voice Notes app's folder to the
# remote inbox via rsync, then moves each one into uploaded/ so it is
# never sent twice and the original stays on the phone.
#
# Meant to run from cron: quiet when there is nothing to upload, and a
# failed upload is simply retried on the next run. Progress goes to
# stdout with timestamps (cron appends it to ~/cron.log); run by hand
# in a terminal for a live rsync progress bar too.

SRC_DIR="$HOME/storage/music/Recordings/Voice Notes"
DONE_DIR="$SRC_DIR/uploaded"
REMOTE="punchagan@muse-amuse.in:~/voice-capture/inbox/"
NOTIF_ID="voice-capture"
# Skip files modified more recently than this (minutes), in case the
# recorder is still writing to them.
MIN_AGE=1

log() {
    printf '%s %s\n' "$(date '+%F %T')" "$*"
}

mkdir -p "$DONE_DIR" || exit 1

# NUL-delimited so file names with spaces are handled safely. Hidden
# files are skipped: Android keeps recordings deleted in the app as
# ".trashed-<expiry>-<name>.m4a" in the same folder.
mapfile -d '' files < <(
    find "$SRC_DIR" -maxdepth 1 -type f -name '*.m4a' ! -name '.*' \
        -mmin +"$MIN_AGE" -print0
)
total=${#files[@]}

if [ "$total" -eq 0 ]; then
    # Stay out of cron.log when idle, but tell someone running it by hand.
    [ -t 1 ] && log "No new voice notes to upload."
    exit 0
fi

rsync_opts=(-az)
[ -t 1 ] && rsync_opts+=(--progress)

log "Found $total voice note(s) in $SRC_DIR"

uploaded=0
failed=0
for f in "${files[@]}"; do
    name=${f##*/}
    n=$((uploaded + failed + 1))
    log "[$n/$total] Uploading $name ($(du -h --apparent-size "$f" | cut -f1))"
    if rsync "${rsync_opts[@]}" "$f" "$REMOTE"; then
        mv "$f" "$DONE_DIR/"
        uploaded=$((uploaded + 1))
        log "[$n/$total] Done, moved to uploaded/"
    else
        failed=$((failed + 1))
        log "[$n/$total] FAILED: $name (will retry next run)"
    fi
done

log "Finished: $uploaded uploaded, $failed failed"

if [ "$failed" -gt 0 ]; then
    termux-notification -i "$NOTIF_ID" -t "Voice notes" \
        -c "$failed upload(s) failed, will retry (uploaded $uploaded)"
else
    termux-notification -i "$NOTIF_ID" -t "Voice notes" \
        -c "Uploaded $uploaded"
fi

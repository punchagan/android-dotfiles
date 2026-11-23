#!/usr/bin/env bash
# Uploads finished recordings from the Voice Notes app's folder to the
# remote inbox via rsync, then moves each one into uploaded/ so it is
# never sent twice and the original stays on the phone.
#
# Meant to run from cron: quiet when there is nothing to upload, and a
# failed upload is simply retried on the next run.

SRC_DIR="$HOME/storage/music/Recordings/Voice Notes"
DONE_DIR="$SRC_DIR/uploaded"
REMOTE="punchagan@muse-amuse.in:~/voice-capture/inbox/"
NOTIF_ID="voice-capture"
# Skip files modified more recently than this (minutes), in case the
# recorder is still writing to them.
MIN_AGE=1

mkdir -p "$DONE_DIR" || exit 1

# NUL-delimited so file names with spaces are handled safely.
mapfile -d '' files < <(
    find "$SRC_DIR" -maxdepth 1 -type f -name '*.m4a' -mmin +"$MIN_AGE" -print0
)
[ "${#files[@]}" -eq 0 ] && exit 0

uploaded=0
failed=0
for f in "${files[@]}"; do
    if rsync -az "$f" "$REMOTE"; then
        mv "$f" "$DONE_DIR/"
        uploaded=$((uploaded + 1))
    else
        failed=$((failed + 1))
    fi
done

if [ "$failed" -gt 0 ]; then
    termux-notification -i "$NOTIF_ID" -t "Voice notes" \
        -c "$failed upload(s) failed, will retry (uploaded $uploaded)"
else
    termux-notification -i "$NOTIF_ID" -t "Voice notes" \
        -c "Uploaded $uploaded"
fi

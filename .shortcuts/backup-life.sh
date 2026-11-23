#!/usr/bin/env bash
# Syncs life-in-plain-text. Runs both from the widget shortcut and from
# cron. When attached to a terminal (widget) it shows a toast and opens
# emacs on a conflict; unattended (cron, no tty) it only notifies, and
# stays quiet on success.

DIR=/sdcard/Documents/git-repos/.life-in-plain-text/
LOG=~/backuplog.txt

bash "$DIR/backup.sh" > "$LOG"
status=$?

if grep -q CONFLICT "$LOG"; then
    termux-notification < "$LOG"
    termux-vibrate -d 300
    if [ -t 0 ]; then
        git -C "$DIR" status
        emacs "$DIR"
    fi
elif [ "$status" -ne 0 ]; then
    termux-notification -t "Backup failed" -c "backup.sh exited with status $status"
elif [ -t 0 ]; then
    termux-toast -g top -b "#000000" -c "yellow" "Backup Successful!"
fi

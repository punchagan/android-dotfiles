#!/data/data/com.termux/files/usr/bin/env bash

CLIPBOARD_FILE=$(mktemp)

function sigexit_capture() {
    rm "${CLIPBOARD_FILE}"
}
trap sigexit_capture EXIT

termux-clipboard-get > "${CLIPBOARD_FILE}"
$HOME/bin/read-text.sh < "${CLIPBOARD_FILE}"

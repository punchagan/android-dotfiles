#!/data/data/com.termux/files/usr/bin/env bash

CLIPBOARD_FILE=$(mktemp)
LANGS="en,hi,te,kn"
RATES="1,1.25,1.5,1.75,2,2.25,2.5"

function sigexit_capture() {
    # NOTE: Termux API doesn't interrup in-progress termux-tts-speak. So, we kill it ourselves when the script is interrupted.
    echo "Killing android TTS service."
    am stopservice 'com.termux.api/.TextToSpeechAPI$TextToSpeechService' > /dev/null
    rm "${CLIPBOARD_FILE}"
}

trap sigexit_capture EXIT

termux-clipboard-get > "${CLIPBOARD_FILE}"
lang=$(termux-dialog radio -t "Language" -v "${LANGS}" | jq -r .text)
rate=$(termux-dialog radio -t "Speaking Rate" -v "${RATES}" | jq -r .text)

termux-tts-speak -n IN -l "${lang:-en}" -r "${rate:-1}" < "${CLIPBOARD_FILE}"

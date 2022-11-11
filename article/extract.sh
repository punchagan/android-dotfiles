#!/data/data/com.termux/files/usr/bin/env bash

set -xeuo pipefail

pushd $(dirname $0)
node scraper.js $1 | \
    pandoc --from html --to plain-raw_html --wrap=none --lua-filter tts-filter.lua
popd

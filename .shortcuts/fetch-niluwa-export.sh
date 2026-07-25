#!/usr/bin/env bash
DIR=/sdcard/Documents/git-repos/niluwa-export/
pushd $DIR
git pull --rebase origin main
popd

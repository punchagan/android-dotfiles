#!/usr/bin/sh
# Runs at phone boot (Termux boot hook). Starts crond so the entries in
# `crontab -l` run without having to open Termux first.
#
# The wake lock keeps Android from suspending Termux, which would
# silently stop crond. It costs battery, and it must be re-acquired
# after every reboot -- hence it lives here.

termux-wake-lock
crond

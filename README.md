# android-dotfiles

Dot files for use with Termux on my phone

## Setup

- Install Termux terminal from the play store. (F-Droid version seems
too old).

- Clone this repository to $HOME

- Copy the .git from this repository to $HOME and reset to HEAD to
  create all the files.

- Add the termux widget to the home screen to be able to run scripts
  from the shortcuts list

## Dependencies

- Termux:Widget which used to be a separate apk is now bundled into
Termux itself.

- pkg install termux-api termux-gui-bash termux-services cronie rsync openssh

- Run `termux-setup-storage` once, so that the shared storage shows up
  under `~/storage/`.

## Scheduled jobs

Periodic jobs run from cron (`cronie`) and are listed in `.crontab`:

| Schedule      | Script                    | What it does                                                    |
|---------------|---------------------------|-----------------------------------------------------------------|
| every 3 hours | `.shortcuts/backup-life.sh` | Syncs life-in-plain-text. Same script as the widget shortcut. |
| every 30 mins | `bin/sync-voice-notes.sh` | Uploads new voice notes to the server.                          |

- `backup-life.sh` checks whether it has a terminal. From the widget it
  shows a toast and opens emacs on a conflict. From cron it stays quiet
  unless there is a conflict or the backup fails, and then it sends a
  notification.

- `sync-voice-notes.sh` picks up finished `.m4a` files from
  `~/storage/music/Recordings/Voice Notes/`, which is where the voice
  recorder app saves them. It `rsync`s each to
  `muse-amuse.in:~/voice-capture/inbox/` and then moves it into
  `uploaded/` next to the recordings, so it isn't sent twice and the
  original stays on the phone. Files modified in the last minute are
  skipped, in case the recorder is still writing. Failed uploads are
  retried on the next run. The desktop side (transcription) is
  `process-voice-notes.sh` in the life-in-plain-text repo.

### Setting up cron

- Install the crontab with `crontab ~/.crontab`. Cron reads its own
  copy, so re-run this after every edit, and check with `crontab -l`.

- `.termux/boot/start-cron.sh` starts `crond` (with a wake lock) when the
  phone boots. For this to work, Termux needs to run scripts from
  `~/.termux/boot/` at boot. To check, add a script there that touches a
  file, reboot without opening Termux, and see if the file appears.
  Don't also `sv-enable crond`, that would start a second crond.

- Turn off battery optimization for Termux, or Android may stop it.

- Cron has no ssh-agent, so the keys in `~/.ssh` used by the scripts
  (the git remote for life-in-plain-text, and `muse-amuse.in`) must not
  have a passphrase.

- Output from the jobs goes to `~/cron.log`.

- To test a job the way cron runs it, with a minimal environment:
  `env -i PATH=/data/data/com.termux/files/usr/bin:/system/bin HOME=$HOME bash ~/bin/sync-voice-notes.sh < /dev/null`

DIR=/sdcard/Documents/git-repos/.life-in-plain-text/
bash $DIR/backup.sh > ~/backuplog.txt
if grep CONFLICT ~/backuplog.txt;
   then
       termux-notification < ~/backuplog.txt
       termux-vibrate -d 300
       git -C $DIR status
       emacs $DIR
else
    termux-toast -g top -b "#000000" -c "yellow" "Backup Successful!"
fi

#!/bin/bash

# set variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REMOTE_SERVER="hostname"
REMOTE_DIR="/remote/path/to/project"
REMOTE_ARCHIVE_DIR="/remote/path/to/backup/project"
REMOTE_ARCHIVE_FILE="${REMOTE_ARCHIVE_DIR}/backup_${TIMESTAMP}.tar.gz"
LOCAL_DEST="/mnt/local/device/backup/project"

# zip the directory on the remote server
ssh ${REMOTE_SERVER} "tar -zcvf ${REMOTE_ARCHIVE_FILE} ${REMOTE_DIR}"

# cleanup old backups on the remote server, keeping only the latest 3
ssh ${REMOTE_SERVER} "cd ${REMOTE_ARCHIVE_DIR} && ls -t backup_*.tar.gz | tail -n +4 | xargs rm -f"

# rsync the zipped file to local machine
rsync -avz --out-format="%t %f %''b" -e ssh ${REMOTE_SERVER}:${REMOTE_ARCHIVE_FILE} ${LOCAL_DEST}

# remove older backups, keeping only the latest 3
cd ${LOCAL_DEST}
ls -t backup_*.tar.gz | tail -n +4 | xargs rm -f

# print success message
echo "Backup completed: ${LOCAL_DEST}/$(basename ${REMOTE_ARCHIVE_FILE})"

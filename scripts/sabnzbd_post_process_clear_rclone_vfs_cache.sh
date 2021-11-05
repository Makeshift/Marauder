#!/bin/bash
set +x

HOST="127.0.0.1"
PORT="5572"

FULL_FOLDER=$(dirname "${SAB_COMPLETE_DIR}")
MAIN_DOWNLOAD_FOLDER=${FULL_FOLDER#/shared/merged/}
FILES_FOLDER=${SAB_COMPLETE_DIR#/shared/merged}

echo "Telling Rclone @ ${HOST}:${PORT} to forget cache info for directory ${MAIN_DOWNLOAD_FOLDER} and ${FILES_FOLDER} "
# Forget first to make absolutely certain that nothing will try to read cached data
curl -fs -X POST "admin:admin@${HOST}:${PORT}/vfs/forget?dir=${FILES_FOLDER}"
sleep 1
curl -fs -X POST "admin:admin@${HOST}:${PORT}/vfs/forget?dir=${MAIN_DOWNLOAD_FOLDER}"
sleep 1
# Now refresh to make reads a bit faster for the program that requested the download
curl -fs -X POST "admin:admin@${HOST}:${PORT}/vfs/refresh?dir=${FILES_FOLDER}&recursive=true"
sleep 1
curl -fs -X POST "admin:admin@${HOST}:${PORT}/vfs/refresh?dir=${MAIN_DOWNLOAD_FOLDER}&recursive=true"

# Just to make sure the refresh is complete
sleep 5

exit 0

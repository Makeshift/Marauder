#!/bin/bash
set +x

HOST="127.0.0.1"
PORT="5572"

FULL_FOLDER=$(dirname "${SAB_COMPLETE_DIR}")
FOLDER=${FULL_FOLDER#/shared/merged/}

echo "Telling Rclone @ ${HOST}:${PORT} to forget cache info for directory ${FOLDER}"

curl -fs -X POST "admin:admin@${HOST}:${PORT}/vfs/forget?dir=${FOLDER}"

sleep 5

exit 0

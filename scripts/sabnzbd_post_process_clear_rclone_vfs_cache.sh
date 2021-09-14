#!/bin/bash
set +x

HOST="127.0.0.1"
PORT="5572"

FULL_FOLDER=$(dirname "${SAB_COMPLETE_DIR}")
FOLDER=${FULL_FOLDER#/shared/merged/}

echo "Telling Rclone @ ${HOST}:${PORT} to refresh directory ${FOLDER}"

curl -fs -X POST "admin:admin@${HOST}:${PORT}/vfs/refresh?dir=${FOLDER}"

exit 0

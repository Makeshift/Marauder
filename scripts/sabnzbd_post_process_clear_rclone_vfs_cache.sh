#!/bin/bash
set +x

HOST="127.0.0.1"
PORT="5572"

FULL_FOLDER=$(dirname "${SAB_COMPLETE_DIR}")
FOLDER=${FULL_FOLDER#/shared/merged/}

echo "Telling Rclone @ ${HOST}:${PORT} to forget directory ${FOLDER} and refresh it"

curl -fs -X POST "${HOST}:${PORT}/vfs/forget?dir=${FOLDER}" &

exit 0
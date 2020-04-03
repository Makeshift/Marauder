#!/bin/bash
set +x

HOST="127.0.0.1"
PORT="5573"

FULL_FOLDER=$(dirname "${SAB_COMPLETE_DIR}")
FOLDER=${FULL_FOLDER#/shared/merged/}

echo "Telling Rclone @ ${HOST}:${PORT} to vfs/refresh directory ${FOLDER}"

curl -fs -X POST "${HOST}:${PORT}/vfs/refresh?dir=${FOLDER}"
if [ $? -eq 0 ]; then
    echo "Rclone refreshed successfully: ${FOLDER}"
else 
    echo "Failed to refresh, may not be visible to client: ${FOLDER}"
fi

echo "Telling Rclone @ ${HOST}:${PORT} to cache/expire ${FOLDER}"

curl -fs -X POST "${HOST}:${PORT}/cache/expire?remote=${FOLDER}"
if [ $? -eq 0 ]; then
    echo "Rclone refreshed successfully: ${FOLDER}"
else 
    echo "Failed to refresh, may not be visible to client: ${FOLDER}"
fi

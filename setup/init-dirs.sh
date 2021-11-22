#!/bin/bash

compose_files=(docker-compose.yml plex-compose.yml)
compose_search_dirs="/shared/\|/runtime_conf/\|/shared_plex/\|/service_accounts/"

if [[ ! -f "docker-compose.yml" ]]; then
  echo "This script should be ran from the root Marauder directory, where the docker-compose.yml lives. Change directory to there and run: setup/init-dirs.sh"
  exit 1
fi

function make_dirs_from_compose_file() {
  local compose_file="$1"
  filtered_mounts=$(docker run -v "$(pwd)/$1":/workdir/$1 mikefarah/yq e '.services[].volumes' $1 | /bin/grep "$compose_search_dirs" | sed -rn 's/- \.?\/?([^:]*):.*/\1/p' | sort | uniq)
  while IFS= read -r dir; do
    echo "Creating directory $dir"
    mkdir -p "$dir"
  done <<< "$filtered_mounts"
}

for compose_file in "${compose_files[@]}"; do
  echo "Processing file $compose_file"
  make_dirs_from_compose_file "$compose_file"
done

#!/bin/bash

if [[ ! -f "docker-compose.yml" ]]; then
  echo "This script should be ran from the root Marauder directory, where the docker-compose.yml lives. Change directory to there and run: setup/init-gcloud.sh"
  exit 1
fi

mkdir -p "$(pwd)/service_accounts" "$(pwd)/runtime_conf/gdrive_init/gcloud"
COMMAND="docker run -it -v "$(pwd)/service_accounts:/mnt" -v "$(pwd)/runtime_conf/gdrive_init/gcloud:/root/.config/gcloud""
# You can export the below variables in your shell to pass them to the container to override options
ENV_VARS=("PROJECT_NAME" "PROJECT_NAME_PREFIX" "EXPORT_LOCATION" "NUM_OF_SA" "SA_EMAIL_PREFIX" "GROUP_EMAIL")

for ENV_VAR in "${ENV_VARS[@]}"; do
    if [ ! -z ${!ENV_VAR} ]; then
        echo ${ENV_VAR} is set to ${!ENV_VAR}
        COMMAND+=" --env ${ENV_VAR} "
    fi
done

COMMAND+=" makeshift27015/marauder_gcloud_init"
if [ "$1" == "bash" ]; then
    COMMAND+=" /bin/bash"
fi

${COMMAND}

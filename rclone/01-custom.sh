#!/usr/bin/with-contenv sh

if [ -z "$SECRETS_SET" ]; then 
    echo "ERROR - Secrets are not set!"
    exit 1
fi

# Set some generic env vars for later
MountPoint="/shared/merged/"
RemotePath="union:"
UnmountCommands="-u -z"
ConfigPath=/config/.rclone.conf

# Make config dirs
mkdir -p /config/
mkdir -p /plexdrive/
mkdir -p /root/.plexdrive/

# Overwrite base rclone conf with env vars
(envsubst < /rclone.conf) > /config/.rclone.conf
# Write some config files
echo $rclone_service_credential_file > /credentials.json
echo $plexdrive_config_file > /root/.plexdrive/config.json
echo $plexdrive_token_file > /root/.plexdrive/token.json

# Set some extra env vars for later
echo $ConfigPath > /var/run/s6/container_environment/ConfigPath
echo $MountPoint > /var/run/s6/container_environment/MountPoint
echo $RemotePath > /var/run/s6/container_environment/RemotePath
echo $UnmountCommands > /var/run/s6/container_environment/UnmountCommands

# Debug
cat /credentials.json
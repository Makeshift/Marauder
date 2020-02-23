# Shamelessly adapted from mumiehub/rclone-mount
FROM alpine:latest

ENV GOPATH="/go" \
    MountPoint="/shared/merged" \
    ConfigPath="/config/.rclone.conf" \
    RCLONE_PLUGIN_PATH="/rclone_plugins" \
    RemotePath="union:" \
    UnmountCommands="-u -z"

COPY rootfs/ /

RUN apk --no-cache upgrade && \
    apk --no-cache add gettext libc6-compat curl go git alpine-sdk ca-certificates fuse fuse-dev && \
    echo "Installing S6 Overlay" && \
    curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz" && \
    tar xfz /tmp/s6-overlay.tar.gz -C / && \
    echo "Download and compile rclone" && \
    go get -u -v github.com/rclone/rclone && \
    cp /go/bin/rclone /usr/sbin/ && \
    echo "Download Plexdrive" && \
    curl -o /bin/plexdrive -L \
        "https://github.com/dweidenfeld/plexdrive/releases/download/5.0.0/plexdrive-linux-amd64" && \
    chmod +x /bin/plexdrive && \
    echo "Build Rclone plugins" && \
    cd /rclone_plugins_build && \
    go get -d ./... && \
    mkdir -p /rclone_plugins && \
    go build -buildmode=plugin -o /rclone_plugins/librcloneplugin_backend_reverseunion.so . && \
    apk del curl go git alpine-sdk && \
    rm -rf /rclone_plugins_build /usr/lib/go /go /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ENTRYPOINT ["/init"]
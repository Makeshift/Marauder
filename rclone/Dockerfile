# Shamelessly adapted from mumiehub/rclone-mount
FROM alpine:latest

ENV GOPATH="/go" \
    MountPoint="/shared/merged" \
    ConfigPath="/config/.rclone.conf" \
    RemotePath="union:" \
    UnmountCommands="-u -z"

COPY rootfs/ /

RUN apk --no-cache upgrade && \
    apk --no-cache add gettext libc6-compat curl go git alpine-sdk ca-certificates fuse fuse-dev findutils && \
    echo "Installing S6 Overlay" && \
    curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz" && \
    tar xfz /tmp/s6-overlay.tar.gz -C / && \
    echo "Download and compile rclone" && \
    go get -u -v github.com/rclone/rclone && \
    cp /go/bin/rclone /usr/sbin/ && \
    apk del curl go git alpine-sdk && \
    rm -rf /usr/lib/go /go /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ENTRYPOINT ["/init"]
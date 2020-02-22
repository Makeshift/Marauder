FROM mumiehub/rclone-mount

COPY 01-custom.sh /etc/cont-init.d/01-custom
COPY 30-cleanup.sh /etc/cont-finish.d/30-cleanup
COPY plexdrive_run.sh /etc/services.d/plexdrive/run

RUN apk --no-cache add gettext libc6-compat curl && \
    curl -o /bin/plexdrive -L \
        "https://github.com/dweidenfeld/plexdrive/releases/download/5.0.0/plexdrive-linux-amd64" && \
    apk del curl && \
    chmod +x /etc/cont-init.d/01-custom \
             /etc/cont-finish.d/30-cleanup \
             /etc/services.d/plexdrive/run \
             /bin/plexdrive

ENTRYPOINT ["/init"]
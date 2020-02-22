FROM mumiehub/rclone-mount

COPY 01-custom.sh /etc/cont-init.d/01-custom
COPY 30-cleanup.sh /etc/cont-finish.d/30-cleanup

RUN apk --no-cache add gettext && \
    chmod +x /etc/cont-init.d/01-custom \
             /etc/cont-finish.d/30-cleanup 

ENTRYPOINT ["/init"]
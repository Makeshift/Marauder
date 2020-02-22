#!/usr/bin/with-contenv sh

fusermount -uz /shared/merged || true
umount /shared/merged || true
rm -r /shared/merged
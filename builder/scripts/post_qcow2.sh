#!/usr/bin/env bash

echo 'Converting raw to qcow2'
qemu-img convert -p -f raw -O qcow2 \
  $CWD/images/stylus-image-builder \
  $CWD/images/stylus-image-builder.qcow2
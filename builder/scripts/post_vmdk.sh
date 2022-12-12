#!/usr/bin/env bash

echo 'Converting raw to vmdk'

qemu-img convert -p -f raw -O vmdk -o adapter_type=lsilogic,subformat=streamOptimized,compat6 \
  $CWD/images/stylus-image-builder \
  $CWD/images/stylus-image-builder.vmdk
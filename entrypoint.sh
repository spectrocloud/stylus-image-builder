#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "No image type defined"
  exit 1
fi

if [ -z "$ISO_URL" ]; then
  echo "Environment Variable ISO_URL must be set"
  exit 1
fi

# ISO should be in /stylus-image-builder/file.iso and can be mounted in or auto-downloaded if not embedded in image
isoFile=$(basename $ISO_URL)

if [ ! -f "$isoFile" ]; then
  echo "Downloading ISO from $ISO_URL"
  wget -q $ISO_URL
fi

echo "Building $1"
PACKER_LOG=1 packer build -var "iso=$isoFile" -var "disk_size=$DISK_SIZE" -only $1.qemu.stylus builder

#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "No image type defined"
  exit 1
fi

if [ -z "$PALETTE_ENDPOINT" ]; then
  echo "Environment Variable PALETTE_ENDPOINT must be set"
  exit 1
fi

if [ -z "$REGISTRATION_URL" ]; then
  echo "Environment Variable REGISTRATION_URL must be set"
  exit 1
fi

if [ -z "$ISO_URL" ]; then
  echo "Environment Variable ISO_URL must be set"
  exit 1
fi

echo "Writing user-data file"
yq e -i '.stylus.site.paletteEndpoint = env(PALETTE_ENDPOINT)' user-data
yq e -i '.stylus.site.registrationURL = env(REGISTRATION_URL)' user-data
if [ -z "$EDGE_HOST_TOKEN" ]; then
  yq e -i '.stylus.site.edgeHostToken = env(EDGE_HOST_TOKEN)' user-data
fi

echo "----------------------USERDATA----------------------"
cat user-data
echo "----------------------USERDATA----------------------"

# ISO should be in /stylus-image-builder/file.iso and can be mounted in or auto-downloaded if not embedded in image
isoFile=$(basename $ISO_URL)

if [ ! -f "$isoFile" ]; then
  echo "Downloading ISO from $ISO_URL"
  wget -q $ISO_URL
fi

echo "Building $1"
PACKER_LOG=1 packer build -var "iso=$isoFile" -var "disk_size=$DISK_SIZE" -only $1.qemu.stylus builder

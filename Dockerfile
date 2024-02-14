FROM ubuntu:focal
ARG ISO_URL=""
ARG EMBED="false"
ARG DISK_SIZE="100000M"

ENV EMBED=${EMBED}
ENV ISO_URL=${ISO_URL}
ENV DISK_SIZE=${DISK_SIZE}

# uncomment and pass build args to make images which need no parameters when ran
#ARG $PALETTE_ENDPOINT=""
#ENV $PALETTE_ENDPOINT=${PALLETE_ENDPOINT}
#ARG REGISTRATION_URL=""
#ENV REGISTRATION_URL=${REGISTRATION_URL}

RUN apt update
RUN apt install -y qemu qemu-kvm libvirt-clients genisoimage unzip wget iat

RUN wget -q https://github.com/mikefarah/yq/releases/download/v4.30.4/yq_linux_amd64; \
    chmod +x yq_linux_amd64; \
    mv yq_linux_amd64 /usr/local/bin/yq; \
    yq --version

RUN wget -q https://releases.hashicorp.com/packer/1.8.4/packer_1.8.4_linux_amd64.zip; \
    unzip packer_1.8.4_linux_amd64.zip; \
    mv packer /usr/local/bin; \
    rm -f packer_1.8.4_linux_amd64.zip

COPY ./ /stylus-image-builder
WORKDIR /stylus-image-builder

RUN if [ "true" = "$EMBED" ]; then \
      wget -q $ISO_URL; \
    fi

ENTRYPOINT ["/stylus-image-builder/entrypoint.sh"]
CMD ["vmdk"]
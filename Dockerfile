FROM gcr.io/spectro-dev-public/stylus/stylus-image-builder-base:v1
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

COPY builder /stylus-image-builder/builder/
COPY *.iso /stylus-image-builder/
COPY stylus-image.yaml /stylus-image-builder/
COPY entrypoint.sh /stylus-image-builder/
WORKDIR /stylus-image-builder

RUN if [ "true" = "$EMBED" ]; then \
    wget -q $ISO_URL; \
    fi

ENTRYPOINT ["/stylus-image-builder/entrypoint.sh"]
CMD ["vmdk"]
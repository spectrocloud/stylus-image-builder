FROM ubuntu:focal

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
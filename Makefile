REPO?=spectrocloud/stylus-image-builder
TAG?=latest
CONTAINER_NAME?=stylus-image-builder

ISO_URL?="stylus-v4.2.3-amd64.iso"
ISO_NAME= $(shell basename $(ISO_URL) .iso)
EMBED?="false"

QCOW2_IMG?=gcr.io/spectro-dev-public/stylus/${ISO_NAME}:latest
BASE_IMG?=gcr.io/spectro-dev-public/stylus/stylus-image-builder-base:v1

PALETTE_ENDPOINT?=""
REGISTRATION_URL?=""
EDGE_HOST_TOKEN?=""
DISK_SIZE?="100000M"

define run
	docker run \
		-v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
		--name ${CONTAINER_NAME}-$1 \
		--device /dev/kvm \
		--privileged --network host \
		-e PALETTE_ENDPOINT=$(PALETTE_ENDPOINT) \
		-e REGISTRATION_URL=$(REGISTRATION_URL) \
		-e DISK_SIZE=$(DISK_SIZE) \
		-e EDGE_HOST_TOKEN=$(EDGE_HOST_TOKEN) \
		$(REPO):$(TAG) $1
endef

images-dir:
	mkdir -p images

docker-build:
	docker buildx build \
		--build-arg EMBED=$(EMBED) \
		--build-arg ISO_URL=$(ISO_URL) \
		--build-arg DISK_SIZE=$(DISK_SIZE) \
		-t $(REPO):$(TAG) .

docker-build-base:
	docker buildx build -t $(BASE_IMG) -f Base.Dockerfile --push .

img: clean-img images-dir
	$(call run,"img")
	docker cp $(CONTAINER_NAME)-img:/stylus-image-builder/images/stylus-image-builder ./images/$(ISO_NAME).img
	-@docker rm ${CONTAINER_NAME}-img 2>/dev/null

clean-img:
	-@docker rm ${CONTAINER_NAME}-img 2>/dev/null

iso: clean-iso images-dir
	$(call run,"iso")
	docker cp $(CONTAINER_NAME)-iso:/stylus-image-builder/images/stylus-image-builder.iso ./images/$(ISO_NAME).iso
	-@docker rm ${CONTAINER_NAME}-iso 2>/dev/null

clean-iso:
	-@docker rm ${CONTAINER_NAME}-iso 2>/dev/null

vmdk: clean-vmdk images-dir
	$(call run,"vmdk")
	docker cp $(CONTAINER_NAME)-vmdk:/stylus-image-builder/images/stylus-image-builder.vmdk ./images/$(ISO_NAME).vmdk
	-@docker rm ${CONTAINER_NAME}-vmdk 2>/dev/null

clean-vmdk:
	-@docker rm ${CONTAINER_NAME}-vmdk 2>/dev/null

qcow2: clean-qcow2 images-dir
	$(call run,"qcow2")
	docker cp $(CONTAINER_NAME)-qcow2:/stylus-image-builder/images/stylus-image-builder.qcow2 ./images/$(ISO_NAME).qcow2
	-@docker rm ${CONTAINER_NAME}-qcow2 2>/dev/null

qcow2-image:
	docker buildx build -t $(QCOW2_IMG) -f Qcow2.Dockerfile --build-arg IMG_NAME=$(ISO_NAME).qcow2 .
	docker push $(QCOW2_IMG)

clean-qcow2:
	-@docker rm ${CONTAINER_NAME}-qcow2 2>/dev/null

clean:
	rm -rf images

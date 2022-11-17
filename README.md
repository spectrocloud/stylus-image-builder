# Stylus Image Builder
Create pre-packaged container images that are ready to consume. This is accomplished by preinstalling stylus via automated image builds.  This project takes an installer ISO and returns a consumable image which is ready to connect back to [Palette](https://www.spectrocloud.com/why-palette/) as an edge host and join a cluster.

To create a pre-installed stylus image you need to:
- Boot the stylus ISO with a cloud-config YAML, which the stylus installer will automatically process
- Power off the machine
- Create the final image

The three most important pieces of data you will need before starting are the following:
1) PALETTE_ENDPOINT - This is the URL to the Palette tenant where you log in to manage your Kubernetes clusters.  
2) REGISTRATION_URL - This is the URL to a registration app for the edge host. This is embedded as link in the QR code with an edge id to be used at installation time.
3) ISO_URL - A stylus installation ISO, downloaded URLs can be found in the Palette UI, navigate to Clusters > Edge Hosts and in the upper right hand corner you wil see `Download Palette Edge Installer`. Additionally, an ISO_URL could be a local file which makes development faster.

## Pre-Requisites
### [QEMU](https://www.qemu.org/)
QEMU is an emulator and virtualizer which is the core of this project. This is necessary to boot a Virtual Machine with a mounted ISO which contains the cloud-config YAML to prapare the image. Testing of this project was done on WSL and Linux Virtual machines. Support for QEMU exists on MacOS but has not explored at this time.

### [Docker](https://www.docker.com/)
Wrapping all the tooling in container images makes this project simple to consume in a CI/CD pipeline. A Dockerfile is supplied  to build container images which contain all the tooling necessary to run the make targets. Please note in order to talk  to QEMU properly we have to run the containers with host networking and privileged mode with mounted devices and sockets.

### [Packer](https://www.packer.io/)
Packer offers a repeatable process through configuration to build images. Packer communicates with QEMU to launch virtual machines and interact with them through the installation process.

## Usage
### Container Image
There are two ways to use the Dockerfile and the container image it generates.

1) Hardcode the ISO_URL/PALETTE_ENDPOINT/REGISTRATION_URL and include the stylus ISO inside the image. This makes a completely self-contained builder which can be passed to an implementor. They will build an image for the system they need it in and can always go back to the original container image to produce more in different formats if their requirements change and have to support a new environment.
2) Dynamically generate images by calling the make targets with Environment variables for ISO_URL/PALETTE_ENDPOINT/REGISTRATION_URL. This lets your CI/CD dynamically generate new images through GitOps or other triggers. 

**Important**: Creating images requires elevated access to the underlying host to communicate with QEMU/kvm. See [Preparing your Build Server](#preparing-your-build-server) for installation guides and make sure where the builder will run is somewhere you can get run as privileged with host networking, devices and sockets mounted.

### Local Development
You can either use Packer directly to generate images from the host, or the Makefile wraps the Dockerfile and abstracts all the utilities need to run packer but needs access to the host.

#### Makefile
**Build a Container Image**
An ISO_URL is required to build the image but is defaulted to the latest stylus installer release if none is passed and can be overridden at runtime. Look at the top of the Makefile for more build options. For instance, you can also set REPO and TAG for your internal processes.

```bash
make docker-build  
```

Once you have an image you can export your configuration and use `make <imagetype>` for the 4 support images. See the [Images](#images-formats) section below for details on each format and what can be done with them.
```bash
export PALETTE_ENDPOINT=#yourendpoint
export REGISTRATION_URL=#yourregurl
make vmdk
```

#### Packer 
You will need a stylus iso in the local directory and pass in the name of the file with `-var iso=<name>`. All builds use the same raw qemu source, you can target each build with `-only vmdk.qemu.stylus`. See the `./builder` directory for variables and read the scripts.

#### Generated Images
After each build all generated images will be in the `./images` directory, they will be named identical to the basename of the passed ISO_URL but with the proper image extension for the chosen format.

#### Tips
- To speed up your dev cycle with the Dockerfile use the layer cache. Keep an installer ISO in the local directory and pass ISO_URL as it's name, the Dockerfile will COPY it in with the scripts and the whole layer will be cached. Skip the auto-download by doing `EMBED=false make docker-build` 

### Preparing your Build Server
The below will walk you through installations for a build server, currently supported is Ubuntu 20.04 and more will be added as they're tested.

#### Using Aptitude in Ubuntu 20.04
```bash
# Install QEMU
apt update
apt install qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager

# install x11-apps if you want GUI, not necessary if headless 
# apt install x11-apps  

systemctl enable --now libvirtd
systemctl enable --now virtlogd

# Install Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### Misc Utilities
Below will install the utilities needed if you want them locally. This is all maintained by the Dockerfile and unnecessary if you use the Makefile development method.

```bash
# Install Packer
wget -q https://releases.hashicorp.com/packer/1.8.4/packer_1.8.4_linux_amd64.zip
unzip packer_1.8.4_linux_amd64.zip
mv packer /usr/local/bin
rm -f packer_1.8.4_linux_amd64.zip

# Install Misc. Utilities
apt install genisoimage unzip wget iat

wget -q https://github.com/mikefarah/yq/releases/download/v4.30.4/yq_linux_amd64
chmod +x yq_linux_amd64
mv yq_linux_amd64 /usr/local/bin/yq
```

## Images Formats
Below is a list of the image formats currently supported and information on their purpose and how to use them.

### img
An uncompressed image format and can be time-consuming to work with, if your disk size is over 5-10gb expect to wait on 
transfers and processing. This format is the most portable and is sometimes called raw.

### qcow2
A compressed image format with thin provisioning support making it portable and supports snapshotting.

### vmdk
A format from VMWare used pervasively across their tooling. This will be the primary format for VCenter, VirtualBox and 
VMWare Workstation. 

### iso
The primary format to build bootable ISO9660 USB/CD/DVD media. This will be the ideal format for a portable media usable in the field to boot and connect edge devices to clusters. Please note this image type uses [iat](https://www.linuxlinks.com/iat/) which can take a long time to process large disks, we recommend keeping your bootable ISO drives not much larger than the contents on the disk.
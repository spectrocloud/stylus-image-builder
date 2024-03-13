source "qemu" "stylus" {
  headless         = var.headless
  iso_url          = "${path.cwd}/${var.iso}"
  iso_checksum     = "none"
  output_directory = "images"
  disk_size        = var.disk_size
  format           = "raw"
  accelerator      = "kvm"
  ssh_username     = "kairos"
  ssh_password     = "kairos"
  ssh_timeout      = "20m"
  cd_files         = ["${path.cwd}/builder/configs/meta-data", "${path.cwd}/builder/configs/user-data"]
  cd_label         = "cidata"
  vm_name          = "stylus-image-builder"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "1s"
  boot_command = [
    "<enter>"
  ]
  shutdown_timeout = "10m"
  qemuargs = [
    ["-m", "8000M"],
    ["-smp", "4"],
  ]
}

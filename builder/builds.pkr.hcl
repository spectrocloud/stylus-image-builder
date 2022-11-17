build {
  name = "img"
  sources = ["source.qemu.stylus"]
  provisioner "shell" {
    environment_vars = ["FILE=/var/run/.stylus-installed"]
    scripts = ["${path.root}/scripts/wait.sh"]
  }
}

build {
  name = "vmdk"
  sources = ["source.qemu.stylus"]
  provisioner "shell" {
    environment_vars = ["FILE=/var/run/.stylus-installed"]
    scripts = ["${path.root}/scripts/wait.sh"]
  }
  post-processor "shell-local" {
    environment_vars = ["CWD=${path.cwd}"]
    scripts = ["${path.root}/scripts/post_vmdk.sh"]
  }
}

build {
  name = "qcow2"
  sources = ["source.qemu.stylus"]
  provisioner "shell" {
    environment_vars = ["FILE=/var/run/.stylus-installed"]
    scripts = ["${path.root}/scripts/wait.sh"]
  }
  post-processor "shell-local" {
    environment_vars = ["CWD=${path.cwd}"]
    scripts = ["${path.root}/scripts/post_qcow2.sh"]
  }
}


build {
  name = "iso"
  sources = ["source.qemu.stylus"]
  provisioner "shell" {
    environment_vars = ["FILE=/var/run/.stylus-installed"]
    scripts = ["${path.root}/scripts/wait.sh"]
  }
  post-processor "shell-local" {
    environment_vars = ["CWD=${path.cwd}"]
    scripts = ["${path.root}/scripts/post_iso.sh"]
  }
}

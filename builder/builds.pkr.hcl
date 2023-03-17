build {
  name = "img"
  sources = ["source.qemu.stylus"]
  provisioner "shell" {
    scripts = ["${path.root}/scripts/wait.sh"]
    expect_disconnect = true
    skip_clean = true
  }
}

build {
  name = "vmdk"
  sources = ["source.qemu.stylus"]
  provisioner "shell" {
    scripts = ["${path.root}/scripts/wait.sh"]
    expect_disconnect = true
    skip_clean = true
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
    scripts = ["${path.root}/scripts/wait.sh"]
    expect_disconnect = true
    skip_clean = true
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
    scripts = ["${path.root}/scripts/wait.sh"]
    expect_disconnect = true
    skip_clean = true
  }
  post-processor "shell-local" {
    environment_vars = ["CWD=${path.cwd}"]
    scripts = ["${path.root}/scripts/post_iso.sh"]
  }
}

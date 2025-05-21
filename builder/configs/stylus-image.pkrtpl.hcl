#cloud-config
install:
  reboot: false
  poweroff: true
stylus:
  debug: false
stages:
  before-install:
    - name: "Remove machine-id"
      if: '[ -f "/run/cos/live_mode" ]'
      commands:
        - echo -n > /etc/machine-id
  initramfs:
    - users:
        ${ssh_user}:
          groups:
            - sudo
          passwd: ${ssh_password}
      name: "Create ${ssh_user} user"

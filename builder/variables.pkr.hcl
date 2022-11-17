# only change headless during local development to see gui
# errors will be "gtk initialization failed" if false and running in a container
variable "headless" {
  type    = bool
  default = true
}

variable "iso" {
  type    = string
  default = "stylus.iso"
}

variable "disk_size" {
  type    = string
  default = "50000M"
}
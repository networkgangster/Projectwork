variable "zone" {
  default = "at-vie-1"
}

variable "template" {
  default = "Linux Ubuntu 20.04 LTS 64-bit"
}

data "exoscale_compute_template" "instancepool" {
  zone = var.zone
  name = var.template
}

resource "exoscale_instance_pool" "projectwork_instancepool" {
  name = "projectwork_instancepool"
  description = "test"
  template_id = data.exoscale_compute_template.instancepool.id
  service_offering = "micro"
  size = 3
  disk_size = 10
  user_data = file("userdata.sh")
  key_pair = ""
  security_group_ids = [exoscale_security_group.sg.name]
  zone = var.zone
 
}
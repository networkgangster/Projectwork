resource "exoscale_compute" "projectwork_monitoring_instance" {
  display_name = "monitoring"
  template_id = data.exoscale_compute_template.instancepool.id
  size = "Small"
  disk_size = 10
  user_data = templatefile("monitoring-instance-userdata.sh.tpl", {
    exoscale_key = var.exoscale_key
    exoscale_secret = var.exoscale_secret
    exoscale_zone_id = var.exoscale_zone_id
    instance_pool_id = exoscale_instance_pool.projectwork_instancepool.id
  })
  key_pair = exoscale_ssh_keypair.ssh_keypair.id
  security_group_ids = [exoscale_security_group.sg.id]
  zone = var.zone
}

variable "exoscale_zone_id" {
  type = string
  description = "ID of the exoscale zone"
  default = "4da1b188-dcd6-4ff5-b7fd-bde984055548"
}
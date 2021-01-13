resource "exoscale_compute" "projectwork_monitoring_instance" {
  display_name = "monitoring"
  template_id = data.exoscale_compute_template.instancepool.id
  size = "Small"
  disk_size = 10
  user_data = templatefile("monitoring-instance-userdata.sh.tpl", {
    exoscale_key = var.exoscale_key
    exoscale_secret = var.exoscale_secret
    instance_pool_id = exoscale_instance_pool.projectwork_instancepool.id
  })
  key_pair = ""
  security_group_ids = [exoscale_security_group.sg.id]
  zone = var.zone
}
variable "admin_ip" {
  description = "Administrator IP address"
  type = string
  default = "0.0.0.0/0"
}

resource "exoscale_security_group" "sg" {
  name = "projectwork"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = "0.0.0.0/0"
  start_port = 80
  end_port = 80
}
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

resource "exoscale_security_group_rule" "HTTP" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = "0.0.0.0/0"
  start_port = 8080
  end_port = 8080
}

resource "exoscale_security_group_rule" "prometheus" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = "0.0.0.0/0"
  start_port = 9090
  end_port = 9090
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = "0.0.0.0/0"
  start_port = 22
  end_port = 22
}

resource "exoscale_security_group_rule" "nodeexporter" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = "0.0.0.0/0"
  start_port = 9100
  end_port = 9100
}

resource "exoscale_security_group_rule" "grafana" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = "0.0.0.0/0"
  start_port = 3000
  end_port = 3000
}

resource "exoscale_security_group_rule" "autoscaler" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = "0.0.0.0/0"
  start_port = 8090
  end_port = 8090
}
resource "exoscale_nlb" "projectwork_nlb" {
  zone = var.zone
  name = "projectwork_nlb"
  description = "This is the Network Load Balancer for my website"
}

resource "exoscale_nlb_service" "projectwork_nlb_service" {
  zone             = exoscale_nlb.projectwork_nlb.zone
  name             = "projectwork-http"
  description      = "Website over HTTP"
  nlb_id           = exoscale_nlb.projectwork_nlb.id
  instance_pool_id = exoscale_instance_pool.projectwork_instancepool.id
    protocol       = "tcp"
    port           = 80
    target_port    = 8080
    strategy       = "round-robin"

  healthcheck {
    mode     = "http"
    port     = 8080
    uri      = "/health"
    interval = 5
    timeout  = 3
    retries  = 1
  }
}
module "alb_security_group_public" {
  source  = "registry.terraform.io/terraform-aws-modules/security-group/aws"
  version = ">= 4.17"

  name            = "alb-ingress"
  use_name_prefix = false
  vpc_id          = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_ipv6_cidr_blocks = ["::/0"]
  ingress_rules            = ["http-80-tcp", "https-443-tcp"]
  egress_rules             = ["all-all"]
}

resource "aws_lb" "public" {
  name               = "sharp-sed"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [module.alb_security_group_public.security_group_id, aws_security_group.allow_to_app.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Request was not routed."
      status_code  = 400
    }
  }
}

output "web_address" {
  value = "https://${aws_lb.public.dns_name}/"
}

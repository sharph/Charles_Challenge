locals {
  page_content = <<EOF
<html>
<head>
<title>Hello World</title>
</head>
<body>
<h1>Hello World!</h1>
</body>
</html>
EOF
}


module "ecs_egress" {
  source  = "registry.terraform.io/terraform-aws-modules/security-group/aws"
  version = ">= 4.17"

  name            = "ecs-egress"
  use_name_prefix = false
  vpc_id          = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_ipv6_cidr_blocks = ["::/0"]
  ingress_rules            = []
  egress_rules             = ["all-all"]
}

resource "aws_security_group" "allow_from_lb" {
  name = "allow_from_lb"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "allow_to_app" {
  name = "allow_to_app"
  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_lb" {
  security_group_id            = aws_security_group.allow_from_lb.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.allow_to_app.id
  from_port                    = 80
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_to_app" {
  security_group_id            = aws_security_group.allow_to_app.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.allow_from_lb.id
  from_port                    = 80
  to_port                      = 80
}



module "service" {
  source = "registry.terraform.io/stroeer/ecs-fargate/aws"
  version = "0.44.2"

  cpu                           = 256
  cluster_id                    = aws_ecs_cluster.cluster.id
  container_port                = 80
  create_ingress_security_group = false
  create_deployment_pipeline    = false
  create_ecr_repository         = false
  desired_count                 = 1
  ecr_force_delete              = true
  memory                        = 512
  service_name                  = "sharp-sed-challenge-service"
  vpc_id                        = module.vpc.vpc_id
  security_groups               = [module.ecs_egress.security_group_id, aws_security_group.allow_from_lb.id]

  container_definition_overwrites = {
    image                  = "nginx:latest"
    readonlyRootFilesystem = false
    command                = ["bash", "-c", "echo $CONTENTS > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]

    environment = [
      { name = "CONTENTS", value = local.page_content }
    ]
  }

  https_listener_rules = [{
    listener_arn = aws_lb_listener.https.arn

    actions = [{
      type               = "forward"
      target_group_index = 0
    }]

    conditions = [{
      path_patterns = ["/"]
    }]
  }]

  target_groups = [
    {
      name              = "sharp-sed-challenge"
      backend_protocol  = "HTTP"
      backend_port      = 80
      load_balancer_arn = aws_lb.public.arn
      target_type       = "ip"

      health_check = {
        enabled  = true
        path     = "/"
        protocol = "HTTP"
      }
    }
  ]
}

resource "aws_alb" "dotcom_fargate" {
  name            = "tf-ecs-dotcom"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "dotcom_fargate" {
  name        = "tf-ecs-dotcom"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dotcom_fargate.id
  target_type = "ip"
}

# Redirect all traffic from 80 to 443
resource "aws_alb_listener" "front_end80" {
  load_balancer_arn = aws_alb.dotcom_fargate.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end443" {
  load_balancer_arn = aws_alb.dotcom_fargate.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.elb_security_policy
  certificate_arn   = aws_acm_certificate_validation.default.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.dotcom_fargate.id
    type             = "forward"
  }
}

# Set up DNS
data "aws_route53_zone" "selected" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "dotcom_fargate_hosted_zone_entry" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "${var.subdomain}${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.dotcom_fargate.dns_name]
}

# Get a certificate
resource "aws_acm_certificate" "default" {
  domain_name               = var.hosted_zone_name
  subject_alternative_names = ["*.${var.hosted_zone_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# To use DNS validation
resource "aws_route53_record" "validation" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = aws_acm_certificate.default.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.default.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.default.domain_validation_options[0].resource_record_value]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn

  validation_record_fqdns = [
    aws_route53_record.validation.fqdn,
  ]
}


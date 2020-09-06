resource "aws_lb" "dotcom_fargate" {
  name               = "tf-ecs-dotcom"
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.lb.id]

  access_logs {
    bucket  = aws_s3_bucket.dotcom_fargate.bucket
    prefix  = "lb-log"
    enabled = true
  }
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "dotcom_fargate" {
  bucket = "dotcom-fargate-logs"
  acl    = "private"

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::dotcom-fargate-logs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_lb_target_group" "dotcom_fargate" {
  name        = "tf-ecs-dotcom"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dotcom_fargate.id
  target_type = "ip"
}

# Redirect all traffic from 80 to 443
resource "aws_lb_listener" "front_end80" {
  load_balancer_arn = aws_lb.dotcom_fargate.id
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
resource "aws_lb_listener" "front_end443" {
  load_balancer_arn = aws_lb.dotcom_fargate.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.elb_security_policy
  certificate_arn   = aws_acm_certificate_validation.default.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.dotcom_fargate.id
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "secondary" {
  listener_arn    = aws_lb_listener.front_end443.arn
  certificate_arn = aws_acm_certificate_validation.secondary.certificate_arn
}

# Set up DNS
data "aws_route53_zone" "selected" {
  name = var.hosted_zone_name
}

data "aws_route53_zone" "secondary" {
  name = var.secondary_zone_name
}

resource "aws_route53_record" "dotcom_fargate_hosted_zone_subdomain" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "${var.subdomain}${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.dotcom_fargate.dns_name]
}

resource "aws_route53_record" "dotcom_fargate_secondary_zone_subdomain" {
  zone_id = data.aws_route53_zone.secondary.id
  name    = "${var.subdomain}${data.aws_route53_zone.secondary.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.dotcom_fargate.dns_name]
}

resource "aws_route53_record" "dotcom_fargate_secondary_zone_entry" {
  zone_id = data.aws_route53_zone.secondary.id
  name    = data.aws_route53_zone.secondary.name
  type    = "A"

  alias {
    name                   = aws_lb.dotcom_fargate.dns_name
    zone_id                = aws_lb.dotcom_fargate.zone_id
    evaluate_target_health = true
  }
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

resource "aws_acm_certificate" "secondary" {
  domain_name               = var.secondary_zone_name
  subject_alternative_names = ["*.${var.secondary_zone_name}"]
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

resource "aws_route53_record" "validation_secondary" {
  zone_id = data.aws_route53_zone.secondary.zone_id
  name    = aws_acm_certificate.secondary.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.secondary.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.secondary.domain_validation_options[0].resource_record_value]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "secondary" {
  certificate_arn = aws_acm_certificate.secondary.arn

  validation_record_fqdns = [
    aws_route53_record.validation_secondary.fqdn,
  ]
}
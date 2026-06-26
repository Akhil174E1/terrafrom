# ─── S3 Bucket for ALB Access Logs ───────────────────────────────────────────

resource "aws_s3_bucket" "lb_logs" {
  bucket        = "${var.project_name}-lb-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true                               # ENHANCEMENT: safe cleanup in dev

  tags = { Name = "${var.project_name}-lb-logs" }
}

resource "aws_s3_bucket_policy" "lb_logs" {        # ENHANCEMENT: required for ALB logging
  bucket = aws_s3_bucket.lb_logs.id
  policy = data.aws_iam_policy_document.lb_logs.json
}

data "aws_iam_policy_document" "lb_logs" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.lb_logs.arn}/*"]
  }
}

data "aws_caller_identity" "current" {}

# ─── External ALB (internet-facing → frontend) ────────────────────────────────

resource "aws_lb" "lb-external" {
  name               = "${var.project_name}-lb-external"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-lb-external.id]
  # FIX: was referencing undefined aws_subnet.public — now uses explicit resources
  # ENHANCEMENT: two public subnets across AZs (required by ALB)
  subnets = [
    aws_subnet.public-front-01.id,
    aws_subnet.public-front-02.id,
  ]

  enable_deletion_protection = false                # set true for production

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "external-lb"
    enabled = true
  }

  tags = { Name = "${var.project_name}-lb-external" }
}

# ─── External ALB Target Group (frontend instances) ───────────────────────────

resource "aws_lb_target_group" "frontend" {         # ENHANCEMENT: was missing entirely
  name     = "${var.project_name}-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = { Name = "${var.project_name}-frontend-tg" }
}

resource "aws_lb_target_group_attachment" "frontend-01" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend-01.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "frontend-02" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend-02.id
  port             = 80
}

# ─── External ALB Listener ────────────────────────────────────────────────────

resource "aws_lb_listener" "external-http" {        # ENHANCEMENT: was missing entirely
  load_balancer_arn = aws_lb.lb-external.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ─── Internal ALB (frontend → backend) ───────────────────────────────────────

resource "aws_lb" "lb-internal" {
  name               = "${var.project_name}-lb-internal"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-lb-internal.id]
  # FIX: internal ALB should be in private backend subnets, not public
  subnets = [
    aws_subnet.private-back-01.id,
    aws_subnet.private-back-02.id,
  ]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "internal-lb"
    enabled = true
  }

  tags = { Name = "${var.project_name}-lb-internal" }
}

# ─── Internal ALB Target Group (backend instances) ────────────────────────────

resource "aws_lb_target_group" "backend" {          # ENHANCEMENT: was missing entirely
  name     = "${var.project_name}-backend-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/actuator/health"         # Spring Boot health endpoint
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = { Name = "${var.project_name}-backend-tg" }
}

resource "aws_lb_target_group_attachment" "backend-01" {
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = aws_instance.backend-01.id
  port             = var.app_port
}

resource "aws_lb_target_group_attachment" "backend-02" {
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = aws_instance.backend-02.id
  port             = var.app_port
}

# ─── Internal ALB Listener ────────────────────────────────────────────────────

resource "aws_lb_listener" "internal-app" {         # ENHANCEMENT: was missing entirely
  load_balancer_arn = aws_lb.lb-internal.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

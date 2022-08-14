# ###############lb#################
resource "aws_lb" "loadbalancer" {
  name               = "loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.securitygroup.id]
  subnets            = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]

 
}

#######################TARGET-GROUP###################
resource "aws_lb_target_group" "targetgroup" {
  name     = "targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.virtual1.id
}
#######################Resource-added###########
resource "aws_lb_target_group_attachment" "resourceattached1" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.ubuntu1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "resourceattached2" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.ubuntu2.id
   port             = 80
}
#######################listner-GROUP###########
resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}


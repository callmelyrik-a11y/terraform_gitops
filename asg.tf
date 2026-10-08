resource "aws_launch_template" "MyLaunchTemplate" {
  depends_on             = [aws_security_group.MySecugroup]
  name_prefix            = "MyAutoScalingGroup"
  instance_type          = "t3.micro"
  image_id               = data.aws_ami.LatestAmi.id
  key_name               = aws_key_pair.tf_keypair.key_name
  vpc_security_group_ids = [aws_security_group.MySecugroup.id]

  user_data = filebase64("${path.module}/script.sh")

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_autoscaling_group" "MyAutoScalingGroup" {
  depends_on          = [aws_launch_template.MyLaunchTemplate, aws_nat_gateway.MyNatGW1, aws_nat_gateway.MyNatGW2]
  name                = "MyAutoScalingGroup"
  desired_capacity    = 4
  max_size            = 6
  min_size            = 4
  vpc_zone_identifier = [aws_subnet.MyPrivate1Subnet.id, aws_subnet.MyPrivate2Subnet.id]

  launch_template {
    id      = aws_launch_template.MyLaunchTemplate.id
    version = aws_launch_template.MyLaunchTemplate.latest_version
  }

  tag {
    key                 = "Name"
    value               = "MyAutoScalingGroup"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

resource "aws_autoscaling_attachment" "MyAutoScalingALBattachment" {
  autoscaling_group_name = aws_autoscaling_group.MyAutoScalingGroup.id
  lb_target_group_arn    = aws_lb_target_group.MyALBtargetgroup.arn
}

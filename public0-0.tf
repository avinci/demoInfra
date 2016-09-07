# ========================ECS Instances=======================
# ECS Instance Security group
resource "aws_security_group" "demoInstSG" {
  name = "demoInstSG"
  description = "ECS instance security group"
  vpc_id = "${aws_vpc.demoVPC.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = [
      "${var.public0-0CIDR}"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags {
    Name = "demoInstSG"
  }
}

# Web Security group
resource "aws_security_group" "demoWebSG" {
  name = "demoWebSG"
  description = "Web traffic security group"
  vpc_id = "${aws_vpc.demoVPC.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "${var.public0-0CIDR}"]
  }
  tags {
    Name = "demoWebSG"
  }
}

# Container instances for ECS Test
resource "aws_instance" "testECSIns" {
  depends_on = [
    "aws_ecs_cluster.test-aws"]

  count = 2

  # ami = "${var.ecsAmi}"
  ami = "${lookup(var.ecsAmi, var.region)}"
  availability_zone = "${lookup(var.availability_zone, var.region)}"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  subnet_id = "${aws_subnet.demoPubSN0-0.id}"
  iam_instance_profile = "${aws_iam_instance_profile.demoECSInstProf.name}"
  associate_public_ip_address = true
  source_dest_check = false
  user_data = "#!/bin/bash \n echo ECS_CLUSTER=${aws_ecs_cluster.test-aws.name} >> /etc/ecs/ecs.config"

  security_groups = [
    "${aws_security_group.demoInstSG.id}"]

  tags = {
    Name = "demoTestECSIns${count.index}"
  }
}

# Container instances for ECS Prod
resource "aws_instance" "prodECSIns" {
  depends_on = [
    "aws_ecs_cluster.prod-aws"]

  count = 3

  # ami = "${var.ecsAmi}"
  ami = "${lookup(var.ecsAmi, var.region)}"
  availability_zone = "${lookup(var.availability_zone, var.region)}"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  subnet_id = "${aws_subnet.demoPubSN0-0.id}"
  iam_instance_profile = "${aws_iam_instance_profile.demoECSInstProf.name}"
  associate_public_ip_address = true
  source_dest_check = false
  user_data = "#!/bin/bash \n echo ECS_CLUSTER=${aws_ecs_cluster.prod-aws.name} >> /etc/ecs/ecs.config"

  security_groups = [
    "${aws_security_group.demoInstSG.id}"]

  tags = {
    Name = "demoProdECSIns${count.index}"
  }
}

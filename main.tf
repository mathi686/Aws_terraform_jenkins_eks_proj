resource "aws_vpc" "newvpc" {
  cidr_block = "10.0.0.0/16" # Corrected the CIDR block
}

resource "aws_subnet" "newpublic" {
  cidr_block          = "10.0.1.0/24" # Corrected the CIDR block
  vpc_id              = aws_vpc.newvpc.id
  availability_zone   = "us-east-2a" # Corrected availability_zone
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "new-IGW" {
  vpc_id = aws_vpc.newvpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.newvpc.id

  route {
    gateway_id     = aws_internet_gateway.new-IGW.id
    cidr_block     = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "rtas" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.newpublic.id
}

resource "aws_security_group" "secgp" {
  name        = "new_secgp"
  vpc_id      = aws_vpc.newvpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "newpublic-ins" {
  ami                    = "ami-0d406e26e5ad4de53"
  subnet_id              = aws_subnet.newpublic.id
  availability_zone      = "us-east-2a" # Specify the desired availability zone
  vpc_security_group_ids = [aws_security_group.secgp.id]
  key_name               = "lost_key" # Replace with your SSH key name
  # Other instance configuration options like instance type, etc.
  instance_type = "t2.micro"
  tags = {
    name = "lost"
  }
}

resource "aws_instance" "newpublic-insrec" {
  ami                    = "ami-0d406e26e5ad4de53"
  subnet_id              = aws_subnet.newpublic.id
  availability_zone      = "us-east-2a" # Specify the desired availability zone
  vpc_security_group_ids = [aws_security_group.secgp.id]
  key_name               = "recovery_key" # Replace with your SSH key name
  instance_type = "t2.micro"
  # Other instance configuration options like instance type, etc.
  tags = {
    name = "rec1"
  }
}

resource "aws_sns_topic" "new-cpu-and-mem" {
  name = "cpu-mem"
}
resource "aws_sns_topic_subscription" "gmailsub" {
  topic_arn = aws_sns_topic.new-cpu-and-mem.arn
  endpoint  = "harshi10neela@gmail.com"
  protocol  = "email"
}

resource "aws_cloudwatch_metric_alarm" "newalrmforCPU" {
  alarm_name          = "cpuutil"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold = 15
  namespace = "AWS/EC2"
  metric_name = "CPUutilazation"
  alarm_actions = [aws_sns_topic.new-cpu-and-mem.arn]
  period = 30
  statistic           = "Average"
  alarm_description = "hey you cpu mem is increased"
  dimensions = {
    instanceid = aws_instance.newpublic-insrec.id
  }
}


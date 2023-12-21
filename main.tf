############### I am Policy ####################
resource "aws_iam_policy" "policy" {
  name        = "${var.component}.${var.env}.ssm.policy"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DescribeParameters"
        ],
        "Resource": "arn:aws:ssm:us-east-1:207072006229:parameter/roboshop.${var.env}.${var.component}.*"
      }
    ]
  })
}

################ I am role ##################
resource "aws_iam_role" "role" {
  name = "${var.component}.${var.env}.ec2role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}
################ I am instance profile#####################
resource "aws_iam_instance_profile" "profile" {
  name = "${var.component}.${var.env}"
  role = aws_iam_role.role.name
}
################ Policy attachment##############
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

#################instance resource##############
resource "aws_instance" "web" {
  ami           = data.aws_ami.example.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.skype.name]

  tags = {
    Name = "venkata"
  }
}

###########Security group ###############
resource "aws_security_group" "skype" {
  name        = "sallow-all"
  description = "Allow TLS inbound traffic"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sallow-all"
  }
}

################################# creating route53 records #########################
resource "aws_route53_record" "www" {
  zone_id = "Z052192021EEIDGN6IJYI"
  name    = "${var.component}-${var.env}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web.private_ip]
}
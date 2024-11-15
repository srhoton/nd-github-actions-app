data "aws_vpc" "main" {
  tags = {
    Name = "${var.environment}-default_vpc"
  }
}

data "aws_subnet" "private_1" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags = {
    Name = "private-1"
  }
}

data "aws_subnet" "private_2" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags = {
    Name = "private-2"
  }
}

data "aws_subnet" "private_3" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags = {
    Name = "private-3"
  }
}

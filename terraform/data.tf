data "aws_vpc" "main" {
  tags = {
    Name = "default_vpc"
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

data "aws_subnet" "public_1" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags = {
    Name = "public-1"
  }
}

data "aws_subnet" "public_2" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags = {
    Name = "public-2"
  }
}

data "aws_subnet" "public_3" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags = {
    Name = "public-3"
  }
}

data "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"
}

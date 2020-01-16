resource "aws_vpc" "main" {
  cidr_block = "172.20.0.0/16"

  tags = "${
    map(
      "Name", "main",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}


resource "aws_subnet" "public" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "172.20.${count.index}.0/24"
  vpc_id            = "${aws_vpc.main.id}"

  tags = "${
    map(
      "Name", "public",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}
resource "aws_subnet" "private" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.private_subnets[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"

  tags = "${
    map(
      "Name", "private",
    )
  }"
}
resource "aws_internet_gateway" "this" {

  vpc_id = "${aws_vpc.main.id}"

}
resource "aws_route_table" "public" {

  vpc_id = "${aws_vpc.main.id}"

}
resource "aws_route" "public_internet_gateway" {

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  lifecycle {
    ignore_changes = ["propagating_vgws"]
  }
}

resource "aws_eip" "nat" {
    count = "2"
    vpc = true
}

resource "aws_nat_gateway" "this" {

  allocation_id = "${aws_eip.nat.*.id}"
  subnet_id     = "${element(aws_subnet.public.*.id,1)}"
  depends_on = ["aws_internet_gateway.this"]
}

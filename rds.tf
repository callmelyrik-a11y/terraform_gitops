resource "aws_security_group" "MyDBSecugroup" {
  name        = "MyDBSecugroup"
  description = "Permit MySQL"
  vpc_id      = aws_vpc.MyVPC08.id
  tags = {
    Name = "MyDBSecugroup"
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "MyDBSubnetGroup" {
  name        = "mydbsubnetgroup"
  subnet_ids  = [aws_subnet.MyPrivate1Subnet.id, aws_subnet.MyPrivate2Subnet.id]
  description = "Subnet group for mydb"

  tags = {
    Name = "MyDBSubnetGroup"
  }
}

resource "aws_rds_cluster" "MyDBCluster" {
  depends_on             = [aws_db_subnet_group.MyDBSubnetGroup, aws_db_subnet_group.MyDBSubnetGroup]
  cluster_identifier     = "mydb"
  engine                 = "aurora-mysql"
  engine_version         = "8.0.mysql_aurora.3.10.3"
  engine_mode            = "provisioned"
  availability_zones     = ["ap-northeast-2a", "ap-northeast-2c", ]
  database_name          = "testdb"
  master_username        = "dbadmin"
  master_password        = "toor1234."
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.MyDBSubnetGroup.id
  vpc_security_group_ids = [aws_security_group.MyDBSecugroup.id]
}

resource "aws_rds_cluster_instance" "MyDB1" {
  depends_on                 = [aws_rds_cluster.MyDBCluster]
  identifier                 = "mydb-1"
  cluster_identifier         = aws_rds_cluster.MyDBCluster.id
  engine                     = "aurora-mysql"
  engine_version             = "8.0.mysql_aurora.3.10.3"
  availability_zone          = "ap-northeast-2a"
  db_subnet_group_name       = aws_db_subnet_group.MyDBSubnetGroup.id
  auto_minor_version_upgrade = false
}

resource "aws_rds_cluster_instance" "MyDB2" {
  depends_on                 = [aws_rds_cluster_instance.MyDB1]
  identifier                 = "mydb-2"
  cluster_identifier         = aws_rds_cluster.MyDBCluster.id
  engine                     = "aurora-mysql"
  engine_version             = "8.0.mysql_aurora.3.10.3"
  availability_zone          = "ap-northeast-2c"
  db_subnet_group_name       = aws_db_subnet_group.MyDBSubnetGroup.id
  auto_minor_version_upgrade = false
}

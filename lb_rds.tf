resource "aws_rds_cluster" "wordpress_cluster" {
  cluster_identifier      = "wordpress-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.05.2"
  database_name           = "WPDB"
  master_username         = "admin"
  master_password         = "MySQLadm1n"
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.wordpress_db_subnet_group.name
  storage_encrypted       = false
  backup_retention_period = 0
  preferred_backup_window = ""
  apply_immediately       = true
  port                    = 3306

  tags = {
    Name        = "wordpress-cluster"
    Environment = "Project"
  }
}

resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name        = "wordpress-db-subnet-group"
    Environment = "Project"
  }
}

resource "aws_rds_cluster_instance" "primary_instance" {
  identifier              = "wordpress-cluster-primary"
  cluster_identifier      = aws_rds_cluster.wordpress_cluster.id
  instance_class          = "db.t3.medium"
  engine                  = aws_rds_cluster.wordpress_cluster.engine
  engine_version          = aws_rds_cluster.wordpress_cluster.engine_version
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.wordpress_db_subnet_group.name
  apply_immediately       = true
  availability_zone       = "us-west-2a"

  tags = {
    Name        = "wordpress-cluster-primary"
    Environment = "Project"
  }
}

resource "aws_rds_cluster_instance" "secondary_instance" {
  identifier              = "wordpress-cluster-secondary"
  cluster_identifier      = aws_rds_cluster.wordpress_cluster.id
  instance_class          = "db.t3.medium"
  engine                  = aws_rds_cluster.wordpress_cluster.engine
  engine_version          = aws_rds_cluster.wordpress_cluster.engine_version
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.wordpress_db_subnet_group.name
  apply_immediately       = true
  availability_zone       = "us-west-2b"

  tags = {
    Name        = "wordpress-cluster-secondary"
    Environment = "Project"
  }
}
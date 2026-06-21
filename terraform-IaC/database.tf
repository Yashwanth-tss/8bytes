resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = [aws_subnet.private_az_1.id, aws_subnet.private_az_2.id]
  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.environment}-postgres-db"
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres15"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}
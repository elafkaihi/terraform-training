resource "aws_db_subnet_group" "vprofile-rds-subgrp" {
  name        = "vprofile-rds-subgrp"
  description = "vprofile-rds-subgrp"
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1],
    module.vpc.private_subnets[2]
  ]

  tags = {
    Name = "subnet-group-db"
  }
}

resource "aws_elasticache_subnet_group" "vprofile-ecache-subgrp" {
  name        = "vprofile-ecache-subgrp"
  description = "vprofile-ecache-subgrp"
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1],
    module.vpc.private_subnets[2]
  ]

  tags = {
    Name = "subnet-group-ecache"
  }
}

resource "aws_db_instance" "vprofile-rds" {
  identifier             = "vprofile-rds-instance"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  name                   = var.dbname
  username               = var.dbuser
  password               = var.dbpass
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.vprofile-rds-subgrp.name
  vpc_security_group_ids = [aws_security_group.vprofile-backend-sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "vprofile-rds-instance"
  }
}


resource "aws_elasticache_cluster" "elafkaihi-cache" {
  cluster_id           = "elafkaihi-cache"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.5"
  subnet_group_name    = aws_elasticache_subnet_group.vprofile-ecache-subgrp.name
  security_group_ids   = [aws_security_group.vprofile-backend-sg.id]

  tags = {
    Name = "elafkaihi-cache"
  }
}

resource "aws_mq_broker" "elafkaihi-rmq" {
  broker_name          = "elafkaihi-broker"
  broker_instance_type = "mq.t2.micro"
  engine_type          = "ActiveMQ"
  engine_version       = "5.15.14"
  security_groups      = [aws_security_group.vprofile-backend-sg.id]
  subnet_ids           = [module.vpc.private_subnets[0]]
  user {
    username = var.rmquser
    password = var.rmqpass
  }
  tags = {
    Name = "elafkaihi-broker"
  }
}
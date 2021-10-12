variable "instance_class" {
  type    = string
  default = "db.t2.large"
}
variable vpc_cidr_block{}
variable vpc_id {}
variable subnet_ids {}

resource "aws_ssm_parameter" "password" {
  name  = "RDS_Password"
  type  = "SecureString"
  value = random_password.this.result
}

resource "random_password" "this" {
  length           = 12
  special          = false
  min_lower = 1
  min_numeric = 1
  min_special = 1
  min_upper = 1
}


module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "demodb"

  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.large"
  allocated_storage = 20

  name     = "demodb"
  username = "user"
  password = random_password.this.result
  port     = "3306"
  multi_az = true

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.allow_from_vpc.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_name = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = var.subnet_ids

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name = "character_set_client"
      value = "utf8mb4"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

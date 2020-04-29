variable "ecs_task_execution_role" {
  default = "arn role"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "VPC" {
  default = "vpc-123456"
}

variable "public-subnet-1a" {
  default = "subnet-123456"
}

variable "public-subnet-1b" {
  default = "subnet-123456"
}
variable "private-subnet-1a" {
  default = "subnet-1234566789"
}
variable "private-subnet-1b" {
  default = "subnet-12334333"
}
variable "ecs-sg" {
  default = "sg-23434334"
}
variable "ping-sg" {
  default = "sg-4543433"
}
variable "alb-sg" {
  default = "sg-34343334"
}
variable "image-arn" {
  default = "image arn"
}
variable "db-name-postgres" {
  default = "DB_NAME"  
}
variable "db-user-postgres" {
  default = "DB_USER"  
}
variable "db-pwd-postgres" {
  default = "DB_PASSWORD"  
}
variable "db-host-postgres" {
  default = "DB_HOST" 
}
variable "db-port-postgres" {
  default = "DB_PORT" 
}
variable "db-name" {
  default = "test"  
}
variable "db-user" {
  default = "name"  
}
variable "db-password" {
  default = "name"  
}
variable "db-host" {
  default = "dbhost"  
}
variable "db-port" {
  default = "port"  
}
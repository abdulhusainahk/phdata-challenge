variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
  type = string
  default = "10.0.1.0/24"
}
variable "mysql_admin_username" {
  description = "MySQL username"
  type        = string
  default     = "admin"
}
variable "mysql_admin_password" {
  description = "valid password for MySQL"
  type        = string
}
variable "port" {
  description = "MySQL port"
  type        = number
  default     = 3307
}
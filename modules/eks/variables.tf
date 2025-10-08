variable "vpc_id" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "cluster_role_arn" {
  type = string
}
variable "node_role_arn" {
  type = string
}
variable "cluster_security_group" {
  type = string
}
variable "node_security_group" {
  type = string
}
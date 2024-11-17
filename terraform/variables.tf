variable "environment" {
  description = "The environment in which the resources are created"
  type        = string
  default     = "dev"
}
variable "repository" {
  description = "The repository being used"
  type        = string
  default     = "dev"
}
variable "tag" {
  description = "The tag of the image"
  type        = string
  default     = "latest"
}

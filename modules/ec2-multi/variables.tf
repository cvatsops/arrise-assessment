variable "instances" {
  type = map(object({
    ami                   = string
    instance_type         = string
    key_name              = string
    subnet_id             = string
    vpc_security_group_ids = list(string)
    root_volume_type      = string           
    root_volume_size      = number           
    root_volume_iops      = optional(number)
    environment           = string
    owner                 = string
    prevent_destroy       = optional(bool, false)
  }))

  validation {
    condition = alltrue([
      for k, v in var.instances :
      contains(["gp2", "gp3", "io1", "io2", "st1", "sc1", "standard"], v.root_volume_type)
    ])
    error_message = "root_volume_type must be a valid EBS volume type (gp2, gp3, io1, io2, st1, sc1, standard)."
  }

  validation {
    condition = alltrue([
      for k, v in var.instances :
      v.root_volume_type != "io1" && v.root_volume_type != "io2" ? true : v.root_volume_iops != null
    ])
    error_message = "root_volume_iops is required when root_volume_type is io1 or io2."
  }
}

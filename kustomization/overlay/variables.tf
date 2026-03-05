variable "configuration" {
  type = map(object({
    # list of kustomization resources to include
    resources = optional(list(string))

    # Below are all Kustomization built-in
    # attributes that modules pass through to the
    # kustomizatoin_overlay data source
    common_annotations = optional(map(string))
    common_labels      = optional(map(string))
    components         = optional(list(string))
    config_map_generator = optional(list(object({
      name      = optional(string)
      namespace = optional(string)
      behavior  = optional(string)
      envs      = optional(list(string))
      files     = optional(list(string))
      literals  = optional(list(string))
      options = optional(object({
        labels                   = optional(map(string))
        annotations              = optional(map(string))
        disable_name_suffix_hash = optional(bool)
      }))
    })))
    crds       = optional(list(string))
    generators = optional(list(string))
    generator_options = optional(object({
      labels                   = optional(map(string))
      annotations              = optional(map(string))
      disable_name_suffix_hash = optional(bool)
    }))
    images = optional(list(object({
      name     = optional(string)
      new_name = optional(string)
      new_tag  = optional(string)
      digest   = optional(string)
    })))
    name_prefix = optional(string)
    namespace   = optional(string)
    name_suffix = optional(string)
    patches = optional(list(object({
      path  = optional(string)
      patch = optional(string)
      target = optional(object({
        group               = optional(string)
        version             = optional(string)
        kind                = optional(string)
        name                = optional(string)
        namespace           = optional(string)
        label_selector      = optional(string)
        annotation_selector = optional(string)
      }))
    })))
    replicas = optional(list(object({
      name  = optional(string)
      count = optional(number)
    })))
    secret_generator = optional(list(object({
      name      = optional(string)
      namespace = optional(string)
      behavior  = optional(string)
      type      = optional(string)
      envs      = optional(list(string))
      files     = optional(list(string))
      literals  = optional(list(string))
      options = optional(object({
        labels                   = optional(map(string))
        annotations              = optional(map(string))
        disable_name_suffix_hash = optional(bool)
      }))
    })))
    transformers = optional(list(string))
    vars = optional(list(object({
      name = optional(string)
      obj_ref = optional(object({
        api_version = optional(string)
        group       = optional(string)
        version     = optional(string)
        kind        = optional(string)
        name        = optional(string)
        namespace   = optional(string)
      }))
      field_ref = optional(object({
        field_path = optional(string)
      }))
    })))
  }))
  description = "Map with per workspace module configuration."
  default     = { apps = {}, ops = {}, loc = {} }
}

variable "configuration_base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
}

variable "sensitive_group_kinds" {
  type        = list(string)
  description = "List of GroupKinds to mark sensitive. Defaults to [\"_/Secret\"]"
  default     = ["_/Secret"]
}

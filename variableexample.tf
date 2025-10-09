variable "prefix"                { type = string }
variable "location"              { type = string }
variable "alert_email"           { type = string }
variable "enable_budget"         { type = bool   default = false }
variable "deploy_container_app"  { type = bool   default = true }
variable "container_image"       { type = string default = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" }
variable "container_cpu"         { type = number default = 0.25 }
variable "container_memory"      { type = string default = "0.5Gi" }
variable "allowed_vm_skus"       { type = list(string) default = ["Standard_B1s","Standard_B2s"] }
variable "allowed_locations"     { type = list(string) default = [] }
variable "ops_reader_object_id"  { type = string default = "" }

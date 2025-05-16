variable "region" {
  default = "ap-northeast-1"
}

variable "asana_personal_token_value" {
  description = "Asana Personal Access Token"
  type        = string
  sensitive   = true
}

variable "asana_project_id" {
  description = "Target Asana Project ID"
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge schedule expression (cron or rate)"
  type        = string
  default     = "cron(0 0 1 * ? *)" # 1st day of every month at midnight
}

variable "snapshot_age_days" {
  description = "Number of days after which snapshots are considered old"
  type        = number
  default     = 365
}

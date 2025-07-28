variable "start_schedule" {
  description = "Cron expression for starting RDS instances (JST)"
  type        = string
  default     = "cron(0 0 ? * MON-FRI *)"  # 9:00 JST weekdays
}

variable "stop_schedule" {
  description = "Cron expression for stopping RDS instances (JST)"
  type        = string
  default     = "cron(0 9 ? * MON-FRI *)"  # 18:00 JST weekdays
}

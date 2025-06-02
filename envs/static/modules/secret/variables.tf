variable "db_envs" {
  type = set(string)
}

variable "db_username" {
  type = string
  description = "DB 사용자 이름"
}

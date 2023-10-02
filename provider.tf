provider "aws" {
  region = "us-east-2"
  access_key = "AKIAQF5NQVPWYXK32V45"
  secret_key = "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"
}

#data "aws_secretsmanager_secret" "scr_pass" {
#  name = "pass_terra"
#}
#
#data "aws_secretsmanager_secret_version" "my_secret_version" {
#  secret_id = data.aws_secretsmanager_secret.scr_pass.id
#}


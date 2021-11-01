data "external" "aws_id" {
  program = ["../00-shared/bin/aws_id.sh"]

  query = {
    key = "Account"
  }
}

data "external" "aws_id" {
  program = ["../_shared/bin/aws_id.sh"]

  query = {
    key = "Account"
  }
}

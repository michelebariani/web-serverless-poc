#
# DynamoDB
#

resource "aws_dynamodb_table" "this" {
  name           = var.remote_state_dynamodb_table_name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

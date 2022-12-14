#
# DynamoDB
#

resource "aws_dynamodb_table" "this" {
  name           = "welcome-${var.env_name}"
  read_capacity  = 10
  write_capacity = 5
  hash_key       = "message"

  attribute {
    name = "message"
    type = "S"
  }
}


resource "aws_dynamodb_table_item" "this" {
  table_name = aws_dynamodb_table.this.name
  hash_key   = aws_dynamodb_table.this.hash_key

  item = <<ITEM
{
  "message": { "S": "welcome" },
  "value"  : { "S": "${var.welcome_string}" }
}
ITEM

  # Enable thew following if you want to set initial data only, with no updates afterwards
  # lifecycle {
  #   ignore_changes = [item]
  # }
}

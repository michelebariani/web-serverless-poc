
output "env_name" {
  value = var.env_name
}

output "url" {
  value = "${aws_api_gateway_stage.this.invoke_url}/${var.welcome_path}"
}

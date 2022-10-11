
output "api-gateway" {
  value = google_api_gateway_gateway.gw.default_hostname
}

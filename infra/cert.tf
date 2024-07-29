resource "tls_private_key" "key" {
  algorithm = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = "self-signed.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key = tls_private_key.key.private_key_pem
  certificate_body = tls_self_signed_cert.cert.cert_pem
}

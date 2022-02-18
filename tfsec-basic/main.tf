resource "aws_kms_key" "this" {
  description             = "Je suis une clef KMS"
  deletion_window_in_days = 10
  enable_key_rotation     = false
}

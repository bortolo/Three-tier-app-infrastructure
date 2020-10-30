#############
# IAM user 1
#############

output "user1_login_profile_key_fingerprint" {
  description = "The fingerprint of the PGP key used to encrypt the password"
  value       = module.iam_user1.this_iam_user_login_profile_key_fingerprint
}

output "user1_login_profile_encrypted_password" {
  description = "The encrypted password, base64 encoded"
  value       = module.iam_user1.this_iam_user_login_profile_encrypted_password
}

output "user1_access_key_id" {
  description = "The access key ID"
  value       = module.iam_user1.this_iam_access_key_id
}

output "user1_access_key_key_fingerprint" {
  description = "The fingerprint of the PGP key used to encrypt the secret"
  value       = module.iam_user1.this_iam_access_key_key_fingerprint
}

output "user1_access_key_encrypted_secret" {
  description = "The encrypted secret, base64 encoded"
  value       = module.iam_user1.this_iam_access_key_encrypted_secret
}

#############
# IAM user 2
#############

output "user2_login_profile_key_fingerprint" {
  description = "The fingerprint of the PGP key used to encrypt the password"
  value       = module.iam_user2.this_iam_user_login_profile_key_fingerprint
}

output "user2_login_profile_encrypted_password" {
  description = "The encrypted password, base64 encoded"
  value       = module.iam_user2.this_iam_user_login_profile_encrypted_password
}

output "user2_access_key_id" {
  description = "The access key ID"
  value       = module.iam_user2.this_iam_access_key_id
}

output "user2_access_key_key_fingerprint" {
  description = "The fingerprint of the PGP key used to encrypt the secret"
  value       = module.iam_user2.this_iam_access_key_key_fingerprint
}

output "user2_access_key_encrypted_secret" {
  description = "The encrypted secret, base64 encoded"
  value       = module.iam_user2.this_iam_access_key_encrypted_secret
}

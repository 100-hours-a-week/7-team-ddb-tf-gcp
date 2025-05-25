output "jenkins_public_key" {
  description = "jenkins public key"
  value       = data.tls_public_key.jenkins_ssh_pubkey.public_key_openssh
}
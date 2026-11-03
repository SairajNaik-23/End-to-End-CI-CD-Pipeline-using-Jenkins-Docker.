#!/usr/bin/env bash
# Installs Jenkins + Docker on an Ubuntu 22.04/24.04 EC2 instance.
# Run as: sudo bash install-jenkins.sh
# Security group: allow 8080 (Jenkins UI + GitHub webhook) and 22 (your IP only).
set -euo pipefail

echo ">> Installing Java 17 (required by Jenkins)"
apt-get update -y
apt-get install -y fontconfig openjdk-17-jre curl git

echo ">> Installing Jenkins (LTS)"
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  -o /usr/share/keyrings/jenkins-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list
apt-get update -y
apt-get install -y jenkins

echo ">> Installing Docker"
curl -fsSL https://get.docker.com | sh

# Let Jenkins run docker commands without sudo
usermod -aG docker jenkins
systemctl enable --now docker
systemctl restart jenkins

echo ">> Done. Open http://<this-server-ip>:8080"
echo ">> Initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword

#!/usr/bin/env bash
# Prepares the deploy target (a second Ubuntu EC2 instance): installs Docker.
# Run as: sudo bash setup-deploy-server.sh
# Security group: allow 80 (app) from anywhere, 22 from the Jenkins server only.
set -euo pipefail

curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu
systemctl enable --now docker

echo ">> Docker installed. Log out and back in so 'ubuntu' can use docker without sudo."

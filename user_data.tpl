#!/bin/bash

set -e

echo "[*] Updating system packages..."
sudo dnf update -y

echo "[*] Installing Java (Amazon Corretto 17)..."
sudo dnf install java-17-amazon-corretto -y

echo "[*] Verifying Java installation..."
java -version

echo "[*] Adding Jenkins repository..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

echo "[*] Importing Jenkins GPG key..."
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "[*] Installing Jenkins..."
sudo dnf install jenkins -y

echo "[*] Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "[*] Checking Jenkins status..."
sudo systemctl status jenkins --no-pager

echo ""
echo "[*] Jenkins installed and running."
echo "[*] To get the initial admin password, run:"
echo "    sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "[*] Access Jenkins at: http://<your-ec2-public-ip>:8080"
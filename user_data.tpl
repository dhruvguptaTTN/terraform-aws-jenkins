#!/bin/bash

# -----------------------------
# Update system and install dependencies
# -----------------------------
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y java-17-amazon-corretto wget

# -----------------------------
# Add Jenkins repository and import GPG key
# -----------------------------
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y

# -----------------------------
# Install Jenkins (specific version)
# -----------------------------
wget https://github.com/jenkinsci/jenkins/releases/download/jenkins-2.511/jenkins-2.511-1.1.noarch.rpm
sudo yum install -y jenkins-2.511-1.1.noarch.rpm

# -----------------------------
# Enable and start Jenkins
# -----------------------------
sudo systemctl enable jenkins
sudo systemctl start jenkins

# -----------------------------
# Install Nginx
# -----------------------------
sudo yum install -y nginx

# -----------------------------
# Generate SSL certificates (self-signed)
# -----------------------------
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/selfsigned.key \
  -out /etc/nginx/ssl/selfsigned.crt \
  -subj "/CN=$(hostname -f)"

# -----------------------------
# Configure Nginx as HTTPS reverse proxy to Jenkins
# -----------------------------
sudo bash -c 'cat <<EOF > /etc/nginx/conf.d/jenkins.conf
server {
    listen 443 ssl;
    server_name _;

    ssl_certificate     /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;

    location / {
        proxy_pass         http://127.0.0.1:8080;
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF'

# -----------------------------
# Enable and start Nginx
# -----------------------------
sudo systemctl enable nginx
sudo systemctl start nginx

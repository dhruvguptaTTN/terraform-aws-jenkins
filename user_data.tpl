#!/bin/bash

# Switch to root
sudo -i

# Install Amazon Corretto 21 (latest LTS Java)
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-21-amazon-corretto

# Set Jenkins version
jenkins_version="${jenkins_version}"
echo "Variable value: ${jenkins_version}" > /opt/version.txt
sudo wget https://updates.jenkins.io/download/war/${jenkins_version}/jenkins.war -O /opt/jenkins.war

# Create Jenkins user
sudo useradd jenkins --home /var/lib/jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo

# Set permissions
sudo chown jenkins:jenkins /var/lib/jenkins

# Create Jenkins systemd service
cat << EOF | sudo tee /etc/systemd/system/jenkins.service
[Unit]
Description=Jenkins Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/java -jar /opt/jenkins.war --httpPort=8080
User=jenkins
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start and enable Jenkins
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
sudo amazon-linux-extras install docker -y
sudo usermod -a -G docker ec2-user
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
docker --version

# Install kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl
kubectl version --client --output=yaml

# System update and install NGINX
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx
sudo systemctl enable nginx

# NGINX port redirection from 80 to 8080
sudo tee /etc/nginx/conf.d/port_redirection.conf > /dev/null <<EOT
server {
    listen 80;
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOT

sudo nginx -t
sudo systemctl reload nginx

# Install Git
sudo yum install git -y
git --version

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Helm v3
export PATH=$PATH:/usr/local/bin
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
helm version --short | cut -d + -f 1
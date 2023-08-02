#!/bin/bash

sudo -i
sudo yum install java-11-amazon-corretto -y
echo "Variable value: ${jenkins_version}" > /opt/version.txt
sudo wget https://updates.jenkins.io/download/war/${jenkins_version}/jenkins.war -O /opt/jenkins.war

sudo useradd jenkins --home /var/lib/jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo

sudo chown jenkins:jenkins /var/lib/jenkins

cat << EOF | sudo tee /etc/systemd/system/jenkins.service
[Unit]
Description=Jenkins Server
After=network.target

[Service]
Type=simple
ExecStart=/bin/java -jar /opt/jenkins.war --httpPort=8080
User=jenkins
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins


sudo amazon-linux-extras install docker -y
sudo usermod -a -G docker ec2-user
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
docker --version

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

sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
nginx -t
nginx -version

sudo yum install git -y
git --version

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

export PATH=$PATH:/usr/local/bin
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
helm version --short | cut -d + -f 1



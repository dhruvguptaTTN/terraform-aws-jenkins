module "ec2-jenkins" {
  source               = "git::https://github.com/tothenew/terraform-aws-jenkins.git"
  vpc_id               = "vpc-99999999"
  subnet_ids           = ["subnet-99999999"]
  assign_public_ip     = true
  jenkins_version      = "WarFileVersion" #For ex- 2.387
  custom_cidr          = "192.0.0.0/24"  #Leave empty for [0.0.0.0]
}
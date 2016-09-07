# aye-aye-deploy
This repository contains the files necessary to set up an Amazon EC2 Container Service infrastructure using Terraform, for use with Shippable Formations and the Aye Aye demo.  

**The Aye Aye demo consists of two services that run in containers:**
* A front-end web service
* A back-end api service

**This sample infrastructure establishes a public subnet with the following components:**
* 1 VPC and associated components (subnet, internet gateway, etc.)
* ELB for web service accepting traffic on port 80
* ELB for api service accepting traffic on port 80
* 2 container instances (t2.micro)
* IAM policy, role and instance profile
* Security groups for accessing instances and load balancers

**Instructions for setting up the Amazon ECS environment**
* Create a cluster in Amazon EC2 Container Service (this is really just naming your cluster)
* [Install the Terraform CLI](https://terraform.io/intro/getting-started/install.html) on your machine
* Fork this repo and clone to your local machine
* cd to the /deploy/default directory on your machine
* Gather the following information from your AWS account:
  * An Amazon Access Key ID and Secret Access Key with rights to install infrastructure
  * Amazon ECS cluster name that you'll register this infrastructure with (created above)
  * An Amazon Key Pair name (usable in the us-east-1 region if you will use Amazon ECR)
* The scripts will default to creating the infrastructure in the us-east-1 region
  * If you'd like to change the region, either specify the value as an additional option
  on the command line (e.g. '-var region=eu-west-1') or change the default value in the
  default/variables.tf file
  * Note: you will have to have a key pair created in the region you specify for use in the command lines below.
* Execute the following command to see what will be set up on AWS:
```
$ terraform plan -var aws_access_key_id=yourKeyId -var aws_secret_access_key=yourSecretKey -var aws_key_name=yourKeyPairName -var cluster_name=yourClusterName
```
* Execute the following command to install the infrastructure:
```
$ terraform apply -var aws_access_key_id=yourKeyId -var aws_secret_access_key=yourSecretKey -var aws_key_name=yourKeyPairName -var cluster_name=yourClusterName
```
* When you're ready to remove this infrastructure, run the following:
```
$ terraform destroy -var aws_access_key_id=yourKeyId -var aws_secret_access_key=yourSecretKey -var aws_key_name=yourKeyPairName -var cluster_name=yourClusterName
```

**Warning: These actions will provision infrastructure on AWS and may incur costs.**

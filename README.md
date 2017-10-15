# packernetes

This tool preloads a master AMI and a worker AMI with kubernetes software to be used with terraform to deploy kubernetes on AWS.

Terraform creates EC2 instances based on these images, calls kubeadm init and creates an autoscaling group.
The launch configuration of the ASG provides the appropriate join token in user-data.
When an EC2 instance of the ASG comes up it calls the join script via /etc/rc.local.

To use this project, please set up your access key and secret key in ~/.aws/credentials.
Also you need to pip install xkcdpass and download packer from hashicorp to run this code.

You can export the following environment variables to create packer images in a different EC2 account:
```
export PACKERNETES_AWS_SECRET_ACCESS_KEY=ZZZZ
export PACKERNETES_AWS_ACCESS_KEY_ID=AKIAXXXX
```
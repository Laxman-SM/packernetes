# packernetes
packer · kubeadm · kubernetes

This tool will only work if you have set up your AWS credentials using `aws configure`, packer will need these credentials for spawning build instances.

Also you need to pip install xkcdpass and download packer from hashicorp to run this code.

You may export environment variables or directly edit the top level Makefile to change the AMI and the region you use for building.

At the moment a lot of things are hardcoded in the configs.


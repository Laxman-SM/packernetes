
#
# pick any Ubuntu 16.04 AMI as the base image
#
PACKER_SOURCE_AMI = ami-3f1bd150

#
# this only affects which region is used by packer to build the ami
#
PACKER_REGION = eu-central-1

#
# should be good enough for most of the building we do here
#
PACKER_INSTANCE_TYPE = t2.medium

all: preflight packer

include include/defines.mk

.PHONY: packer
packer:
	@$(DESCEND)

# .PHONY: terraform
# terraform:
# @$(DESCEND)


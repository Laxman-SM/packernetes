
#
# pick any Ubuntu 16.04 AMI as the base image
#
PACKER_SOURCE_AMI = ami-3f1bd150

#
# this defines the region to be used by packer to build the AMI
#
PACKER_REGION = eu-central-1

#
# this is the size of the ec2 instance we use for building the AMI
#
PACKER_INSTANCE_TYPE = t2.medium

#
# you can override this variable to influence the seeding of the codenames
#
ifeq "$(CODE_NAME_SEED)" ""
CODE_NAME_SEED = "aa"
endif

all: preflight packer/master packer/worker

include include/defines.mk

.PHONY: packer/master
packer/master:
	@$(DESCEND)

.PHONY: packer/worker
packer/worker:
	@$(DESCEND)


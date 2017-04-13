
#
# pick any Ubuntu 16.04 AMI as the base image
#
ifeq "$(PACKER_SOURCE_AMI)" ""
PACKER_SOURCE_AMI = ami-3f1bd150
endif

#
# this defines the region to be used by packer to build the AMI
#
ifeq "$(PACKER_REGION)" ""
PACKER_REGION = eu-central-1
endif

#
# this is the size of the ec2 instance we use for building the AMI
#
ifeq "$(PACKER_INSTANCE_TYPE)" ""
PACKER_INSTANCE_TYPE = t2.medium
endif

#
# you can override this to influence the seeding of the codenames
# eventually this will become your release management policy
# note that we only fetch the first two words of the codename generator
#
ifeq "$(CODE_NAME_SEED)" ""
CODE_NAME_SEED = "aa"
endif

#
# this is the main logic to create the master and worker AMIs
#
all: preflight packer/master packer/worker

include include/defines.mk

.PHONY: packer/master
packer/master:
	@$(DESCEND)

.PHONY: packer/worker
packer/worker:
	@$(DESCEND)


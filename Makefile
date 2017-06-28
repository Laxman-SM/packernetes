
#
# add the github users of people here who should be injected during packer image building
#
ifeq "$(GITHUB_KEYS)" ""
GITHUB_KEYS = agabert ixl123 hoesler
endif

#
# populate the packernetes AWS credentials from normal AWS credentials if env vars are not set
#
ifeq "$(PACKERNETES_AWS_ACCESS_KEY_ID)" ""
ifneq "$(AWS_ACCESS_KEY_ID)" ""
PACKERNETES_AWS_ACCESS_KEY_ID = "$(AWS_ACCESS_KEY_ID)"
endif
endif

ifeq "$(PACKERNETES_AWS_SECRET_ACCESS_KEY)" ""
ifneq "$(AWS_SECRET_ACCESS_KEY)" ""
PACKERNETES_AWS_SECRET_ACCESS_KEY = "$(AWS_SECRET_ACCESS_KEY)"
endif
endif

#
# pick any Ubuntu 16.04 AMI as the base image
#
ifeq "$(PACKER_SOURCE_AMI)" ""
ifneq "$(PACKERNETES_AWS_ACCESS_KEY_ID)" ""
ifneq "$(PACKERNETES_AWS_SECRET_ACCESS_KEY)" ""
PACKER_SOURCE_AMI = $(shell ./bin/findimage.sh)
endif
endif
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
CODE_NAME_SEED = "ac"
endif

#
# this is the main logic to create the master and worker AMIs
#
all: preflight packer/master packer/worker

include include/defines.mk

.PHONY: packer/master
packer/master:
	@$(BUILD_IMAGE)

.PHONY: packer/worker
packer/worker:
	@$(BUILD_IMAGE)

show:
	@bin/show.sh


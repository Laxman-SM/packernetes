
BUILD_DATE := $(BUILD_DATE)
XCODE_NAME := $(XCODE_NAME)

#
# derives the image type from the directory where the packer run is executed from
#
IMAGE_TYPE = $(shell basename $(shell pwd))

PACKER_VAR1 = -var "source_ami=$(PACKER_SOURCE_AMI)"
PACKER_VAR2 = -var "region=$(PACKER_REGION)"
PACKER_VAR3 = -var "instance_type=$(PACKER_INSTANCE_TYPE)"
PACKER_VAR4 = -var "ami_name=packernetes ($(BUILD_DATE)) $(IMAGE_TYPE) image [$(XCODE_NAME)]"
PACKER_VAR5 = -var "basic_packages=$(BASIC_PACKAGES)"
PACKER_VAR6 = -var "build_git_commit_id=$(shell git log --pretty=format:'%H' -n 1)"

PACKER_VARS = $(PACKER_VAR1) $(PACKER_VAR2) $(PACKER_VAR3) $(PACKER_VAR4) $(PACKER_VAR5) $(PACKER_VAR6)

PACKER_JSON = tmp/packer.json

PACKER = packer $(@) $(PACKER_VARS) $(PACKER_JSON)


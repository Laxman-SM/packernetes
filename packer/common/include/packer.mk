
IMAGE_TYPE = $(shell basename $(shell pwd))

BUILD_STANZA = ($(BUILD_DATE)) $(IMAGE_TYPE) image [$(XCODE_NAME)]

GIT_COMMIT_ID = "$(shell git log --pretty=format:'%H' -n 1)"

PACKER_VARS := $(PACKER_VARS) -var "source_ami=$(PACKER_SOURCE_AMI)"
PACKER_VARS := $(PACKER_VARS) -var "region=$(PACKER_REGION)"
PACKER_VARS := $(PACKER_VARS) -var "instance_type=$(PACKER_INSTANCE_TYPE)"
PACKER_VARS := $(PACKER_VARS) -var "ami_name=packernetes $(BUILD_STANZA)"
PACKER_VARS := $(PACKER_VARS) -var "basic_packages=$(BASIC_PACKAGES)"
PACKER_VARS := $(PACKER_VARS) -var "build_git_commit_id=$(GIT_COMMIT_ID)"
PACKER_VARS := $(PACKER_VARS) -var "image_type=$(IMAGE_TYPE)"

PACKER_JSON = ../common/conf/kubeadm.json

PACKER = packer $(@) $(PACKER_VARS) $(PACKER_JSON)


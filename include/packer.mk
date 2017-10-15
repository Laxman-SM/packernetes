
IMAGE_TYPE = $(shell basename $(shell pwd))

BUILD_STANZA = ($(BUILD_DATE)) $(IMAGE_TYPE) image [$(XCODE_NAME)]

GIT_COMMIT_ID = "$(shell git log --pretty=format:'%H' -n 1)"

EINHOR1 = agabert/einhorn:latest
EINHOR2 = docker pull $(EINHOR1) 1>/dev/null;
EINHOR3 = docker run -it --rm --detach=false
EINHOR4 = -e AWS_SECRET_ACCESS_KEY=$(PACKERNETES_AWS_SECRET_ACCESS_KEY)
EINHOR5 = -e AWS_ACCESS_KEY_ID=$(PACKERNETES_AWS_ACCESS_KEY_ID)
EINHORN = $(EINHOR2) $(EINHOR3) $(EINHOR4) $(EINHOR5)

ifeq "base" "$(IMAGE_TYPE)"
PACKER_VARS := $(PACKER_VARS) -var "source_ami=$(shell $(EINHORN))"
else
PACKER_VARS := $(PACKER_VARS) -var "source_ami=$(shell ../../bin/baseimage.sh)"
endif

PACKER_VARS := $(PACKER_VARS) -var "region=$(PACKER_REGION)"
PACKER_VARS := $(PACKER_VARS) -var "instance_type=$(PACKER_INSTANCE_TYPE)"
PACKER_VARS := $(PACKER_VARS) -var "ami_name=packernetes $(BUILD_STANZA)"
PACKER_VARS := $(PACKER_VARS) -var "basic_packages=$(BASIC_PACKAGES)"
PACKER_VARS := $(PACKER_VARS) -var "build_git_commit_id=$(GIT_COMMIT_ID)"
PACKER_VARS := $(PACKER_VARS) -var "image_type=$(IMAGE_TYPE)"
PACKER_VARS := $(PACKER_VARS) -var "github_keys=$(GITHUB_KEYS)"

PACKER_JSON = ../../conf/packer.json

PACKER = packer $(@) $(PACKER_VARS) $(PACKER_JSON)


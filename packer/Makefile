
BUILD_DATE := $(shell date +%s)

CODE_NAME := $(shell xkcdpass --count=1 --acrostic='kubernetes' | awk '{print $$1 " " $$2;}')

PACKER_VAR1 = -var "source_ami=$(PACKER_SOURCE_AMI)"
PACKER_VAR2 = -var "region=$(PACKER_REGION)"
PACKER_VAR3 = -var "instance_type=$(PACKER_INSTANCE_TYPE)"
PACKER_VAR4 = -var "ami_name_suffix=$(CODE_NAME) ($(BUILD_DATE))"
PACKER_VAR5 = -var "basic_packages=$(BASIC_PACKAGES)"

PACKER_VARS = $(PACKER_VAR1) $(PACKER_VAR2) $(PACKER_VAR3) $(PACKER_VAR4) $(PACKER_VAR5)

PACKER_CONFIG = conf/kubeadm.json

PACKER = packer $(@) $(PACKER_VARS) $(PACKER_CONFIG)

all: validate build

validate:
	@$(PACKER)

build:
	@$(PACKER)


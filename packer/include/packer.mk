
BUILD_DATE := $(BUILD_DATE)
XCODE_NAME := $(XCODE_NAME)

#
# derives the image type from the directory where the packer run is executed from
#
IMAGE_TYPE = $(shell basename $(shell pwd))

PACKER_VAR1 = -var "source_ami=$(PACKER_SOURCE_AMI)"
PACKER_VAR2 = -var "region=$(PACKER_REGION)"
PACKER_VAR3 = -var "instance_type=$(PACKER_INSTANCE_TYPE)"
PACKER_VAR4 = -var "ami_name_prefix=($(BUILD_DATE)) $(IMAGE_TYPE)"
PACKER_VAR5 = -var "basic_packages=$(BASIC_PACKAGES)"
PACKER_VAR6 = -var "ami_name_suffix=[$(XCODE_NAME)]"

PACKER_VARS = $(PACKER_VAR1) $(PACKER_VAR2) $(PACKER_VAR3) $(PACKER_VAR4) $(PACKER_VAR5) $(PACKER_VAR6)

PACKER = packer $(@) $(PACKER_VARS) tmp/packer.json

PACKER_KUBEADM_CONF_HEAD = ../conf/kubeadm.json.HEAD
PACKER_KUBEADM_CONF_TAIL = ../conf/kubeadm.json.TAIL

BUILD_CONFIG = mkdir -pv tmp; cat $(PACKER_KUBEADM_CONF_HEAD) conf/$(IMAGE_TYPE).json $(PACKER_KUBEADM_CONF_TAIL) | python -mjson.tool | tee tmp/packer.json

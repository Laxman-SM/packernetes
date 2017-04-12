
PACKER_VAR1 = -var "source_ami=$(PACKER_SOURCE_AMI)"
PACKER_VAR2 = -var "region=$(PACKER_REGION)"
PACKER_VAR3 = -var "instance_type=$(PACKER_INSTANCE_TYPE)"
PACKER_VAR4 = -var "ami_name_suffix=$(shell date +%s)"

PACKER_VARS = $(PACKER_VAR1) \
							$(PACKER_VAR2) \
							$(PACKER_VAR3) \
							$(PACKER_VAR4)

PACKER_CONFIG = conf/kubeadm.json

PACKER = packer build $(PACKER_VARS) $(PACKER_CONFIG)

all: packer

packer:
	@$(PACKER)

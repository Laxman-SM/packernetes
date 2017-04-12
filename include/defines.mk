
#
# these environment variables need to be handed down
# from the top-level Makefile
#
DESCEND = PACKER_SOURCE_AMI=$(PACKER_SOURCE_AMI) \
					PACKER_REGION=$(PACKER_REGION) \
					PACKER_INSTANCE_TYPE=$(PACKER_INSTANCE_TYPE) \
					make -C $(@)

preflight:
	@which packer 1>/dev/null


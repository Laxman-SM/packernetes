
BUILD_DATE := $(shell date +%s)
XCODE_NAME := $(shell xkcdpass --count=1 --acrostic=$(CODE_NAME_SEED) | awk '{print $$1 " " $$2;}')

#
# these environment variables need to be handed down
# from the top-level Makefile
#
DESCEND = PACKER_SOURCE_AMI="$(PACKER_SOURCE_AMI)" \
					PACKER_REGION="$(PACKER_REGION)" \
					PACKER_INSTANCE_TYPE="$(PACKER_INSTANCE_TYPE)" \
					BASIC_PACKAGES="$(BASIC_PACKAGES)" \
					BUILD_DATE="$(BUILD_DATE)" \
					XCODE_NAME="$(XCODE_NAME)" \
					make -C "$(@)"

BASIC_PACKAGES = htop atop screen make lsof strace ltrace tcpdump tmux golang

#
# here we make sure you installed the necessary tools on your machine
#
preflight:
	@which packer 1>/dev/null
	@which xkcdpass 1>/dev/null
	@which python 1>/dev/null


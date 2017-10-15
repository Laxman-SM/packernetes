
BUILD_DATE := $(shell date +%s)

XKCDPASS = docker run -it --rm --detach=false agabert/rampensau:latest --count=1

XCODE_NAME := $(shell $(XKCDPASS)--acrostic=$(CODE_NAME_SEED))

BASIC_PACKAGES = htop screen make lsof strace ltrace tcpdump tmux golang

#
# these environment variables need to be handed down
# from the top-level Makefile
#
BUILD = PACKER_REGION="$(PACKER_REGION)" \
		PACKER_INSTANCE_TYPE="$(PACKER_INSTANCE_TYPE)" \
		BASIC_PACKAGES="$(BASIC_PACKAGES)" \
		BUILD_DATE="$(BUILD_DATE)" \
		XCODE_NAME="$(XCODE_NAME)" \
		GITHUB_KEYS="$(GITHUB_KEYS)" \
		AWS_ACCESS_KEY_ID="$(PACKERNETES_AWS_ACCESS_KEY_ID)" \
		AWS_SECRET_ACCESS_KEY="$(PACKERNETES_AWS_SECRET_ACCESS_KEY)" \
		make -C "$(@)"

#
# check if this box is ready for running the project
#
preflight: scriptpermissions
	which packer
	env | grep PACKERNETES_AWS_ACCESS_KEY_ID
	env | grep PACKERNETES_AWS_SECRET_ACCESS_KEY

scriptpermissions:
	find packer -type f -ipath '*.sh' | xargs -n1 chmod -v 0755

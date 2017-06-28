
BUILD_DATE := $(shell date +%s)

XCODE_NAME := $(shell xkcdpass \
												--count=1 \
												--acrostic=$(CODE_NAME_SEED) | \
													awk '{print $$1 " " $$2;}' | \
														tr -d "'")

BASIC_PACKAGES = htop atop screen make lsof strace ltrace tcpdump tmux golang

#
# these environment variables need to be handed down
# from the top-level Makefile
#
BUILD_IMAGE = PACKER_SOURCE_AMI="$(PACKER_SOURCE_AMI)" \
							PACKER_REGION="$(PACKER_REGION)" \
							PACKER_INSTANCE_TYPE="$(PACKER_INSTANCE_TYPE)" \
							BASIC_PACKAGES="$(BASIC_PACKAGES)" \
							BUILD_DATE="$(BUILD_DATE)" \
							XCODE_NAME="$(XCODE_NAME)" \
							GITHUB_KEYS="$(GITHUB_KEYS)" \
							AWS_ACCESS_KEY_ID="$(PACKERNETES_AWS_ACCESS_KEY_ID)" \
							AWS_SECRET_ACCESS_KEY="$(PACKERNETES_AWS_SECRET_ACCESS_KEY)" \
							make -C "$(@)"

#
# here we make sure you installed the necessary tools on your machine
# also you must export environment variables pointing to your AWS account where packer should run
# most likely this is not your terraform AWS account so we are using different variables here.
#
preflight:
	@which packer 1>/dev/null || \
		(echo 'PACKER IS MISSING' && exit 1)
	@which xkcdpass 1>/dev/null || \
		(echo 'XKCDPASS IS MISSING' && exit 1)
	@env | grep PACKERNETES_AWS_ACCESS_KEY_ID 1>/dev/null || \
		(echo 'environment variable PACKERNETES_AWS_ACCESS_KEY_ID is missing' && exit 1)
	@env | grep PACKERNETES_AWS_SECRET_ACCESS_KEY 1>/dev/null || \
		(echo 'environment variable PACKERNETES_AWS_SECRET_ACCESS_KEY is missing' && exit 1)


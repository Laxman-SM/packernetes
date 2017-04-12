
#
# these environment variables need to be handed down
# from the top-level Makefile
#
DESCEND = PACKER_SOURCE_AMI="$(PACKER_SOURCE_AMI)" \
					PACKER_REGION="$(PACKER_REGION)" \
					PACKER_INSTANCE_TYPE="$(PACKER_INSTANCE_TYPE)" \
					BASIC_PACKAGES="$(BASIC_PACKAGES)" \
					make -C "$(@)"

BASIC_PACKAGES = htop atop screen make lsof strace ltrace tcpdump tmux golang

# make sure you pip install xkcdpass
preflight:
	@which packer 1>/dev/null
	@which xkcdpass 1>/dev/null


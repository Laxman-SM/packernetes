TODOs
==

* find out how to make an AMI public after the packer run (or inside the json definition)
Or use ami_users (array of strings) - A list of account IDs that have access to launch the resulting AMI(s). By default no additional users other than the user creating the AMI has permissions to launch it.


* at the moment we are doing dist-upgrade in two different base images
This may or may not fail.
An alternative would be to create a staging image (a common image) and derive the other two images from this staging image, then having three images lying around, with guaranteed identical packages.

* write cleaner script for packer images that are >30 days old and not used by any running installation


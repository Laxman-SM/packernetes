TODOs
==

* find out how to make an AMI public after the packer run (or inside the json definition)

* at the moment we are doing dist-upgrade in two different base images
This may or may not fail.
An alternative would be to create a staging image (a common image) and derive the other two images from this staging image, then having three images lying around, with guaranteed identical packages.

* write cleaner script for packer images that are >30 days old and not used by any running installation


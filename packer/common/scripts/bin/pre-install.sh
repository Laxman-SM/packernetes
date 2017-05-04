#!/usr/bin/env bash
#./pre-install.sh

#
# bail out on the slightest error (will abort packer build)
#
set -e

if [[ "" == "$BASIC_PACKAGES" ]]; then
  echo "ERROR: environment variable BASIC_PACKAGES is not set"
  exit 1
fi

if [[ "" == "$AMI_NAME" ]]; then
  echo "ERROR: environment variable AMI_NAME is not set"
  exit 1
fi

if [[ "" == "$IMAGE_TYPE" ]]; then
  echo "ERROR: environment variable IMAGE_TYPE is not set"
  exit 1
fi

#
# this helps with installations
#
export DEBIAN_FRONTEND=noninteractive

#
# install basic packages available in every image
#
sudo apt-get -y -u install \
  unzip \
  screen \
  glances \
  htop \
  atop \
  tcpdump \
  vim \
  ntpdate \
  traceroute \
  $BASIC_PACKAGES

#
# inject the screenrc with the AMI image identifier string
#
sudo tee /root/.screenrc<<EOF
hardstatus alwayslastline

hardstatus string '%{= kG} $AMI_NAME [%= %{= kw}%?%-Lw%?%{r}[%{W}%n*%f %t%?{%u}%?%{r}]%{w}%?%+Lw%?%?%= %{g}] %{W}%{g}%{.w} $IMAGE_TYPE %{.c} [%H]'
EOF

sudo sed -i 's,master image,MASTER image,g;' /root/.screenrc
sudo sed -i 's,worker image,WORKER image,g;' /root/.screenrc

#
# copy the screenrc to the ubuntu user
#
sudo cp /root/.screenrc /home/ubuntu/.screenrc
sudo chown ubuntu: /home/ubuntu/.screenrc

#
# install google packages key for kubernetes repository
#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo apt-key add -

#
# set up kubernetes repository
#
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

#
# lets see if there are any upgraded packages in there (note that bootstrap already ran dist-upgrade)
#
sudo apt-get update
sudo apt-get dist-upgrade -y -u

#
# install kubernetes and kubeadm dependencies
#
sudo apt-get install -y -u apt-transport-https \
  kubelet \
  kubectl \
  kubernetes-cni \
  kubeadm \
  docker-engine

tee -a /home/ubuntu/.ssh/authorized_keys<<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQC5upfvBd5jt7sn7tdQfCbY0Qt/ylZ27J/aVHRRSMINkex9z4066GgJEWM3CbuDn/RQxgJCfpQ/gkTh48eOPWrM5uLbwFSQnoeAU5h47acX4nLnQPmj4b+lZNWkplM2wmYMgnKVdejr5Xi62qYNV0fOiMAzXC2hu2HHLTk0AEyNpHHvUT2lA9Eze2M2A3L4AYAXZos43ZI4IYsK4u5FBitrALOOjEbC7Zl4zRXERKTCA3HgAk5bUrb8hUFXR10wnhHBFXDIaXJjoQdGyENHMuDJTklJZP78006Qj+E7e/Eo73uBLNh951WmmqIi7zbf5XikG+y7zvp+Gx+lmU/o7JQZTs1QH6M3sQxA/WfTVdm3oaUX54JevSrcK2Ndc0AXcjrvNxn5G9ppcSADpVArL8SymVUiQplC0sAt8UmjI5BlDI3LrvusszMXLSlKs5czk3ycB7FZd9Ckl/asdFTpWaKODwXD18DBh2bIPg+z3Nz3JxcYLX5xRLKjyoUutoytRLtO0nDV2nEg9IzZdpNjDJkrpIJBTLfEMmGj5cl0egilW6tDliQJJll3fobYKOx2rgOgwZd/lEpxtCCX4u5B5uEYJel8GF/6n9iOe8UNSoZblrvsJGuXvsLVB+8Q+76Vz56RD3eoj+8HCD9XeNhjvd/rcAZCsy1e100vPLWVEAqT4kbLZw6SjzVZ0jHqW0MPHxNMa5FxmmmyHFBGwq4quOpXiHg/lHBHsE9vcmFTsXeE+UfBGXIgUmbWnPiiUweKn7m3i+UH1vkP+NPwJPvRhvGtuStYQJnQ2GDT74Kbx/OOVf0Ct32LcqkZtgD/491ycPMPLPJfqPlQY9Vo93irZXSydmHzbJDQC/wZMPsZdZFoxkIlg6ZcwkGSFeFscJXIOLFvDV1PoiUGl7Gr7MYbkX26KKdwEuDYfuDd5C7p9/qmvbhcLemPGpcJ2fWzgFLV+nCkQE/uQrWXu5yvT+FEPanAMqQ8oV1Yb2zbyXjBbGx6NoQTF6b22/0wMg/dTfhbnsfmf1kR6NjyaAO1vx/3kSeQ4Qx5LbdWRpJxjtDLFxJDtiH3q8JFb39KzCjqltUou7qkNpvj9efiZjobppgVmjd1kHPYnaK7bqqrmDiyBMxi5hGKTNaol5aw6gvxHZFRU6lUhYq6LlCnWoQHgqcczGQNH04zq/JY//iqs9i+CcLNAW1fBV1FUqSLsn/Wec2qyg33C075V/CMRjOofmF3OtGJUVPLhr8zb/8PJ82hR757iK3c22S7UVURMLYC5xnpNW69/WEp3TbU/xrp865SgLOzjdijyLCo7ZWYWg//Ayp9Z8iUrsut0h4vNwJ7qAkgVqmMMjoUxXTaACF6q1Bqgnb5 agabert@T420

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYpcksZbrTlLlqrfGmjbrhgGmhh/GsqoS6JqvAE9+0PzYkSqeNt7d1HYcaqwGVC2C8KvkYM3dXGqpXhd+mVYUswovPSsu6ASp0G4UUeyB8Tt1mfc+jsdOBkfv2xEtCwF/pBbhsIVjtKS8IEWQEYEsne0gv05hhJVJERfuYXoZvyk72YebIl56kPMx5KLmKcx7ENZUHoc0uvxNZad55jXPAuVVVAIGVARnMbuINgdyiyl/DRTqAE5htlgeNEew/vSC3kNBOH9til5nVLA0IXJSC+dFvA4qy/y9UnMnNh9ToDlSUkSN/XX7+3OKoCyvJ2ayom9fhvThpMGZDv5YR+zlb bahrl@IT073-N01

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUJvYXH8b71E8uTtfrbdyg0bVIb10Z04KwUd/Na+SB4K/7OYsn2QmtbHANH807ZELlzgwhfAlFYPKKMYmL7DX0Q0XddVqRa64OJyNROU3aaCy7lFVCMr+KVzWJGoKKlZmzcSXaLQQ/ftFUsxVSR5vfdFzRa93mSX9kvaaLa5ke+fugAuJV8lP5ZAdV64z4+Cvfo4SBGJkPoZ9Y4X6KSWYYe9d7PAa2vB3aqy0/DSRbruJMzDu5BMN+dA7XFZh+Lm2RI5e6AbUEf2/2Yek9DrXYC5RVDrxnb+Ppa719G+6W+CzQ9gxCJw7Sm4CGxYv9Jx78UsnYRCN/ZrY2l6APX18j agabert@Alexanders-MacBook-Pro.local

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQCxs4P2Zrh78+P5hn+aT4TsTRmT6OO/m+clP+kxEbnLZTqEWRrfyJ2fYqxAjO52fWydxgSu7MhdJdRyMFnCpUVt2ZVLGNZFpL7jqjF7Rwos1ppLgWRILnb1G1j/0zUbKKBD3q9RY1nLaje+Tp9DUSq3DRU/TwaJiv5suREp9mb3cRVfIKIc14PtxAIcgXILHDJcT6CtBotXUMJ7Ev+v/m2vr4ywIg8o8KtwNbf6XUwbgX2w5mBltSbrsPERkwton+pptnGViuUUoJCqaBcKpY8KLZKiE6RmJBTtzUzzaniAmgzR2cAtJN03Kyhl7PuABnaIrNmdaJEJoyN8475HHL/B2IWlvyyPSxC40UuE7DkWldt0jGbi+aBtidgreY98pThsP/xEOCtDZlzDnc46XCTay3W/9PKq3BN2e/z6X0eqsBpJCyloc6kP7F+cT6bM/0pM+wOeOBO+Ndtq+44MAgqd5/a2QwNUrtqWWFyqyn9UpEi8kMYUfb3SyUU7p0SYqU0cdT3AhOtucD610xA8ZXMbVwJXR40kQQ48in1wdW6p3hPNw4G8QEeqwAN3WtuJ+854X7+X7WnsNcEqcZPLvep335savoyLdrndxu/DbTeExeBfrsD+HsZSwVZ27NnEXA/6bgu5BE2kPRok8RuedU3tARm5eJkIRohQGD2/Tu5TvzuKo/+CdY6y3KXcMQ9n/gVY3rKnOmTEUDdV+nOipcjgFwOEQxXJrLQq35yXuhXfDXXlxO2qqYYNMGjWTZXVkTGad9nNXebb+6dPgS71l9BFZB/puP/qTgRN93sbeQEWzpqmh4lnQYbqFLwqjZugGoLAVzqfjorBeJbAj5IX40PXnRVotNEux+nV5WrUZRyt87Eg72tzkEujojP7eDh2UkcPdY2ongW821Sx/QPa320HB+NJVCSjKjrqQe+ZyrgHVW2PaNaE50XtznFpQbeZ7k4b/Zs0ys4ItpqLw61S+NLGAcZp5lq2GEELpinSyQR6xs4zdJ3WytG3KKIaep2aC9kad4CYOvithYQH+FYcTqB7fPehs4vw5DemItN/U935nA2TkpUFs3a0NUaiLPBC7pAc/FApog+IZ2dCAkJ4ZlpQUhiDSUpvCaQHEL7Z23HqkmwlmXa66yrGE92rvSYud/XGtaXSHaaLgbESpvEFB+Ey/VO5NpKuaHMDUsSBC07uInCPChpgXIvzTXQb0b8WmSmVrO3EYy3OmE2my2RV2/RvWk6IqfyNptrwINtFkorYAl54pIFnJiKSkOb2po4LWg60zVSQKL72o+wBH/9GaOc059EJS+vLQrjusLEkprBIsOvZYyTs6RGDPeCPBrFXtloOkYpuNGkH9a0kGr2uCa6D pietsch@pietsch-VirtualBox

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdo1dvAVIh2+EbngDol/6BkhA9Ra4z+yri8emzqVUXhGLh5nUndOO0Pu1jTy9YB2g8huf0Q7F3VuzgyvuHKVDlEv50KSH1/5q4IetXGj46RaLuSSPeVexgosIS3VFbIGhw/gbllDz9QVrNF1AhJ1DWhcgoocTPshppVwpBEhKKIa43/jXsxczgg4T2tcuF9CortITAnz5ikl9du69ipGkgYHwzMC6Q2kbJxYje+wfEGhOF/poKQAM5FLeYIxJvpz+/lXnr49FnPQSiEMn4MFGjLX07D5bVYSLU7rSnMKyavbHim4Izj9XkhhQF3i9wpm2kF59qOPrT5tptfcbzwgbJ mbergmann

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYpcksZbrTlLlqrfGmjbrhgGmhh/GsqoS6JqvAE9+0PzYkSqeNt7d1HYcaqwGVC2C8KvkYM3dXGqpXhd+mVYUswovPSsu6ASp0G4UUeyB8Tt1mfc+jsdOBkfv2xEtCwF/pBbhsIVjtKS8IEWQEYEsne0gv05hhJVJERfuYXoZvyk72YebIl56kPMx5KLmKcx7ENZUHoc0uvxNZad55jXPAuVVVAIGVARnMbuINgdyiyl/DRTqAE5htlgeNEew/vSC3kNBOH9til5nVLA0IXJSC+dFvA4qy/y9UnMnNh9ToDlSUkSN/XX7+3OKoCyvJ2ayom9fhvThpMGZDv5YR+zlb bahrl@IT073-N01

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7MHpOspXqIRz9ACiE8e8vcfxgzDlXcEhU5I5eO2w0cSpeH62cklJrTW43a9VGKyfjKsvkFPMr2gO2M5ZgFpgh8GIUpDYB6nbk2LBpFzTWfhsJxmCUPLsOCpgZCPVXew+H2laHkWcDI9YIS6lVKH7QNV1bAT73JvZ0K+tFKPqUKAQCJEyO0NcX7AjMwNquaGwR7Nf7bTPjMo6b1Gj7c8Gt/zYRNb6JQnFIVHTgPg7TzMC1CBwinFgyyhGJNBc/mI18/mv1zGJRj6uIeId8G683kcb9Qb1Bk3qjB95FyCVEmqx26vA2Va2NUsZZha8k9oQyBkAEu7+Qpu3G1ps/MCZ3 Sack@it404-n01

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDpJAe+pZWOmAujMrDDdyHtcEqtJPC+AuqA6u8A6gGCaFip2Br2fpoBvPvacPDMY/Usn41WAjvu+MgjVq21sKWtBN6wo7l3kLqSerKpRAjnMnCQMRNKia857vGenuAjhmNT/81LjTtif99Yw40+0wnH/dlGofl7qFz7XpMNBi9fUDAMuP9rMF5q2Xmk6eAU5NQIZUHa5cZhn7RnWuldgJVjTUUljD+RYboNeLcK8joBK55JbfRpsrp/kJ4nkrfvXcFRFO4PFAWyplvCmzZ6K+6b9kX5PqAjik9l5mmc4EmVy6JFtBFHDqq/R8MNBtInVe2lF8+sloJy2yzYlEwswf8UwIRpYIV1x+48/OZwT2lMJ9VNd0Kkfn/DBbcidk1YxjJTqje7UE6SrG89yTyGsR4tgaoaDlt5NvyfgfURl7VBZHqpsfZZAvdtvfev5OQmyErORoJ7d381I9c+TJZkZreXyza/46Bamq1yWAc/g8rzRj8FStnVOWQ8q7ALG6gJmVoXEwtzhqPEhhK73bBBuTYE9ePO7kntzz+fhloZHM153b4WR4fdMSyE8PuCXWrA23N/xqeGtsPlY3LYBWZNIwreK036wTdVRcHViV6VHD2pz2OhFp8NEMcAafulbPN2i9wVw0koDyM6or1TJ1+6n+d9AT431g78GKsTbFO6uIcElQ== hendrik@hendrik-VirtualBox

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8XPHuVVP6szNGsH2xFw3bVxQN5DVQxQ//ZTq5h9XxV1KbYvY3uCRTrZegs4gAStN4/9JXVHiAoqAAOX/zXIEtOqPKWnZU05V4uYwfTzxmxobL0ugdHL9eV/azUFaMLPq6Vwk9bVUWWNQBxsqUvKVXJAZtzghhiSi7E848mTAnHT9op2BEPJ9hVhGxH1/QN4YOE9Xm4XY9P4IjbLEmlM7zLakxdhhzLWo1+Wjslk1JDTIeq3rZDrLUbQk/30Qben62EVVfFGtY4Uk09vkGPJYwHS6pW/j7OIgb08WL9uV4v8u2ytYJhP279Mykx8++HVMHYMLEev/qFuOcuFoQmGH5 stillh@IT398-N01

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfRVlzfzJqVxKgNGl9G3vhYiEW5b1912rantK/GECrHAMncEZ9yFcFdry9ECQqR0OQfMFk4VNk0qCTz/XlY7gylVALV0EQljT1I6L64vvx93d7DWgbx3TorXTfGKKEixeTTwIJNZBTHNUXhmjcrIGhjWVPNAygqqoTnhSxPj16ZzVFT/vaArq4CubwJr83Ll6lnllhP5OCDNP1TiBh3XFNgGwPwOhYHlfCQjYlYwO9CxIG2mK6YB+sFZCdSy3pWlN2T5dQvL9i3ZwW82vERxgUql9ZWgD+qqiOsmQVvTdF7bWouD2SSz5/aC76pvSGhtikJM2m35SnBf+gi1ZjiJsF schochw@IT416-N01

ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvpU6ZpVhI+LREwCDIQ8lJ+dYOJeg71DM+hNw5ysdXlzMrJKZrg4E/xSMFmNM643db5JDLXSbBhfHF4pZGDf/t6dPpQbA8mcrXimURkZWfOgujRHc8AkSd3iMZ8MCKPCyD0cEaX0A0kJzVgze/CZr2Lq191IJeId8wXc3o5GDz6XAPMtMFbETYJObRAwt42pSuCQ+VLz4sQivUY/W/52eshSebDOuySR4Yq4U0fyyzyBjlnoOcrohkHhZfRdUYI7vYkYQKFSvRdCGSFAH21fEkDGCuMDOC+iOfqrMUoBLcK5b81jLwu8rUe2bjVkPMxoQQuGjlMwJtrvj4NGcu679EQ== schappacheB@OGITNB053
EOF

#
# set up .vimrc
#
sudo tee /root/.vimrc<<EOF
syntax on
set hlsearch
set list
set listchars=tab:»·,trail:¢
set expandtab
set visualbell
set autoread
set noswapfile
set nobackup
set nowb
set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
filetype on
filetype plugin on
filetype indent on
filetype plugin indent on
EOF

#
# copy the vimrc to the ubuntu user
#
sudo cp /root/.vimrc /home/ubuntu/.vimrc
sudo chown ubuntu: /home/ubuntu/.vimrc

#
# pin the timezone of the image
#
sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

#
# install and activate ntp
#
sudo apt-get install -y -u ntp
for CMD in "enable" "start"; do
  sudo systemctl $CMD ntp
done

exit 0


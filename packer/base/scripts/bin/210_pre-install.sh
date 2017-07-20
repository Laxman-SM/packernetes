#!/usr/bin/env bash

set -e
set -x

if [[ ! "0" == "$(id -u)" ]]; then
  exec sudo -E $0 $@
fi

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
# htop on /dev/tty0
#
mkdir -pv /root/INSTALL && cd /root/INSTALL
test -d quiescence || git clone https://github.com/agabert/quiescence.git
cd quiescence && make
cd

#
# install google packages key for kubernetes repository
#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

#
# set up kubernetes repository
#
tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get -y -u dist-upgrade
apt-get autoremove -y

BORG_VERSION="=1.6.7-00"

apt-get -y -u install \
  kubelet"$BORG_VERSION" \
  kubectl"$BORG_VERSION" \
  kubeadm"$BORG_VERSION" \
  kubernetes-cni $BASIC_PACKAGES

#
# set up .vimrc
#
tee /root/.vimrc<<EOF
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
cp /root/.vimrc /home/ubuntu/.vimrc
chown ubuntu: /home/ubuntu/.vimrc

#
# pin the timezone of the image
#
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

#
# activate ntp
#
for CMD in "enable" "start"; do
  systemctl $CMD ntp
done

#
# inject github user keys
#
if [[ ! "" == "$GITHUB_KEYS" ]]; then
  for GITHUB_KEY in $GITHUB_KEYS; do
    echo "## github keys for user [$GITHUB_KEY] injected at $(LANG=C date +%s)" | tee -a /home/ubuntu/.ssh/authorized_keys
    wget -SO- https://github.com/${GITHUB_KEY}.keys | tee -a /home/ubuntu/.ssh/authorized_keys
  done
fi

#
# CNI
#
sudo mkdir -pv /etc/cni/net.d
sudo tee /etc/cni/net.d/10-weave.conf<<EOF
{
    "name": "weave",
    "type": "weave-net",
    "hairpinMode": true
}
EOF

#
# CLOUD
#
systemctl stop kubelet || echo
mkdir -pv /etc/systemd/system/kubelet.service.d
tee /etc/systemd/system/kubelet.service.d/77-kubeadm.conf<<EOF
[Service]
Environment="KUBELET_EXTRA_ARGS=--cloud-provider=aws"
EOF

systemctl daemon-reload

#
# authorized keys
#
tee -a /home/ubuntu/.ssh/authorized_keys<<EOF

#
# these are github keys injected at $(LANG=C date +%s) by packer using [$0]
#

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQCVLYv9BFJkz0gOlBv/FHLVBupaRYNPscMzYs5MvCbngPxAcTYdMWNVlDx+NhZ0nGKWzCBRrCNmwtJiJhKxCD2MBYaepgZI+67yC5Wb0UfNxAy2PHLQjRY5S13bDEAEssfavmArsynOyIY+m8dLW8lCZN8oS72k2C6PnjTofLBQlWLfBf6ohWY3WWkuM0vH2m2X+4YG0n2mz6CA4nxOoj8IylzDM1FIw4iNAcShJYyd93s/jd2mR8eymvvlxhzsgh2s3Uef2TTLDSO0NnBpmMRygswfRLd3nARNbvxIobRJrwJ95306b7qyG8Lo3U60sYKZyQfM6LDJfrc0zi1TyS0Ulrl725gP7KxpaDAyzYZ3xhWTVvRKMRyibbo6SwddRyLU2obon+B2ycfNFVtmLfPmpmwwQE8nLv1KNimpThHk6QAotofcauL8ATD7AvKzAX5z84YYNAD24c2VxwK7k8G4b5un6ttw90AVClnfQ1fjP4/8tooodLWVl9B7+25XMAP8DqYQuoY4odAl4ROb5MEseWH2fiqmpNGxHOQi+431lf9XYoWMNitx5OLoMZNXgYJlTCGwWnaUPQNEj1iSgtWuGdzb0ULAnJUfL3Pd8EEVAU1cjUvIvSXcDJXM7Nu1rvE0/MWKrVcZ6B6WGGLXaIK0oAI7b+gY8CzYk1LU7IIHi86Kp/sZczr/2gUK3lEeb87TJ4bXeIe0W4ZbSWnLC5IulZyEy38p8zd+N6tEELMwqwP8lq5/mF0hL9CUZdnBQIqVGarVVE1xK7kQtWcdyk6lKNB6jdkID3Ckbglc5H6TzcRjeb1fstqLpyzbUez5lH41dDfGIFJSWmCebOz6OjhpAihaOXMLkclHn9u7WnBwsjJN9e2jxKp33oVE+O77SvfDOtOzf5Rq3rfm+bAj0agPYNyO5g3y5ufx7lhUX9yJShXfQu5qRY3qxuVvElGnSKgug8Ut3Ezs411lIUcPY5RliarY1u2BIDklzCxy4pvCSOYWOGLhh2XQjkGMTlO6HwTvMwFXg2AoV6+xtmW8H+lsb0+iJ4f48TtCmp4Zht8uId4Ma9qzKEMMNSnEJmgB95d/OxzYckFiMAYYs4HGKNsVIdkeiz1Zz9SM0OSRAoJ4SUGlLaFYb2Ybpp2Dizl8/wGbNBeisjmrvyesaO+YJT08lvLqyvvOeXk8pqrIUet9MI7tHjVxN7yHw/tysvDsJKonnkELqG6YhJytYTTC/9wpjOFe5y6cbR4BSboEXZDRzUp6aANBU+TtLRSbRS/iqyZGJdWvEhF5vvl/enmBq+edX/RPxkTx0Tq2bqtbzzocpVOzTU+xXqyve2m8um3WN/fpL/kZ/yvkioBCTFgZjlOr agabert@conway

ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA6k91qeEG43uglZhxHyxkeL3dDlsAxVLK2YbFhZSFsNMbXzBw570Lo7G9KY9MgOlyDBS8bqWYl/hWNN8Cz0DpaawoA16yqoe55hIcdIh3iseORsXEa3OTYhP9FynT8oh0aOqSDM0gpVuIp8NQ21zCOfJlBhU1gerzpZqjJSfR0js=
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDK8bpPnwq5G10x5lfWRy7cESWHvwUc1p9lCt0f8okRUFdKsyK8Hpm8y3wRzoohsvWzkGDRpHSgjPIhmm3QfaUy0CtJpka6kydhaYxfUknvp97vH7ucMO7nrCqIAsrleEGUzgFJrNemvT5IbI6Qzqi9EWJGNvhVHT49Q0R8E4SXmPY2hQgkODzzCPg4H8So7d32cU+CqPjbI7xA6s1adsdEawKkFDveg60MunAMJPazU1E/nmCZVwc77/vYN9cKzrZx34vwMLzqO4onJ7JrzUBPi5IESZyyfw5TRj0Oij3US2a6eIvZFCHldvSHEwPo/Sq4h/tNydtNYUArXsIBi6Gb
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmbJdu2hxkIX8Enmfl2/PTfb18rKZhSLT1vpYCFImui2d/lB6B+19VSt4K2/qWQ91strMVHbaK6AEkEZTzGIJRn6a5SXt2TSixh/c+dbsFnvlUTvFzQ+pEZvrLs0G72KzvpBTjghsAP5NxhDpWAYQ8FJlttfiU4ea3wDReY3VIervQFlDPteSlC0dhzInpJYdI6fIPfNEGnnkekwFBzJaw57BW2CrBGFxlH7+nPZN/zM/SevAqDiBiMzRFewz6/nsokzZUKl4gQlCZVqKCxb4sOrtqMOyFeRNd59kIAx0vJyy/yxxwBz3xvQ0CP6YoyzMHH+gtveEQUGFZtNLng33h

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQCkN6bLn/+YAlhwAq1Oy6MvkshSdh8Mi3wVJ5Jjd74A27aPFzeyamc+AtgCQWdQ1pfVzcwacrAyDkYs0/pqxY22Lqfj3dpVaYLdJrVm+FkX0w+nzxfaol03P8FRM+IV46fQ34588/U3IF5sB6MmevTHXGaDLFy8thFi8+9x3q9hogHAiwBYOmdme2WS0Kvkqirynldlgxz5RdR66TerHV4YDVuCeSbgMBKd2NOzIqAYZZA/H4nAxmWDI9dSBK7fo+WvgnSrcylVew3n4ELd+1lfiuhpDaNoBeOulRObpZ0ayfK3BiIInl8r7LrCXru73bKvZ270eZbgWRmnFT7bwfKTqvxbjRw4Fdlek8cA+RQ2h5tZZk5eC8pKNoOkjrWqYxaUg7a+SYATFZexdAZ8gdjrtixscenye+nsbhECv4a+77cOxj0MnpKzaBmp3IxY7zAG/dGKNxB1Uss7vAY8vXCfo2iTDy+QuvnLhwHSxF9/tjceazmVbrHFqbvHJKocFWbXP8xoWzmwwElb2lWKrwHTjh1MyGo18R8J7YJPPHw/y4tDJG4TxZBO49niKwPdasfVcPuPYW9FsNf+GUwIdmK+/FkAwWb1NlUbMO+BOBq/k4T1hT9JNHY9A4RY6N7eiIWpXEp6toQX8bMmDNm+BSRlcGNQQxv7+5iHkEolG/g6TosNyDVYHtRXK9abGP0+isN8ZYFGa1027mI5PuzY+4HQmoNthPAoxAPhgfyJOYvV4KBbGvDtl17wA/grgwXcnftK0BIn13en88IPNFXhElwgT+nnKhNWm6dFidpq+GUl99TL6/Z1XOzdI009P/mobsnEkqxPno1+l1tDQUGPJmcSK8ahZe+dgEyHyavGItG9zHZipF1jlDK0CN66j4SCvFTyl/CPiCF9K2TxOGBRvad/p1jsE55mdQ4PQpFGN0uJxbp5Ww1auqU5Y8DRtz2JB5P9lTVG5Er7FIF8W6gJXV8AD1xNyGnHJFeTuHuygsXRdx32Qg3K6CZ+hYlYqeYThz/YATwFRMDTmWch0v1B0xfTjfgwTUFsLt2zfAsB4jqWhIcHH+iN8zg5iP3Umb/RkKZc1SfGuDuwT9+nvtL3w5+JVg8a5IU3DnT9jBzHQfoY729UxrBUEMqyWvUsII3u9FuwrJ9UCOmYJHMNwrz62nKGP9dZNcvW5wjvERTdDBXvclM7LsJpe5AOUD7lPDuJPUWjLsBQfvFTBfBRMXQHRp37U6FfufuHyQgDgpbr4rmdpzeTi5aWoi5x0mLIe4uHbj74AIArDNYPHhJVv0uwblbIP1MwzJmbUnmGYKjtjti7DyByfVQ8peTS28yMMnxEZtvg9sFzQ4mrgrz+8J4dhuUl agabert@T420

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC58YKtfLnsTdOA2oG9a1bXlVEKs5HhDEgQ9gbCim6dMWvCdczBEUKtAcClbov6UShW7hXYhFjiUHeBNEnlz6DT655w7qoJfbaMdjuO2SKiHQMl5YDTnr9omXWSgHwEZuKKAtCH8/i3K5Lh3cb6DY2bKWLn46t80kvsx7BBz6Ln9VVH5J+kDpF/F3f5kuWthCDHCNiLMA5zRlIQexgrh/vhws6L7k/rzcqIKVuXsrxbHiA4Edd+JqUXuFFvUaM94tmGB7NZRLxJkbpG4ADRfM8poWB8fC44z+v7LiIO8y4HOQqrRefnPR8ruXwzShAfRReXuH1Q4AKGc6FI31riMtzV jcofman
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPz9mUHw16ejsIQ+DRwfCRrK4tOFL2x96ve3rKS+fQ9T5c6llC+JQVNr7ZPbMK4kUW0vWY9YixirDFc/WL+rxyg5LsMMqow4zlvXh+BRLPG/0VRsKfvqe8Efe6cugr9yfA+H+MYwDMipOJfn87VSB9JNTH6kwvS+WxPDQABDpnHhF3MOj8epa0/iHtZrHF3mVp4BsO2uTuE/pH+4GjKeBU1ZIprtb2mecEPuDn6Oh+DcU4IqkQtklDg9LvxLUEH03ZR1V8c1VKDitUJOpFIi2r+A6GUJtXr8tDtoIWuhfxdZ9DYMjwRa+MDfE71JvzTn/wRfLT9sTzpANAEj7FP/Kj jcofman
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHJJ4xtFvqHVl0SZQqUXWRpXgUT2bZKe067S5o2f0Vk7ELJTrxuGLRqNK+trEOsBIPANfCpK+gwYhr9OVt7VfJ5bVK9lhHQEhfcDE7K1edb89iHoiDiEpTPf5ZjRnY9icjytNzEFsRxoB5tFO1/P+VlGioX9nn7zabKPnadjB4t612T5CQRqenaY8T3V9xF4kUuS7ZM/vUDmalCi4Ug4yjJPIzrjlF6z7hntuXyqu/TPIX93tRygO+iLP5Pc4gK3HIlGU/fmchejZsSazVnG8T+oFKTIctm3kGHT61t0sBhU2A+Gbx36UnwohgNrHgpk0F2Gkal70XDeGpsC6sjuZ3 jcofman

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLfTRpnrD3PVtbfeUsCEBkGf3fE+x8SU93IuC5Vu0dUCcMeVWVX56z1oWNxhN3FXInJfxsn2nEgqal1YKV+R/bw30iRR/ByxnlRwRHz1Y0mJ8fnCwTjhN20s7UkfR/p6Oh9FMW74TqkDWEluonni/GfyEWCJJ/wdfwtWBvbfIwJ1U4BtUeILmUmRRx9DJZfyOJd4UJSohAflcfo8zDJWZPOXD0a+48esxxfaj4p4sRdZm6TACXkDgp/Qb7w+LN0cVOhptWoVSXxNetnVdE/amJhAOyzdpK6holvFW/V/JYJjmfVf32PO852r/VfKC9+lFZ+wyNOwKF01oHmJcCVuoSnR5enSE/f7lKnU1XjWlRyhSzbsErNQB1kSL9lXAzrIBjVKfyLEh1ARR3HjQMy7LgKsUaoFBK8Ses5ONP8eAej877RAAQUQo1eJy2lKqAIKH7L4+ETxlGBrvCavOPquw7cFy6Xj3/H7FFhKuTzeo4eGjSaKXnFyGpIyvIjMaKu/wwzd++urAVoglHXxjSa03GRBnf+vTZ1rWcuPG4KVtiM/of3YIcpqAc79ifBcHJWfCPv9WgSIWyVcNA+jJ1eTwQT1c+BOSlbAAYxirIkqz6AjS9Aqi1BaJQfSsR4CN3TUOHVRv9aP5RqCQS131v+0UdnBxkGOrrKIoLB5hSnvqq3w==

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

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCi4FfvR6WOs/dRRKSyLkJ58/jAn5nspsZ7lgk7Z+5Qh9q7MZHNDr2DwaoLMZ8zycAE+ve+ObvpqAieSuGTnJJl7iOi+VJE+/kDzjU7BDI0g2c351usGoUtFM/vPtN4hbFJIn3/OnxZp2XQStcia6GmietWIB+idqGZ9soYmKAiWsC2NPcD8xzMUFZrGQoLosMkH8BwQEeCQjDIw3+iz3upfzGjz8QFKNOTBqimJZkimeyTFWM7pf+ebbaeygXHqYbftjtih1i9ugnw7KZzgJUsD9Whr78m8k/BMB+XafuzaviwLShijApD5gt39dT+sutpBVAzupopKeA+aQKlMjZSq9KNegC1iHG73AO+T+sa59/htWMby+N1MJFJVvS7fcX6WGTtvfkX+8UOW31O4qqI4CSfu5orNmYLx9tcYa45rivxklQMzT033jCAHpXaZh9u7nnaJPNMUd4DXdAbY5XSeecTGCVuRw5HlAQ29GzjGSqPdM/8+q5m+d6F4W5ZMWfRVPLDRXC75mh3jnSbrI97VU2petcjPGrYpzDYVXsyK/ZJ74xCTkP4NcME5GURABwqsXKlSuv1pkcyKWMuQvJNEuwhlWpDAcfE4eIs99dBaouD6JG7SxXtv9rTJfOAykjrsb5TlWCOHGSvqACdJMAfflI/QzEJ44i5MR7urvI12w== wschoch@Todesstern.local

EOF

#
# root logins
#
sed 's|disable_root: true|disable_root: false|g;' /etc/cloud/cloud.cfg
systemctl restart cloud-init

mkdir -pv /root/.ssh
cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
chown -Rv root:root /root

chmod -v 0755 /root /root/.ssh
chmod -v 0644 /root/.ssh/authorized_keys

exit 0

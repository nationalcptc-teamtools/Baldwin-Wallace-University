#!/bin/bash
# 
# This script will do the following:
#  - Install Docker
#  - Install and configure OpenVAS
#
# You must run this on a debian-based system, such as Ubuntu. 
#
# This script is provided in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#

#!/bin/bash
iface=$(ip route | grep default | sed 's/.*dev \([0-9a-z]*\) .*/\1/g' | head -n 1)
ip=$(ip addr show "$iface" | grep 'inet ' | tr -s ' /' ' ' | cut -f 3 -d ' ')
read -sp 'Password: ' password
apt update
apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
docker run -d -p 443:443 -e SETUPUSER=true -e OV_PASSWORD=$password -e PUBLIC_HOSTNAME=$ip --name openvas mikesplain/openvas
echo Waiting for OpenVas to be ready...
sleep 20;
while grep -q 'openvas.*Rebuilding' < <(ps -ef|grep -v grep);
do
sleep 5
done
echo Complete!

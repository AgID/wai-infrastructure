#!/bin/sh

# Fail script on first error
set -e


# Download etcd binaries
download_ansible()
{

	echo "Downloading ansible"
	sudo -E apt-get update	
	sudo -E apt-get install -y software-properties-common unzip 
	sudo -E apt-add-repository -y ppa:ansible/ansible
    sudo -E apt-get update
    sudo -E apt-get install -y ansible
	echo "finish ansible installation"

}

download_jinja ()
{
	echo "Downloading jinja"
	sudo -E apt-get install -y python-pip
	sudo pip install Jinja2
	sudo -E apt-get install -y python-netaddr
	echo "finish jinja installation"
}


sudo true
download_ansible
download_jinja

# Download kubespray 2.8.3
wget https://codeload.github.com/kubernetes-sigs/kubespray/zip/v2.8.3 -O ansible/kubespray-2.8-3.zip && cd ansible && unzip kubespray-2.8-3.zip && cd ..





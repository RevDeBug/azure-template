#!/bin/bash

# RevDeBug DevOps Monitor installation script.

# Docker installation
install_docker() 
{    
    # 1. Installing required applications
    sudo apt-get update
    sudo apt-get -y install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    # 2. Adding docker repository    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

    # 3. Installing latest docker
    sudo apt-get update
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io   
    
    # 4. Installing docker-compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

#RevDeBug DevOps Monitor installation
install_rdm()
{
    wget https://raw.githubusercontent.com/RevDeBug/azure-template/feat/vm/server/resources/docker-compose.yml

    export REVDEBUG_AUTH="$1"
    
    sudo -E docker-compose -p rdb up -d
}

if [ -z "$1" ]; then
  echo "Missing RevDeBug OrganizationId parameter."
  exit 1
fi

if [ ! -x "$(command -v docker)" ]; then
  echo 'Installing docker...'
  install_docker
else
  echo 'Docker already installed.'
fi

if [ ! "$(sudo docker ps -a | grep rdb_server_node)" ]; then 
  echo 'Running RevDeBug container...'
  install_rdm "$1"
else
  echo 'RevDeBug container already created.'
fi

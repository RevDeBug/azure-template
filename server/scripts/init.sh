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
}

#RevDeBug DevOps Monitor installation
install_rdm()
{
    sudo docker run -d --name rdb_server_node -p 42733-42734:42733-42734 -p 5000:5000 -v /var/revdebug/server/repo:/app/RevDeBug:rw -e REVDEBUG_AUTH="$1" -e CONTINUOUS_CONNECTION_STARTUP_MODE='crash' docker.revdebug.com/server
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

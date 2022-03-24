#!/bin/bash

# RevDeBug root volume path. Default value matches the one on compose files.
REVDEBUG_ROOTVOLUME_PATH=${REVDEBUG_ROOTVOLUME_PATH:-/var/revdebug}

# RevDeBug DevOps Monitor installation script.

# Docker installation
install_docker()
{
    # 1. Installing required applications
    sudo apt-get update
    sudo apt-get -y install \
        apt-transport-https \
        ca-certificates \
        curl git\
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
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

#RevDeBug DevOps Monitor installation
install_rdm()
{
    # Change workdir. For Azure deployment this normally should be a default user's home directory.
    if [ -n $REVDEBUG_WORKDIR ]; then
        cd $REVDEBUG_WORKDIR
    fi
    
    git clone https://github.com/RevDeBug/revdebug-server-docker-compose ./revdebug
    
    cd revdebug
    cat > .env <<ENV
# Organization ID obtained from portal.revdebug.com
REVDEBUG_SERVER_NAME=$REVDEBUG_SERVER_NAME
REVDEBUG_AUTH_OPENID_ADDRESS=https://${REVDEBUG_SERVER_NAME}/auth/realms/rdbRealm
REVDEBUG_SSL_CERT_PATH=${SSL_CERT_PATH:-"/etc/letsencrypt/live/$REVDEBUG_SERVER_NAME/fullchain.pem"}
REVDEBUG_SSL_CERTKEY_PATH=${SSL_CERTKEY_PATH:-"/etc/letsencrypt/live/$REVDEBUG_SERVER_NAME/privkey.pem"}
REVDEBUG_AUTH_OPENID_SECRET=$(openssl rand -hex 12)
KEYCLOAK_USER=$KEYCLOAK_USER
KEYCLOAK_PASSWORD=$KEYCLOAK_PASSWORD
ENV

    initialize_certbot

    sudo docker-compose -f docker-compose.yml -f docker-compose.certbot.yml up -d
}

# Certbot initialization for SSL certificate.
initialize_certbot() 
{
    domains=($REVDEBUG_SERVER_NAME)
    rsa_key_size=4096
    data_path=$REVDEBUG_ROOTVOLUME_PATH"/certbot"
    email=$REVDEBUG_SSL_EMAIL
    staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

    if [ -d "$data_path" ]; then
      echo "Skipping certbot initialization - RevDeBug volumes already exist."
      return
    fi

    echo "### Creating dummy certificate for $domains ..."
    path="/etc/letsencrypt/live/$domains"
    sudo mkdir -p "$data_path/conf/live/$domains"
    sudo docker-compose -f docker-compose.init-cert.yml run --rm --entrypoint "\
      openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
        -keyout '$path/privkey.pem' \
        -out '$path/fullchain.pem' \
        -subj '/CN=localhost'" certbot
    echo


    echo "### Starting nginx ..."
    sudo docker-compose -f docker-compose.init-cert.yml up --force-recreate -d nginx
    echo

    echo "### Deleting dummy certificate for $domains ..."
    sudo docker-compose -f docker-compose.init-cert.yml run --rm --entrypoint "\
      rm -Rf /etc/letsencrypt/live/$domains && \
      rm -Rf /etc/letsencrypt/archive/$domains && \
      rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
    echo


    echo "### Requesting Let's Encrypt certificate for $domains ..."
    #Join $domains to -d args
    domain_args=""
    for domain in "${domains[@]}"; do
      domain_args="$domain_args -d $domain"
    done

    # Select appropriate email arg
    case "$email" in
      "") email_arg="--register-unsafely-without-email" ;;
      *) email_arg="--email $email" ;;
    esac

    # Enable staging mode if needed
    if [ $staging != "0" ]; then staging_arg="--staging"; fi

    sudo docker-compose -f docker-compose.init-cert.yml run --rm --entrypoint "\
      certbot certonly --webroot -w /var/www/certbot \
        $staging_arg \
        $email_arg \
        $domain_args \
        --rsa-key-size $rsa_key_size \
        --agree-tos \
        -n \
        --force-renewal" certbot
    
    sudo docker-compose -f docker-compose.init-cert.yml down
}

set_variables() {
    REVDEBUG_WORKDIR="$1"
    REVDEBUG_SSL_EMAIL="$2"
    REVDEBUG_SERVER_NAME="$3"
    KEYCLOAK_USER="$4"
    KEYCLOAK_PASSWORD="$5"
}

set_variables "$1" "$2" "$3" "$4" "$5"

if [ ! -x "$(command -v docker)" ]; then
  echo 'Installing docker...'
  install_docker
else
  echo 'Docker already installed.'
fi

if [ ! "$(sudo docker ps -a | grep devops)" ]; then 
  echo 'Running RevDeBug container...'
  install_rdm
else
  echo 'RevDeBug container already created.'
fi

# RevDeBug Devops Monitor ARM template

## About this template
This Azure Resource Manager template can be used to deploy the RevDeBug DevOps Monitor on your Azure Cloud. This deployment will create a new Ubuntu 18.04-LTS virtual machine within a resource group of your choice and host the RevDeBug DevOps Monitor using Docker Compose. If you already have a Docker hosting environment and want to use it for the RevDeBug DevOps Monitor deployment, please refer to [this article](https://revdebug.com/doc/tutorial/newest/Product-Guidelines/DevOps-Monitor/installation/).

## Setup
You will need to obtain the RevDeBug Organization Id before deploying this template. Please refer to [this article on how setup your RevDeBug Organization](https://revdebug.com/doc/tutorial/newest/Product-Guidelines/DevOps-Monitor/portal/), or got to the [RevDeBug Portal](https://portal.revdebug.com/UserPanel) if you already have one.

When using this template you may change any option according to your needs. It is highly recommended to store the credentials used in this setup. While the RevDeBug DevOps Monitor doesn't require any daily administrative tasks, admin user is crucial for performing backups and updates.

## Deployment
You can deploy this template on Azure using this button:
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FRevDeBug%2Fazure-template%2Fmaster%2Fserver%2Fazuredeploy.json" target="_blank">
	<img src="http://azuredeploy.net/deploybutton.png"/>
</a>

## Updating the RevDeBug DevOps Monitor
To update the RevDeBug DevOps Monitor, you have to login into the virtual machine using SSH client of your choice. You will need to run commands listed below:
1. To pull newest docker images use: `sudo docker-compose pull`
2. To restart the RevDeBug DevOps Monitor use: `sudo docker-compose -p rdb down && sudo docker-compose -p rdb up -d`

## Application data location
Application data for the RevDeBug DevOps Monitor is stored in the `/var/revdebug/server` directory.

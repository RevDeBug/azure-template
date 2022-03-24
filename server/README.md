# RevDeBug Devops Monitor ARM template

## About this template
This Azure Resource Manager template can be used to deploy the RevDeBug DevOps Monitor on your Azure Cloud. This deployment will create a new Ubuntu 18.04-LTS virtual machine within a resource group of your choice and host the RevDeBug DevOps Monitor using Docker Compose. If you already have a Docker hosting environment and want to use it for the RevDeBug DevOps Monitor deployment, please refer to [this article](https://revdebug.gitbook.io/revdebug/installing-revdebug-server).

## Setup
After deploying this template you'll be asked for a valid RevDeBug license. For more information, please refer to [this article](https://revdebug.gitbook.io/revdebug/installing-revdebug-server#get-a-license).

When using this template you may change any option according to your needs. It is highly recommended to store the credentials used in this setup. While the RevDeBug DevOps Monitor doesn't require any daily administrative tasks, admin user is crucial for performing backups and updates.

## Deployment
You can deploy this template on Azure using this button:

<p align="center">
    <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FRevDeBug%2Fazure-template%2Fmaster%2Fserver%2Fazuredeploy.json" target="_blank">
        <img src="http://azuredeploy.net/deploybutton.png"/>
    </a>
</p>

**Warning!** Due to a bug in the Azure Portal, generating a new key pair for a SSH connection might not work in Azure Template Custom Deployment. If you don't have one, please create a new key pair beforehand.

## Updating the RevDeBug DevOps Monitor
To update the RevDeBug DevOps Monitor, you have to log in into the virtual machine using SSH client of your choice. Default settings on the Network Security Group prohibit any direct connection via the internet to SSH port, so you will have to either use VPN/[Azure Private Link](https://azure.microsoft.com/en-us/services/private-link/) to access the virtual machine, or [modify Network Security Group](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) settings to accommodate your needs.

After securing the connection with your virtual machine, you should be able to see the `revdebug` directory inside your default user's home directory. This is where the RevDeBug docker compose files are cloned on the virtual machine as part of the Azure Deploy procedure. You will need to make sure that you are in that directory before running [update commands listed in the documentation](https://revdebug.gitbook.io/revdebug/updating-revdebug-server).
## Application data location
Application data for the RevDeBug DevOps Monitor is stored in the `/var/revdebug/server` directory.

## Privacy notification
When you deploy this template, Microsoft can identify the installation of RevDeBug.com sp. z o.o software with the deployed Azure resources. Microsoft can correlate these resources used to support the software. Microsoft collects this information to provide the best experiences with their products and to operate their business. The data is collected and governed by Microsoft's privacy policies, located at https://www.microsoft.com/trustcenter.

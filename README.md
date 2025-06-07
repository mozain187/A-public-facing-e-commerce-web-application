# Azure E-commerce Application Infrastructure

This repository contains Infrastructure as Code (IaC) templates and deployment workflows for a secure, scalable e-commerce web application hosted on Azure.

---

## Project Overview

This project deploys an Azure infrastructure that includes:

- An **Azure App Service** hosting the e-commerce web app
- An **Application Gateway** configured with a Web Application Firewall (WAF) to protect against OWASP Top 10 threats
- **HTTPS enforcement** with HTTP-to-HTTPS redirection
- Secure backend traffic routing from Application Gateway to App Service
- **Azure Bastion** for secure internal management access
- Network Security Groups (NSGs) controlling network traffic

The goal is to provide a secure, highly available web app environment accessible over the internet while protecting internal resources.

---


## Technologies Used

- Azure App Service
- Azure Application Gateway with WAF (OWASP 3.2)
- Azure Bastion
- Azure Virtual Network & Subnets
- Network Security Groups (NSGs)
- Bicep for Infrastructure as Code
- GitHub Actions for CI/CD pipeline

---
## my humble Architecture Diagram ^-^

                     +-----------------------+
                     |       Internet        |
                     +-----------+-----------+
                                 |
                         Public IP (App Gateway)
                                 |
                     +-----------+-----------+
                     |  Application Gateway  |
                     |  - WAF (Prevention)   |
                     |  - Custom WAF Rules   |
                     |  - HTTP to HTTPS      |
                     +-----------+-----------+
                                 |
                         Backend Pool (FQDN)
                                 |
                          Azure App Service
                             (E-Commerce)
                                 |
                     +----------------------+
                     |  Azure Bastion (Admin)|
                     +-----------+----------+
                                 |
                             VNet + Subnets
                                 |
                             NSG Rules
---
## Repository Structure

/azure-ecommerce-app/
├── bicep
│ ├── main.bicep
│ ├── app.bicep
│ ├── bastion.bicep
│ └── hub-vnet.bicep
├── /Cli used
├── .github/
│ └── workflows/
│ └── deploy-bicep.yml # GitHub Actions workflow
├── README.md




---

## Deployment Instructions

### Prerequisites

- Azure subscription
- Azure CLI installed locally or use Azure Cloud Shell
- GitHub repository configured with a secret named `AZURE_CREDENTIALS` containing your service principal JSON credentials

### Deploy via GitHub Actions

1. Push your Bicep files and workflow YAML to the `main` branch.
2. GitHub Actions will automatically deploy the infrastructure to the specified Azure resource group (`hub-rg`).
3. Monitor the deployment status in the GitHub Actions tab.

### Manual Deployment

Alternatively, you can deploy manually:

bash

az deployment group create --resource-group hub-rg --template-file bicep/main.bicep
Custom WAF Rules
This setup includes custom WAF rules to block specific IP ranges and suspicious user agents like sqlmap, curl, and wget.

Security Notes
Bastion is deployed in a dedicated subnet with NSG rules allowing management traffic.

Application Gateway enforces HTTPS and blocks common web attacks with WAF in prevention mode.

Network Security Groups limit traffic flows within the virtual network.

-----

Contact
For suggestions, please contact [mboating2@gmail.com].

Happy deploying! 🚀





---


If you want, I can also help with:

- Explaining how to generate and add the Azure service principal credentials to GitHub Secrets.
- Writing your GitHub Actions workflow YAML with your exact resource group and files.
- Any other part you want to polish!


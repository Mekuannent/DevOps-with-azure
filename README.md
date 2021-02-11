# Project to deploy a Web Server in Azure
## Introduction
In this project, you will write a Packer template and a Terraform template to deploy a web server with a load balancer in Azure.

The project will consist of the following main steps: 
- Creating a Packer template
- Creating a Terraform template
- Deploying the infrastructure

## Getting started
Clone this repository on your github account, so that you can work on this copy

## Dependecies
- Create an Azure Account
- Install Terraform
- Install Packer
- Install the Azure CLI

## Deploy a policy
Create a policy that ensures all indexed resources are tagged. This will help us with organization and tracking, and make it easier to log when things go wrong.

#### Policy definition
Write policy definition to deny the creation of resources that do not have tags

`az policy defnition create --name 'tagging-policy' --display-name 'Deny create if no tags' --description 'Deny the creation of resources that do not have tags.' --rules 'tagging-policy.json' --mode All`

#### Apply policy definition
`az policy assignment create --name tagging-policy`

#### Check policy
`az policy assignment list`

## Create Server image using Packer Template
Server resources are defines in the file server.json

Ensure all resources are defined in server.json and the resource group specified in Packer for the image is the same image as specified in Terraform

`packer build server.json`

## Create the server infrastructure using Terraform Template
Terraform template will allow us to reliably create, update, and destroy our infrastructure. 

Our terraform template should create the following infastructure compontents
1. Create a resource group
2. Create virtual network and a subnet on the virtual network
3. Create network security group and security rules
4. Create network interface
5. Create public ip
6. Create load balancer. The load balancer needs

   6.1. Backend address pool
   
   6.2. Address pool association for the network interface and the load balancer
   
7. Create virtual machine availability set
8. Create virtual machine. Make sure to use the image you deployed using packer
9. Create managed disks for the VM
10. Ensure variable file to allow customer to configure the number of VMs and deployment

## Deploying the VM image

Use Packer to deploy your VM image in Azure CLI as shown below

`packer build server.json`

## Deploy the infrastructure

Run Terraform command to deploy the infrastructure on the image just created. 
Save the plan with file name solution.plan

`terraform plan -out solution.plan`

Once deployment is done, destroy the resources defined in the Terraform configuration

## Variables

#### Input variables 
variables that are used in Terraform to plan, apply and destroy operations are saved in ***vars.tf*** file. The values of these variables are determined by user input.

#### Assign values to your variables
Terraform can populate variables using values from ***terraform.tfvars*** file

## Output
Screenshots are saved in this repo
* tagging-policy definition, 
* tagging-policy assignment, 
* packer build,
* terraform apply and 
* terraform destroy



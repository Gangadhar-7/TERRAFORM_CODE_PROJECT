## CSYE6225- Network Structures and Cloud Computing

## Assignment 3: Project description 

<br>Infrastructure as Code: This assignment will focus on setting up networking resources such as Virtual Private Cloud (VPC), Internet Gateway, Route Table, and Routes. We use Terraform for infrastructure setup and tear down. <br><br>

## Terraform
Terraform is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure <br><br>

## Setting up Infrastructure using Terraform 
 
<br> The terraform init command initializes a working directory containing Terraform configuration files:
```
terraform init
```

The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure:
```
terraform plan
```

The terraform apply command executes the actions proposed in a Terraform plan to create, update, or destroy infrastructure:
```
terraform apply
```

The terraform destroy command is a convenient way to destroy all remote objects managed by a particular Terraform configuration:
```
terraform destroy
```

## Assignment 4: Project description 
Updated the terraform script to create an EC2 instance from the custom AMI image.

## Assignment 6: Project description 
Updated the terraform script to create a DNS A record and point the subdomain to the EC2 Ip address.

## Assignment 7: Project description
Updated the terraform script to add cloudwatchagent server policy to the EC2-CSYE6225 role.

<br>
Developer - Nagendra babu Shakamuri <br>
NUID - 002771584 </br>
Email - shakamuri.n@northeastern.edu

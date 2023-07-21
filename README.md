## CSYE6225- Network Structures and Cloud Computing

### API code is available on https://github.com/Nagendra-babu-Shakamuri/webapp

https://github.com/NagendraBabuShakamuri/aws-infra/assets/114452317/08618cae-52e7-4609-8225-bfa811d1be72

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

## Assignment 8: Project description
Updated the terraform script to add load balancer, EC2 target group and Auto scaling group to balance the load between/among the instances.

## Assignment 9: Project description
Attached the imported SSL certificate to the listener interface of the load balancer and allowed only HTTPS traffic.
Updated the terraform script and removed HTTP port from the listener interface of the ALB to prevent HTTP traffic flowing into the Loadbalancer.
Updated the launch template to encrypt the EBS volume of the EC2 instance with a KMS key.
Also used another KMS key to encrypt RDS.

Following is the command used to import the NameCheap SSL certificate into the AWS certificate manager.
```
aws acm import-certificate --certificate file://Certificate.pem --certificate-chain file://CertificateChain.pem --private-key file://PrivateKey.pem
```

<br>
Developer - Nagendra babu Shakamuri <br>
NUID - 002771584 </br>
Email - shakamuri.n@northeastern.edu

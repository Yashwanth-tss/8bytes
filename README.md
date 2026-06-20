# End-to-End devops project

## Infrastructure 
The infrastucture provisioned using terraform in AWS cloud. 
consists of  VPC, Subnets, Route Tables, Gateways, Security Groups, RDS, EC2, ECS, ECR, ALB, ASG.

### Tech Stack:
- Terraform
- AWS
- Docker

## Architecture
The architecture consists of a VPC with two public and two private subnets.
The public subnets host the Application Load Balancer and the EC2 instances.
The private subnets host the RDS instance..
The VPC is connected to the internet through an Internet Gateway.
The Application Load Balancer is connected to the public subnets.
The EC2 instances are connected to the public subnets.
The RDS instance is connected to the private subnets.

## Infrastucture configuration steps
Clone the repo 

```git clone https://github.com/Yashwanth-tss/8bytes.git```

```cd 8bytes```
```terraform init```
```terraform apply -var="aws_region=ap-south-1" -var="db_username=your_username" -var="db_password=your_password" -var="db_name=your_db_name" -var="app_port=80" -var="my_ip=[IP_ADDRESS]"```

the infra is built, now we need to deploy the docker images to the EC2 instances.

From the application folder, three-tier-web-app

build the containers images

```docker build -t quotes-db ./db```
```docker build -t quotes-api ./api```
```docker build -t quotes-frontend ./app```


log in to ECR using AWS CLI. 


```aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com```

retag the images

```docker tag quotes-db:latest <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-db:latest```
```docker tag quotes-api:latest <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-api:latest```
```docker tag quotes-frontend:latest <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-frontend:latest```


push the images to ECR

```docker push <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-api:latest```
```docker push <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-frontend:latest```


now in EC2 instaces, pull the images and run the containers

```docker pull <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-api:latest```
```docker pull <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-frontend:latest```

Start the containers using
```docker compose up -d```

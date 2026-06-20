# End-to-End devops project

This assignment will be focusing on DevOps tools, tools we are going to use in this assignment are 
1. IaC -Terraform
2. CI/CD - Github Actions
3. Observability - Grafana, prometheus

The application is a simple three-tier web application consisting of a database (postgres), an API (flask), and a frontend (flask) took from a public repository. I have changed the application docker setup and other for production deployment.

Application repository : https://github.com/pdichone/docker-course-three-tier-web-app.git

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
The EC2 instance is connected to the public subnets.
The RDS instance is connected to the private subnets.

### Infrastucture configuration steps
Clone the repo 

```git clone https://github.com/Yashwanth-tss/8bytes.git```

```cd 8bytes``` <br>
```terraform init``` <br>
```terraform plan``` <br>
```terraform apply -var="aws_region=ap-south-1" -var="db_username=your_username" -var="db_password=your_password" -var="db_name=your_db_name" -var="app_port=80" -var="my_ip=[IP_ADDRESS]"```

The infra is provisioned, now we need to deploy the docker images to the EC2 instance.

From the application folder, three-tier-web-app

#### Build the containers images

```docker build -t quotes-db ./db``` <br>

```docker build -t quotes-api ./api``` <br>

```docker build -t quotes-frontend ./app``` <br>


#### Log in to ECR using AWS CLI. 

```aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com```

#### Retag the images

```docker tag quotes-db:latest <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-db:latest``` <br>
```docker tag quotes-api:latest <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-api:latest``` <br>
```docker tag quotes-frontend:latest <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-frontend:latest```


#### push the images to ECR

```docker push <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-api:latest``` <br>
```docker push <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-frontend:latest```


now in EC2 instaces, pull the images and run the containers

```docker pull <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-api:latest``` <br>
```docker pull <your-ecr-account-id>.dkr.ecr.your-region.amazonaws.com/quotes-frontend:latest``` <br>

Before starting the application intilize the database using 
```PGPASSWORD='your_password' psql -h <your-rds-endpoint> -U <your-db-username> -d <your-db-name> -f three-tier-web-app/db/init.sql```

Configure the environment variables similar to `.env.example` file 

###### Start the containers using
```docker compose -f docker-compose-prod.yml up -d```

## CI/CD Pipeline
Deployment process has been automated using github actions.
Why github actions? Github provides 2000 minutes of free build minutes per month. Also, no need to maintain server as it is a managed service. 

The pipeline is consisting of 3 jobs
1. Run tests  
2. Build and Push to ECR
3. Deploy to Staging EC2 via SSH

###### Run tests

This is lint and test stage for validating the code and dependencies. I have added dummy unit tests for this application. In real world, this stage will be used to run the unit tests and integration tests for the application. Example, if using node - npm run test; npm run lint. 

Trigger : When new PR is <b>raised</b> to main. <br>
File : test.yml

###### Build and Push to ECR
This pipeline will have the job to checkout to the latest branch, build the docker images, scan the images using trivy for vulnerability and push to ECR only if passes the scan. 

Trigger : When new PR is <b>merged</b> to main. <br>
File : deploy.yml <br>
Job name : build-and-push

###### Deploy to Staging EC2 via SSH
Once the images are pushed, it will proceed the deploy job, which will login to the staging EC2 instance using SSH and deploy the application. 

File : deploy.yml <br>
Job name : deploy-staging 

###### Deploy to production EC2
TO reduce the provisioning of extra infrastructure, I have created a manual intervention job assuming to be deploying in production environment similar to our staging. This will be triggered by manual approval from any of environment reviewers. 

File : deploy.yml <br>
Job name : deploy-production


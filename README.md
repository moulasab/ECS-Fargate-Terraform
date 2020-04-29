# ecs-fargate
ECS Fargate is AWS managed container service, we can easily setup and run our services in container and we can not ssh in ECS container directly.

Terraform script to setup ECS Fargate(Serverless) 
1) Create Serverless application with end to end
2) Create Applicaiton Load Balancer, Target Groups, Listeners 
3) Create ECR repo 
4) Create ECS Cluster, Service and Taks Definition and point all traffic should redirect through ALB

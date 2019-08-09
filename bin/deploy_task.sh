#!/bin/bash

source ./bashrc.ext

#Retrieve ECR_IMAGE_VERSION from CI/CD pipiline.
if [ -z "$1" ] ; then
    echo "Please input image version as per pipeline."
    exit 1
fi
echo ECR_IMAGE_VERSION=$1 > tmp.env

#Retrieve BASE_VPC_ID/ECS_POLICY_ARN / LOAD_BALANCING_ARN (ecs nodes) from previous CF
aws cloudformation --region $AWS_REGION describe-stacks \
  --stack-name $BASE_STACK_NAME \
  --query 'Stacks[0].Outputs[?OutputKey==`baseVpc`].OutputValue' \
  --output text |awk '{print "BASE_VPC_ID="$0}' >> tmp.env

aws cloudformation --region $AWS_REGION describe-stacks \
  --stack-name $BASE_STACK_NAME \
  --query 'Stacks[0].Outputs[?OutputKey==`ecsRole`].OutputValue' \
  --output text |awk '{print "ECS_ROLE_NAME="$0}' >> tmp.env

aws cloudformation --region $AWS_REGION describe-stacks \
  --stack-name $ECS_STACK_NAME \
  --query 'Stacks[0].Outputs[?OutputKey==`appElasticLoadBalancing`].OutputValue' \
  --output text |awk '{print "LOAD_BALANCING_ARN="$0}' >> tmp.env

source ./tmp.env


echo "Deploying application into ECS ..."
aws cloudformation --region $AWS_REGION describe-stacks --stack-name $DEPLOY_STACK_NAME
isExist=$?

if [ $isExist -ne 0 ]
then

  # aws cloudformation describe-stacks --stack-name $DEPLOY_STACK_NAME \
  #   --query 'Stacks[0].Outputs[?OutputKey==`DbUrl`].OutputValue' --output text


  echo "Createing new stack -> $DEPLOY_STACK_NAME"
  aws cloudformation --region $AWS_REGION create-stack --stack-name $DEPLOY_STACK_NAME \
    --template-url `aws s3 presign s3://$BUCKET_NAME/ecs/task-deploy.yaml`  \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameters \
    ParameterKey=baseVpc,ParameterValue=$BASE_VPC_ID \
    ParameterKey=ecsCluster,ParameterValue=$ECS_CLUSTER_NAME \
    ParameterKey=serviceName,ParameterValue=$ECS_SERVICE_NAME \
    ParameterKey=imageVersion,ParameterValue=$ECR_IMAGE_VERSION \
    ParameterKey=logRetentionDays,ParameterValue=3653 \
    ParameterKey=ecrRepo,ParameterValue=$ECR_REPO_NAME \
    ParameterKey=appElasticLoadBalancing,ParameterValue=$LOAD_BALANCING_ARN \
    ParameterKey=ecsRole,ParameterValue=$ECS_ROLE_NAME

  isExist=$?

  if [ $isExist -eq 0 ]
  then
    aws cloudformation --region $AWS_REGION wait stack-create-complete --stack-name $DEPLOY_STACK_NAME
    isExist=$?
  fi

else

  echo "Updating new stack -> $DEPLOY_STACK_NAME"
  aws cloudformation --region $AWS_REGION update-stack --stack-name $DEPLOY_STACK_NAME \
    --template-url `aws s3 presign s3://$BUCKET_NAME/ecs/task-deploy.yaml`  \
    --parameters \
    ParameterKey=baseVpc,ParameterValue=$BASE_VPC_ID \
    ParameterKey=ecsCluster,ParameterValue=$ECS_CLUSTER_NAME \
    ParameterKey=serviceName,ParameterValue=$ECS_SERVICE_NAME \
    ParameterKey=imageVersion,ParameterValue=$ECR_IMAGE_VERSION \
    ParameterKey=logRetentionDays,ParameterValue=3653 \
    ParameterKey=ecrRepo,ParameterValue=$ECR_REPO_NAME \
    ParameterKey=appElasticLoadBalancing,ParameterValue=$LOAD_BALANCING_ARN \
    ParameterKey=ecsRole,ParameterValue=$ECS_ROLE_NAME

  isExist=$?

  if [ $isExist -eq 0 ]
  then
    aws cloudformation --region $AWS_REGION wait stack-update-complete --stack-name $DEPLOY_STACK_NAME
    isExist=$?
  fi

fi


#!/bin/bash

USE_SPOT=no
if [ $1 = "-spot" ] ; 
then
  USE_SPOT=yes
fi



source ./bashrc.ext

echo "Seting ECS  environment ..."
aws cloudformation --region $AWS_REGION describe-stacks --stack-name $ECS_STACK_NAME
isExist=$?

if [ $isExist -ne 0 ]
then

  echo "Createing new stack -> $ECS_STACK_NAME"
  aws cloudformation --region $AWS_REGION create-stack --stack-name $ECS_STACK_NAME \
    --template-url `aws s3 presign s3://$BUCKET_NAME/ecs/ecs-main.yaml`  \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameters \
    ParameterKey=baseStackName,ParameterValue=$BASE_STACK_NAME  \
    ParameterKey=instanceType,ParameterValue=$INSTANCE_TYPE_FOR_ECS \
    ParameterKey=keyPairName,ParameterValue=$KEY_PAIR \
    ParameterKey=s3cf,ParameterValue=$BUCKET_NAME \
    ParameterKey=s3Dns,ParameterValue=$BUCKET_ENDPOINT_DNS \
    ParameterKey=volSize,ParameterValue=$NODE_VOLUME_SIZE \
    ParameterKey=desiredCount,ParameterValue=$NODE_DESIRED_COUNT \
    ParameterKey=onDemandPercentage,ParameterValue=$ON_DEMAND_PERCENTAGE \
    ParameterKey=useSpot,ParameterValue=$USE_SPOT
  isExist=$?

  if [ $isExist -eq 0 ]
  then
    aws cloudformation --region $AWS_REGION wait stack-create-complete --stack-name $ECS_STACK_NAME
  fi

else

  echo "Updating new stack -> $ECS_STACK_NAME"
  aws cloudformation --region $AWS_REGION update-stack --stack-name $ECS_STACK_NAME \
    --template-url `aws s3 presign s3://$BUCKET_NAME/ecs/ecs-main.yaml`  \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameters \
    ParameterKey=baseStackName,ParameterValue=$BASE_STACK_NAME  \
    ParameterKey=instanceType,ParameterValue=$INSTANCE_TYPE_FOR_ECS \
    ParameterKey=keyPairName,ParameterValue=$KEY_PAIR \
    ParameterKey=s3cf,ParameterValue=$BUCKET_NAME \
    ParameterKey=s3Dns,ParameterValue=$BUCKET_ENDPOINT_DNS \
    ParameterKey=volSize,ParameterValue=$NODE_VOLUME_SIZE \
    ParameterKey=desiredCount,ParameterValue=$NODE_DESIRED_COUNT \
    ParameterKey=onDemandPercentage,ParameterValue=$ON_DEMAND_PERCENTAGE \
    ParameterKey=useSpot,ParameterValue=$USE_SPOT
  isExist=$?

  if [ $isExist -eq 0 ]
  then
    aws cloudformation --region $AWS_REGION wait stack-update-complete --stack-name $ECS_STACK_NAME
  fi

fi
echo "Done"

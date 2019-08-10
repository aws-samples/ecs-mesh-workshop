#!/bin/bash
set -xe

USE_SPOT=no
if [ $1 = "spot" ]
then
  USE_SPOT=yes
  echo "Using spot & on-demand instance with mixed type as ECS worker nodes."
else 
  echo "Using on-demand instance as ECS worker nodes."
fi


echo "Initial ECS environments ..."
source ./bashrc.ext


isExist=`aws cloudformation --region $AWS_REGION describe-stacks --stack-name $ECS_STACK_NAME|jq .Stacks[].StackId`

if [ "$isExist" == "" ]
then
  echo "Createing new stack -> $ECS_STACK_NAME"
else
  echo "Updating existing stack -> $ECS_STACK_NAME"
fi

aws cloudformation --region $AWS_REGION deploy --stack-name $ECS_STACK_NAME \
  --template-file $WORKSHOP_HOME/templates/ecs/ecs-main.yaml  \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --parameter-overrides \
  baseStackName=$BASE_STACK_NAME  \
  instanceType=$INSTANCE_TYPE_FOR_ECS \
  keyPairName=$KEY_PAIR \
  s3cf=$BUCKET_NAME \
  useSpot=$USE_SPOT \
  volSize=$NODE_VOLUME_SIZE \
  cpuTargetValue=$CPU_TARGET_VALUE \
  desiredCount=$NODE_DESIRED_COUNT \
  onDemandPercentage=$ON_DEMAND_PERCENTAGE
  
echo "Done"

#!/bin/bash
set -xe

echo "Initial infrastructure environment ..."
source ./bashrc.ext

echo "Uploading templates to S3 bucket..."
! aws s3api create-bucket --bucket $BUCKET_NAME \
      --region $AWS_REGION \
      --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3 cp $WORKSHOP_HOME/templates s3://$BUCKET_NAME/templates/ --recursive

isExist=`aws cloudformation --region $AWS_REGION describe-stacks --stack-name $BASE_STACK_NAME|jq .Stacks[].StackId`

if [ "$isExist" == "" ]
then
  echo "Createing new stack -> $BASE_STACK_NAME"
else
  echo "Updating exiting stack -> $BASE_STACK_NAME"
fi

aws cloudformation --region $AWS_REGION deploy --stack-name $BASE_STACK_NAME \
  --template-file $WORKSHOP_HOME/templates/infra/main.yaml  \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --parameter-overrides \
  keyPairName=$KEY_PAIR \
  s3cf=$BUCKET_NAME \
  --tags Name=ECS-MESH-WORKSHOP

echo "Done"

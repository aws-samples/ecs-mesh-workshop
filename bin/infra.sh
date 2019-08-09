#!/bin/bash

source ./bashrc.ext

echo "Seting infrastructure environment ..."
aws cloudformation --region $AWS_REGION describe-stacks --stack-name $BASE_STACK_NAME
isExist=$?

if [ $isExist -ne 0 ]
then

  echo "Createing new stack -> $BASE_STACK_NAME"
  aws cloudformation --region $AWS_REGION create-stack --stack-name $BASE_STACK_NAME \
    --template-url `aws s3 presign s3://$BUCKET_NAME/infra/main.yaml`  \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameters \
    ParameterKey=keyPairName,ParameterValue=$KEY_PAIR \
    ParameterKey=s3cf,ParameterValue=$BUCKET_NAME \
    ParameterKey=s3Dns,ParameterValue=$BUCKET_ENDPOINT_DNS
  isExist=$?

  if [ $isExist -eq 0 ]
  then
    aws cloudformation --region $AWS_REGION wait stack-create-complete --stack-name $BASE_STACK_NAME
  fi

else

  echo "Updating new stack -> $BASE_STACK_NAME"
  aws cloudformation --region $AWS_REGION update-stack --stack-name $BASE_STACK_NAME \
    --template-url `aws s3 presign s3://$BUCKET_NAME/infra/main.yaml`  \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameters \
    ParameterKey=keyPairName,ParameterValue=$KEY_PAIR \
    ParameterKey=s3cf,ParameterValue=$BUCKET_NAME \
    ParameterKey=s3Dns,ParameterValue=$BUCKET_ENDPOINT_DNS
  isExist=$?

  if [ $isExist -eq 0 ]
  then
    aws cloudformation --region $AWS_REGION wait stack-update-complete --stack-name $BASE_STACK_NAME
  fi

fi
echo "Done"

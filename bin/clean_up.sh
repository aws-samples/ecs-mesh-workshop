#!/bin/bash
echo "Initial environment......"
source ./bashrc.ext
echo "Done"

echo "Delete stack... $ECS_STACK_NAME ..."
aws cloudformation delete-stack --stack-name $ECS_STACK_NAME
aws cloudformation wait stack-delete-complete --stack-name $ECS_STACK_NAME
echo "Done"

echo "Delete stack... $BASE_STACK_NAME ..."
aws cloudformation delete-stack --stack-name $BASE_STACK_NAME
aws cloudformation wait stack-delete-complete --stack-name $ECS_STACK_NAME
echo "Done"
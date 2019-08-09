#!/bin/bash

source ./bashrc.ext


repo=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME/$ECS_SERVICE_NAME

echo "Pushing image into ECR -> $repo"

$(aws ecr get-login --no-include-email --region $AWS_REGION)
docker tag $ECS_SERVICE_NAME:latest $repo:$ECR_IMAGE_VERSION
docker push $repo:$ECR_IMAGE_VERSION

echo "Done"

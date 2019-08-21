# Configure Fluent Bit 

Using official Fluent Bit image from Docker Hub and adding new config files to build a new image. Push image into ECR for futher use.


## Configure Fluent Bit

```bash

# modify fluent-bit.conf
vi fluent-bit.conf

```

## Prepare docker image

```bash

# build image
docker build -t fluent-bit .

# push image to ECR
$(aws ecr get-login --no-include-email --region $AWS_REGION)
docker tag fluent-bit:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com.cn/fluent-bit:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com.cn/fluent-bit:latest

```
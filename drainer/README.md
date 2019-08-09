# Drainer for Spot Instance

Deploy drianer as deamon into cluster and monitor termination notice, modify status of container instance accordingly.

```bash

export AWS_REGION=
export ECS_STACK_NAME=
export ECS_CLUSTER_NAME=


aws cloudformation --region $AWS_REGION \
    deploy --stack-name $ECS_STACK_NAME \
    --template-file ./drainer-task.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM


aws ecs create-service --cluster $ECS_CLUSTER_NAME \
    --service-name spot-checker \
    --task-definition spot-checker  \
    --scheduling-strategy DAEMON


```

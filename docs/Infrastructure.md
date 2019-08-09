# Setup infrastructure layer & standup ECS

## Prerequisite

- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) with latest version.
- [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) AWS CLI with right permission.

## Deployment

### 1. Prepare enviroment

```bash
# setup variables
cd ./bin;vi ./bashrc.ext

# quick deployment
./install_all.sh

# quick deployment with on-demand & spot instance (1:3)
./install_all.sh -spot

```

### 2. Linkerd & Consul Dashboard

Choose linkerd-viz-node and forward traffic on three local ports to
three remote ports on the EC2 host:

- Traffic to `localhost:9990` will go to the Linkerd dashboard on the remote
  host
- Traffic to `localhost:8500` will go to the Consul admin dashboard on the
  remote host
- Traffic to `localhost:4140` will go to the Linkerd HTTP proxy on the remote
  host

```bash
# Select an ECS node
ECS_NODE=$( \
  aws ec2 describe-instances \
    --filters Name=instance-state-name,Values=running Name=tag:Name,Values=*linkerdviz-node  \
    --query 'Reservations[0].Instances[0].PublicDnsName' \
    --output text \
)

ssh -i "$KEY_PAIR" \
    -L 127.0.0.1:4140:$ECS_NODE:4140 \
    -L 127.0.0.1:9990:$ECS_NODE:9990 \
    -L 127.0.0.1:8500:$ECS_NODE:8500 ec2-user@$ECS_NODE -N

# view linkerd dashboard (osx)
open http://localhost:9990

# view Consul (osx)
open http://localhost:8500

```

### 3. Install example applications into ECS

```bash
# build example applications
cd ./example/todo/front
docker build .
cd ./example/todo/store
docker build .

# push images to ECR
.

# register example applications
cd ./ecs
#aws ecs register-task-definition --cli-input-json file://example-front-task-definition.json
#aws ecs register-task-definition --cli-input-json file://example-store-task-definition.json
aws ecs register-task-definition --cli-input-json file://hello-world-task-definition.json

```

### 4. Test dynamic request routing

Lets use the tunnel to send some requests to the `helloworld` service via the
Linkerd HTTP proxy:

```bash
# test routing via Linkerd
http_proxy=localhost:4140 curl hello
```

You will see these requests reflected in the Linkerd dashboard. The request flow
we just tested:

`curl` -> `linkerd` -> `hello` -> `linkerd` -> `world`

As our `hello-world` task also included a `world-v2` service, let's test
per-request routing:

```bash
http_proxy=localhost:4140 curl -H 'l5d-dtab: /svc/world => /svc/world-v2' hello
```

By setting the `l5d-dtab` header, we instructed Linkerd to dynamically route all
requests destined for `world` to `world-v2`.

### 5. Monitoring wih Grafana & Prometheus through Linkerd

```bash
# register task & run
cd ./ecs
aws ecs register-task-definition --cli-input-json file://linkerd-viz-task-definition.json
aws ecs run-task --cluster $ECS_CLUSTER_NAME --task-definition linkerd-viz --count 1

# find the ECS node running linkerd-viz
TASK_ID=$(  \
    aws ecs list-tasks --cluster $ECS_CLUSTER_NAME \
        --family linkerd-viz --desired-status RUNNING \
        --query taskArns[0] --output text
)
CONTAINER_INSTANCE=$(   \
    aws ecs describe-tasks --cluster $ECS_CLUSTER_NAME \
        --tasks $TASK_ID --query tasks[0].containerInstanceArn \
        --output text
)
INSTANCE_ID=$(  \
    aws ecs describe-container-instances --cluster $ECS_CLUSTER_NAME \
        --container-instances $CONTAINER_INSTANCE \
        --query containerInstances[0].ec2InstanceId \
        --output text
)
VIZ_NODE=$( \
    aws ec2 describe-instances --instance-ids $INSTANCE_ID \
        --query Reservations[*].Instances[0].PublicDnsName \
        --output text
)

ssh -i "$KEY_PAIR" -L 127.0.0.1:3000:$VIZ_NODE:3000 ec2-user@$VIZ_NODE -N

# view linkerd-viz (osx)
open http://localhost:3000

```

### 6. Install drianer to minitor spot instance termination

## TODO

- [x] Scripts to build, run and linkerd configuration for todo applicaiton.
- [x] Add daemon service to drain tasks when spot instance receive termination notice.
- [ ] Persistent volume with self-awareness binding. (https://github.com/rexray/rexray)

## Note

### 1. Tested Region

- ZHY (Ningxia Region of China)
- BJS (Beijing Region of China)

### 2. Update ECS Agent

```bash

#update ecs-agent
sudo yum update -y
sudo yum update ecs-init -y
sudo systemctl restart docker

#Run following commands if ecs agent didn't update
aws ecs --region $AWS_REGION list-container-instances --cluster $ECS_CLUSTER_NAME

# {
#     "containerInstanceArns": [
#         "arn:aws-cn:ecs:cn-northwest-1:455538790878:container-instance/0693fc7c-9f2d-4732-993f-1dcc66614815"
#     ]
# }
# "0693fc7c-9f2d-4732-993f-1dcc66614815" - container-instance

aws ecs --region $AWS_REGION update-container-agent --cluster $ECS_CLUSTER_NAME --container-instance $CONTAINER_INSTANCE

```

## Resources

For more information about ECS developer guide, see the
[Developer Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html).

For more information about ECS task placement, see the
[Amazon ECS Task Placement](https://aws.amazon.com/blogs/compute/amazon-ecs-task-placement/).

For more information about configuring Linkerd, see the
[Linkerd Configuration](https://api.linkerd.io/latest/linkerd) page.

For more information about linkerd-viz, see the
[linkerd-viz GitHub repo](https://github.com/linkerd/linkerd-viz).

For more information about CloudFormation, see the
[User Guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html).


## License Summary

The documentation is made available under the Creative Commons Attribution-ShareAlike 4.0 International License. See the LICENSE file.

The sample code within this documentation is made available under the MIT-0 license. See the LICENSE-SAMPLECODE file.


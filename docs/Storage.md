# Storage

When using Docker Volumes, the built-in local diver or a third-party dirver can be used.Docker volumes are managed by Docker and a directory is created in /var/lib/docker/volumes on the container instance that contains the volume data.

We're focusing on built-in local dirver and third-party driver to setup data volume for in task. If you want to use bind mounts, [here's more](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/bind-mounts.html)

## Playbook

### 1. Prepare enviroment

> Note: You can ignore this step if you finished previous module - [Using spot instance as worker nodes](./Spot4Worker.md) without clean-up!!!

```bash

# setup variables
cd ecs-mesh-workshop/bin;
# modify environments in ./bashrc.ext
source ./bashrc.ext

# quick deployment, setup infrastructure & standup ECS cluster with on-demand instance
./install_all.sh spot

```

### 2. Local driver
A directory is created in /var/lib/docker/volumes on the container instance that contains the volume data.

```bash
cd ecs-mesh-workshop/template/storage

# create a volume on worker node.
docker run -ti --volume-driver=local -v test-local:/test-local busybox
df -h /test-local

# check out folder /var/lib/docker/volumes
ls /var/lib/docker/volumes

```


### 3. REX-Ray

Creat a policy and attach to instnace role of worker nodes.

```bash
cd ecs-mesh-workshop/template/storage

aws iam create-policy --policy-name rexray-ecs-policy --policy-document file://rexray-iam-policy.json

```

Register task to test local volume.

```bash

aws ecs register-task-definition --cli-input-json file://mysql-local-task-definition.json
aws ecs run-task --cluster $ECS_CLUSTER_NAME --task-definition mysql-local --count 1

```

Install Rex-Ray driver on each worker nodes.

```bash

# list public IP addresses in order to login and install dirver
aws ec2 describe-instances --filters "Name=tag:Owner,Values=CC,Name=availability-zone,Values=us-west-2b"| jq '.Reservations[].Instances[].PublicIpAddress'

# install rexray dirver
docker plugin install rexray/ebs REXRAY_PREEMPT=true EBS_REGION=$AWS_REGION --grant-all-permissions

# if driver is not active and then restart the container agent
sudo systemctl restart ecs

# check it out after install
docker plugin ls
docker run -ti --volume-driver=rexray/ebs -v test-rexray:/test-rexray busybox
df -h /test

# Check out EBS volume
aws ec2 describe-volumes --filters "Name=tag:Name,Values=test-rexray"

```

Register task to test volume by REX-Ray.

```bash

aws ecs register-task-definition --cli-input-json file://mysql-rexray-task-definition.json
aws ecs run-task --cluster $ECS_CLUSTER_NAME --task-definition mysql-rexray --count 1

```


With REX-Ray, it's also work with other storages, such as EFS and S3, check out [here](https://github.com/rexray/rexray/blob/master/.docs/user-guide/storage-providers/aws.md).



### 6. Clean-up

```bash

# delete all stacks in CloudFormation
cd ecs-mesh-workshop/bin
./clean_up.sh

# manually delete EBS volume
aws ec2 describe-volumes --filters "Name=tag:Name,Values=test-rexray"
aws ec2 delete-volume --volume-id <VolumeId>
aws ec2 describe-volumes --filters "Name=tag:Name,Values=rexray-vol"
aws ec2 delete-volume --volume-id <VolumeId>

```


## Resources
[Using data volumes in Task](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_data_volumes.html)

[REX-Ray](https://github.com/rexray/rexray)

[REX-Ray for EBS](https://amazonaws-china.com/blogs/compute/amazon-ecs-and-docker-volume-drivers-amazon-ebs/)

[REX-Ray for EFS](https://amazonaws-china.com/blogs/compute/amazon-ecs-and-docker-volume-drivers-amazon-efs/)

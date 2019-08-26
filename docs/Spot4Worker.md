
# Using spot instance as worker nodes

## Prerequisite

- Install [jq](https://stedolan.github.io/jq/) and [git](https://git-scm.com/downloads).
- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) with latest version.
- [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) AWS CLI with right permission.

## Playbook

### 1. Prepare enviroment

```bash

# setup variables
cd ecs-mesh-workshop/bin;
# modify environments in ./bashrc.ext
source ./bashrc.ext

# quick deployment, setup infrastructure & standup ECS cluster with on-demand instance
./install_all.sh spot

```

### 2. Observe information of relevant instances

```bash

# using aws-cli / ec2 console: 3 spot + 1 normal 
aws ec2 describe-instances \
    --filters Name=instance-state-name,Values=running Name=tag:Member,Values=appserver-of-AutoScalingGroup  \
    --output json \
    | jq '.Reservations[].Instances[].LaunchTime, .Reservations[].Instances[].InstanceLifecycle, .Reservations[].Instances[].InstanceType' \
    | paste - - - -

```

### 3. Terminate spot instance and watch logs

Watch logs form CloudWatch under ECS cluster, which created in previous step, such as {aws_stack_name}/ec2/autoscaling/var/log/docker -> {cluster}/{container_instance_id}.

```bash

# execute following command to terminate instance with right id
aws ec2 terminate-instances --instance-ids <instance_id>

```

### 4. Terminate on-demand instance and watch logs

Watch logs form CloudWatch under ECS cluster, which created in previous step, such as {aws_stack_name}/ec2/autoscaling/var/log/docker -> {cluster}/{container_instance_id}

```bash

# execute following command to terminate instance with right id
aws ec2 terminate-instances --instance-ids <instance_id>

```


### 5. Clean-up

> Note: Don't execute 'clean_up.sh' to remove all esources if you'd like to continue the workshop, so you'll spend less time to waiting provsion resources!!! 

```bash

# delete all stacks in CloudFormation
cd ecs-mesh-workshop/bin
./clean_up.sh


```


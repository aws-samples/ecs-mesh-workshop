# Using on-demand instance as worker nodes

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
./install_all.sh

```

### 2. Observe information of relevant instances 

```bash

# using aws-cli / ec2 console: 4 normal 
aws ec2 describe-instances \
    --filters Name=instance-state-name,Values=running Name=tag:Member,Values=appserver-of-AutoScalingGroup  \
    --output json \
    | jq '.Reservations[].Instances[].LaunchTime, .Reservations[].Instances[].InstanceLifecycle, .Reservations[].Instances[].InstanceType' \
    | paste - - - -

```

### 3. Clean-up

```bash

# delete all stacks in CloudFormation
cd ecs-mesh-workshop/bin
./clean_up.sh


```

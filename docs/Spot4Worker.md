
# Using spot instance as worker nodes

## Prerequisite

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

### 2. Observe releavant instance infroamtion

### 3. Terminate spot instance and watch logs

### 4. Terminate on-demand instance and watch logs

### 5. Clean-up

```bash
# delete stacks in CloudFormation

```

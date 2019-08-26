# Centralized log solution with Fluent Bit & Elasticsearch


## Prerequisite

- Install [jq](https://stedolan.github.io/jq/) and [git](https://git-scm.com/downloads).
- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) with latest version.
- [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) AWS CLI with right permission.

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

### 2. Install Fluent Bit

### 3. Launch Elasticseach service on AWS



-> https://fluentbit.io/articles/docker-logging-elasticsearch/

fluent.sock

https://aws.amazon.com/about-aws/whats-new/2019/07/aws-container-services-launches-aws-for-fluent-bit/
https://aws.amazon.com/blogs/opensource/centralized-container-logging-fluent-bit/

# ECS Mesh Workshop

<img src="./docs/images/ecs-gopher.png" width="240"/>

This quick start solution is designed to easily launch ECS with various powerful features, such as spot fleet, auto scaling with mixed fleet, service mesh, monitoring tools, and more. Linkerd, Prometheus, and Grafana as major components are integrated ECS in this solution but you can use your favorite.

It'll be Keep iterating and added more tutorials and guides from time to time.

## Tutorial

### 1. [Setup infrastructure layer and stand up ECS](./docs/Infrastructure.md)

### 2. [Using on-demand instance as worker nodes](./docs/Ondemand4Worker.md)

### 3. [Using spot instance as worker nodes](./docs/Spot4Worker.md)

### 4. [Using third party solution for service mesh and monitoring](./docs/ServiceMesh.md)

### 5. Manage persistent volumn with different storages

### 6. Centralized log solution with Fluent Bit

### 7. Integrate CI/CD with ECS cluster

## Tips

> 1. Using ECS optimized AMI for worker node, which include recommended Docker runtime & ECS agent. In addtion, you should install SSM agent in order to simplify future management.
>
> 2. Using spot instance to optimizing cost, spot instance can be integrate with auto scaling group to suppot mission critical needs. You can setup specific need rate between on-demand instnace and spot instance, so that you always have available capacity to handle business operation.
>
> 3. Using service mesh to improve observbility.

## Todo

- [ ] 5. Manage persistent volumn with different storages
- [ ] 6. Centralized log solution with Fluent Bit
- [ ] 7. Integrate CI/CD with ECS cluster

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


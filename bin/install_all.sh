#!/bin/bash

echo "Initial environment......"
source ./bashrc.ext
echo "Done"

echo "Setup infrastructure layer......"
./infra.sh

echo "Setup ECS cluster......"
./ecs.sh $1
#!/bin/bash

echo "Initial environment......"
source ./bashrc.ext
echo "Done"

echo "Setup infrastructure layer......"
./infra.sh

if [ $? -ne 0 ]
then
    echo "Setup infrastructure layer was failed and exit building process."
    exit 0
fi 

echo "Setup ECS cluster......"
./ecs.sh $1

if [ $? -ne 0 ]
then
    echo "Setup ECS cluster was failed and check out logs/console."
fi 
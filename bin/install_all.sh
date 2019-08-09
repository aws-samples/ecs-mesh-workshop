#!/bin/bash

source ./bashrc.ext

cd bin
./infra.sh

cd bin
./ecs.sh $1
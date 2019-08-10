#!/bin/bash

source ./bashrc.ext

echo "BUCKET_NAME -> $BUCKET_NAME"

echo "Uploading CloudFormation template & scripts to S3 -> $BUCKET_NAME ..."
aws s3 cp `pwd`/.. s3://$BUCKET_NAME/ --recursive
echo "Done."

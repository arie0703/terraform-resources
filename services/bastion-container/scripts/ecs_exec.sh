#!/bin/bash

TASK_ID=$1
AWS_REGION=ap-northeast-1

aws ecs execute-command \
  --cluster bastion-cluster \
  --region ${AWS_REGION} \
  --task ${TASK_ID} \
  --container bastion \
  --interactive \
  --command "/bin/bash"

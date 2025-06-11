schemaVersion: '0.3'
description: 'Stop ECS Tasks'
parameters:
  ClusterArn:
    type: String
    description: 'ECS Cluster ARN'
    default: '${aws_ecs_cluster.arn}'
  ServiceName:
    type: String
    description: 'ECS Service Name'
    default: '${aws_ecs_service.name}'

mainSteps:
  - name: UpdateService
    action: 'aws:executeAwsApi'
    maxAttempts: 3
    onFailure: 'Continue'
    inputs:
      Service: ecs
      Api: UpdateService
      cluster: '{{ ClusterArn }}'
      service: '{{ ServiceName }}'
      desiredCount: 0
      forceNewDeployment: false

  - name: DescribeService
    action: 'aws:executeAwsApi'
    inputs:
      Service: ecs
      Api: DescribeServices
      cluster: '{{ ClusterArn }}'
      services:
        - '{{ ServiceName }}'
    isEnd: true 

# smsk-kafka-load

Leverages apache-kafka bin utils folder to run commands on a kafka cluster. This can be utilitzed to (not limited)

1. Generate load to a topicin a kafka cluster (kafka-producer-perf-test.sh)
2. Run a console consumer group on a topic in a kafka cluster


# Pre-reqs

## Create an ECR repo smsk-bulrush-test

$ aws-okta exec ops-write -- aws ecr create-repository --repository-name=smsk-kafka-load


## Add permissions to ecr repo

$ aws-okta exec ops-write -- aws ecr set-repository-policy \
  --registry-id="528451384384" \
  --repository-name=smsk-kafka-load \
  --policy-text='{"Version": "2008-10-17", "Statement": [{"Action": ["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:BatchCheckLayerAvailability", "ecr:DescribeImages"], "Principal": "*", "Effect": "Allow", "Condition": {"ForAnyValue:StringLike": {"aws:PrincipalOrgPaths": "o-wb8ewg4hzk/*"}}, "Sid": "AllowOrganization"}]}'

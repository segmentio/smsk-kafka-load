# smsk-kafka-load


## Pre-req checks

### log in to docker
$ aws-okta exec ops-read -- aws ecr get-login-password | docker login --username AWS --password-stdin 528451384384.dkr.ecr.us-west-2.amazonaws.com

### Create an ecr repo

$ aws-okta exec ops-write -- aws ecr create-repository --repository-name=smsk-kafka-load

### Add permissions to ecr repo

$ aws-okta exec ops-write -- aws ecr set-repository-policy \
  --registry-id="528451384384" \
  --repository-name=smsk-kafka-load \
  --policy-text='{"Version": "2008-10-17", "Statement": [{"Action": ["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:BatchCheckLayerAvailability", "ecr:DescribeImages"], "Principal": "*", "Effect": "Allow", "Condition": {"ForAnyValue:StringLike": {"aws:PrincipalOrgPaths": "o-wb8ewg4hzk/*"}}, "Sid": "AllowOrganization"}]}'


## Docker build Local

docker build -t smsk-kafka-load:v2.5.1 .


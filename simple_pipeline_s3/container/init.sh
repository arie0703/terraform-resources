docker build -t cicd-sandbox-ecr . --platform amd64
docker tag cicd-sandbox-ecr:latest ${REPOSITORY_URI}:latest
docker push ${REPOSITORY_URI}:latest

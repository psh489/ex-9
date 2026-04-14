#!/bin/bash
REGION="ap-south-1"
ACCOUNT_ID="458894893383"
S3_BUCKET="pwotc.cloud"
ECR_REPO="st6-githb-ecr"
IMAGE_TAG="v2"
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_URI="${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}"

exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "--- Deployment Started ---"

# 1. 깔끔하게 정리
rm -rf /home/ec2-user/nginx
mkdir -p /home/ec2-user/nginx/html

# 2. S3에서 정적 파일만 가져오기
aws s3 sync s3://${S3_BUCKET}/html/ /home/ec2-user/nginx/html --delete

# 3. ECR 로그인 및 이미지 준비
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URL}
docker pull ${IMAGE_URI}

# 4. 기존 컨테이너 정리
docker stop nginx-container || true
docker rm -f nginx-container || true

# 5. 컨테이너 실행 (conf.d 마운트 제거)
docker run -d --name nginx-container -p 80:80 \
-v /home/ec2-user/nginx/html:/usr/share/nginx/html \
${IMAGE_URI}

echo "--- Deployment Finished ---"

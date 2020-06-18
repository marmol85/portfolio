#!/usr/bin/env bash

set -eu

STAGE="${1:-dev}"
echo "Deploying static assets to ${STAGE}..."

BUCKET_NAME=$(aws \
    cloudformation describe-stacks \
    --stack-name "danielhollcraft-${STAGE}" \
    --query "Stacks[0].Outputs[?OutputKey=='WebSiteBucket'] | [0].OutputValue" \
    --output text)

WEBSITE_URL=$(aws \
    cloudformation describe-stacks \
    --stack-name "danielhollcraft-${STAGE}" \
    --query "Stacks[0].Outputs[?OutputKey=='WebSiteUrl'] | [0].OutputValue" \
    --output text)

#Deploy site content
aws s3 sync --acl 'public-read' --delete ui/public/ "s3://${BUCKET_NAME}/"

# Deploy sitemap and google webmaster tools verification
aws s3 sync --acl 'public-read' ui/deploy/google-webmaster-tools/ "s3://${BUCKET_NAME}/"

echo "Bucket URL: ${WEBSITE_URL}"

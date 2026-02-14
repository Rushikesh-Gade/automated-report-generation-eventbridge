#!/bin/bash

# AWS EventBridge Report Automation - Deployment Script
# This script automates the deployment of all resources

set -e

echo "🚀 Starting deployment of AWS EventBridge Report Automation..."

# Set environment variables
export AWS_REGION=$(aws configure get region)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Generate unique suffix
RANDOM_SUFFIX=$(openssl rand -hex 3)
export DATA_BUCKET="report-data-${RANDOM_SUFFIX}"
export REPORTS_BUCKET="report-output-${RANDOM_SUFFIX}"
export LAMBDA_FUNCTION="report-generator-${RANDOM_SUFFIX}"
export SCHEDULE_NAME="daily-reports-${RANDOM_SUFFIX}"

# Prompt for email
read -p "Enter your verified email address: " VERIFIED_EMAIL
export VERIFIED_EMAIL

echo "📋 Configuration:"
echo "  Region: ${AWS_REGION}"
echo "  Account: ${AWS_ACCOUNT_ID}"
echo "  Data Bucket: ${DATA_BUCKET}"
echo "  Reports Bucket: ${REPORTS_BUCKET}"
echo "  Lambda Function: ${LAMBDA_FUNCTION}"
echo "  Email: ${VERIFIED_EMAIL}"
echo ""

# Step 1: Create S3 Buckets
echo "📦 Step 1/7: Creating S3 buckets..."
aws s3 mb s3://${DATA_BUCKET} --region ${AWS_REGION}
aws s3 mb s3://${REPORTS_BUCKET} --region ${AWS_REGION}

aws s3api put-bucket-versioning --bucket ${DATA_BUCKET} --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket ${REPORTS_BUCKET} --versioning-configuration Status=Enabled
echo "✅ S3 buckets created"

# Step 2: Upload sample data
echo "📤 Step 2/7: Uploading sample data..."
aws s3 cp data/sample_sales.csv s3://${DATA_BUCKET}/sales/
aws s3 cp data/sample_inventory.csv s3://${DATA_BUCKET}/inventory/
echo "✅ Sample data uploaded"

# Step 3: Create Lambda IAM role
echo "🔐 Step 3/7: Creating Lambda IAM role..."
aws iam create-role \
    --role-name ReportGeneratorRole \
    --assume-role-policy-document file://iam/lambda-trust-policy.json

aws iam attach-role-policy \
    --role-name ReportGeneratorRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Update policy with actual bucket names
sed "s/report-data-mwkvgt/${DATA_BUCKET}/g; s/report-output-mwkvgt/${REPORTS_BUCKET}/g" \
    iam/lambda-permissions-policy.json > /tmp/lambda-permissions-policy.json

aws iam create-policy \
    --policy-name ReportGeneratorPolicy \
    --policy-document file:///tmp/lambda-permissions-policy.json

aws iam attach-role-policy \
    --role-name ReportGeneratorRole \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/ReportGeneratorPolicy

echo "✅ Lambda IAM role created"

# Step 4: Deploy Lambda function
echo "⚡ Step 4/7: Deploying Lambda function..."
sleep 10  # Wait for IAM role propagation

aws lambda create-function \
    --function-name ${LAMBDA_FUNCTION} \
    --runtime python3.12 \
    --role arn:aws:iam::${AWS_ACCOUNT_ID}:role/ReportGeneratorRole \
    --handler report_generator.lambda_handler \
    --zip-file fileb://lambda/function.zip \
    --timeout 300 \
    --memory-size 512 \
    --environment Variables="{DATA_BUCKET=${DATA_BUCKET},REPORTS_BUCKET=${REPORTS_BUCKET},EMAIL_ADDRESS=${VERIFIED_EMAIL}}"

echo "✅ Lambda function deployed"

# Step 5: Create EventBridge Scheduler IAM role
echo "🔐 Step 5/7: Creating EventBridge Scheduler IAM role..."
aws iam create-role \
    --role-name EventBridgeSchedulerRole \
    --assume-role-policy-document file://iam/scheduler-trust-policy.json

# Update policy with actual function name
sed "s/report-generator-mwkvgt/${LAMBDA_FUNCTION}/g; s/ap-south-1/${AWS_REGION}/g; s/936998755370/${AWS_ACCOUNT_ID}/g" \
    iam/scheduler-permissions-policy.json > /tmp/scheduler-permissions-policy.json

aws iam create-policy \
    --policy-name EventBridgeSchedulerPolicy \
    --policy-document file:///tmp/scheduler-permissions-policy.json

aws iam attach-role-policy \
    --role-name EventBridgeSchedulerRole \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/EventBridgeSchedulerPolicy

echo "✅ EventBridge Scheduler IAM role created"

# Step 6: Create EventBridge Schedule
echo "⏰ Step 6/7: Creating EventBridge schedule..."
aws scheduler create-schedule \
    --name ${SCHEDULE_NAME} \
    --schedule-expression "cron(0 9 * * ? *)" \
    --target "{\"Arn\":\"arn:aws:lambda:${AWS_REGION}:${AWS_ACCOUNT_ID}:function:${LAMBDA_FUNCTION}\",\"RoleArn\":\"arn:aws:iam::${AWS_ACCOUNT_ID}:role/EventBridgeSchedulerRole\"}" \
    --flexible-time-window "{\"Mode\":\"OFF\"}" \
    --description "Daily business report generation"

echo "✅ EventBridge schedule created"

# Step 7: Verify email in SES
echo "📧 Step 7/7: Verifying email in SES..."
aws ses verify-email-identity --email-address ${VERIFIED_EMAIL}
echo "✅ Email verification initiated"

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📧 IMPORTANT: Check your email (${VERIFIED_EMAIL}) and click the verification link from AWS SES"
echo ""
echo "🧪 To test the system:"
echo "  aws lambda invoke --function-name ${LAMBDA_FUNCTION} --payload '{}' response.json"
echo ""
echo "📊 To view reports:"
echo "  aws s3 ls s3://${REPORTS_BUCKET}/reports/"
echo ""
echo "💰 Estimated monthly cost: ~$0.02-0.05"
echo ""
echo "🧹 To cleanup all resources, run: ./scripts/cleanup.sh"

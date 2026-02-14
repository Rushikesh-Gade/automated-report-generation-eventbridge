#!/bin/bash

# AWS EventBridge Report Automation - Cleanup Script
# This script removes all deployed resources

set -e

echo "🧹 Starting cleanup of AWS EventBridge Report Automation..."
echo ""
echo "⚠️  WARNING: This will delete all resources including:"
echo "  - EventBridge Schedule"
echo "  - Lambda Function"
echo "  - S3 Buckets and all data"
echo "  - IAM Roles and Policies"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

export AWS_REGION=$(aws configure get region)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Prompt for resource names
read -p "Enter Schedule Name (e.g., daily-reports-mwkvgt): " SCHEDULE_NAME
read -p "Enter Lambda Function Name (e.g., report-generator-mwkvgt): " LAMBDA_FUNCTION
read -p "Enter Data Bucket Name (e.g., report-data-mwkvgt): " DATA_BUCKET
read -p "Enter Reports Bucket Name (e.g., report-output-mwkvgt): " REPORTS_BUCKET

echo ""
echo "🗑️  Deleting resources..."

# Step 1: Delete EventBridge Schedule
echo "⏰ Deleting EventBridge schedule..."
aws scheduler delete-schedule --name ${SCHEDULE_NAME} 2>/dev/null || echo "Schedule not found or already deleted"
echo "✅ EventBridge schedule deleted"

# Step 2: Delete Lambda Function
echo "⚡ Deleting Lambda function..."
aws lambda delete-function --function-name ${LAMBDA_FUNCTION} 2>/dev/null || echo "Lambda function not found or already deleted"
echo "✅ Lambda function deleted"

# Step 3: Empty and delete S3 buckets
echo "📦 Emptying and deleting S3 buckets..."
aws s3 rm s3://${DATA_BUCKET} --recursive 2>/dev/null || echo "Data bucket not found or already empty"
aws s3 rb s3://${DATA_BUCKET} 2>/dev/null || echo "Data bucket not found or already deleted"

aws s3 rm s3://${REPORTS_BUCKET} --recursive 2>/dev/null || echo "Reports bucket not found or already empty"
aws s3 rb s3://${REPORTS_BUCKET} 2>/dev/null || echo "Reports bucket not found or already deleted"
echo "✅ S3 buckets deleted"

# Step 4: Delete Lambda IAM role and policies
echo "🔐 Deleting Lambda IAM role and policies..."
aws iam detach-role-policy \
    --role-name ReportGeneratorRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null || true

aws iam detach-role-policy \
    --role-name ReportGeneratorRole \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/ReportGeneratorPolicy 2>/dev/null || true

aws iam delete-policy \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/ReportGeneratorPolicy 2>/dev/null || true

aws iam delete-role --role-name ReportGeneratorRole 2>/dev/null || true
echo "✅ Lambda IAM role deleted"

# Step 5: Delete EventBridge Scheduler IAM role and policies
echo "🔐 Deleting EventBridge Scheduler IAM role and policies..."
aws iam detach-role-policy \
    --role-name EventBridgeSchedulerRole \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/EventBridgeSchedulerPolicy 2>/dev/null || true

aws iam delete-policy \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/EventBridgeSchedulerPolicy 2>/dev/null || true

aws iam delete-role --role-name EventBridgeSchedulerRole 2>/dev/null || true
echo "✅ EventBridge Scheduler IAM role deleted"

# Step 6: Clean up local files
echo "🗑️  Cleaning up local temporary files..."
rm -f response.json response2.json response3.json 2>/dev/null || true
echo "✅ Local files cleaned"

echo ""
echo "🎉 Cleanup completed successfully!"
echo ""
echo "Note: SES email verification remains active. To remove it:"
echo "  aws ses delete-identity --identity your-email@example.com"

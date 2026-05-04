# Deployment Guide

## Prerequisites

- AWS Account with free tier access
- AWS CLI configured
- Python 3.12 installed
- Node.js 18+ (for frontend)
- OpenAI API key

## Step 1: Set Up AWS Resources

### 1.1 Create S3 Buckets

```bash
# Resume storage bucket
aws s3 mb s3://resume-matcher-resumes --region ap-south-1

# Cover letter storage bucket
aws s3 mb s3://resume-matcher-coverletters --region ap-south-1
```

### 1.2 Create DynamoDB Tables

```bash
# Users table
aws dynamodb create-table \
    --table-name ResumeMatcherUsers \
    --attribute-definitions AttributeName=user_id,AttributeType=S \
    --key-schema AttributeName=user_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1

# Resumes table
aws dynamodb create-table \
    --table-name ResumeMatcherResumes \
    --attribute-definitions AttributeName=user_id,AttributeType=S \
    --key-schema AttributeName=user_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1

# Jobs table
aws dynamodb create-table \
    --table-name ResumeMatcherJobs \
    --attribute-definitions AttributeName=job_id,AttributeType=S \
    --key-schema AttributeName=job_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1

# Matches table
aws dynamodb create-table \
    --table-name ResumeMatcherMatches \
    --attribute-definitions \
        AttributeName=user_id,AttributeType=S \
        AttributeName=job_id,AttributeType=S \
    --key-schema \
        AttributeName=user_id,KeyType=HASH \
        AttributeName=job_id,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1

# Applications table
aws dynamodb create-table \
    --table-name ResumeMatcherApplications \
    --attribute-definitions \
        AttributeName=user_id,AttributeType=S \
        AttributeName=job_id,AttributeType=S \
    --key-schema \
        AttributeName=user_id,KeyType=HASH \
        AttributeName=job_id,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1
```

### 1.3 Create IAM Role for Lambda

Create `lambda-trust-policy.json`:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Create the role:
```bash
aws iam create-role \
    --role-name ResumeMatcherLambdaRole \
    --assume-role-policy-document file://lambda-trust-policy.json
```

Attach policies:
```bash
# Basic Lambda execution
aws iam attach-role-policy \
    --role-name ResumeMatcherLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# S3 access
aws iam attach-role-policy \
    --role-name ResumeMatcherLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# DynamoDB access
aws iam attach-role-policy \
    --role-name ResumeMatcherLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
```

## Step 2: Deploy Lambda Functions

### 2.1 Package Lambda Functions

```bash
cd backend/lambda

# Create deployment package for resume parser
mkdir package
pip install -r ../requirements.txt -t package/
cd package
zip -r ../resume_parser.zip .
cd ..
zip -g resume_parser.zip resume_parser.py

# Repeat for other functions
```

### 2.2 Deploy Lambda Functions

```bash
# Resume Parser
aws lambda create-function \
    --function-name resume-parser \
    --runtime python3.12 \
    --role arn:aws:iam::YOUR_ACCOUNT_ID:role/ResumeMatcherLambdaRole \
    --handler resume_parser.lambda_handler \
    --zip-file fileb://resume_parser.zip \
    --timeout 300 \
    --memory-size 512 \
    --environment Variables="{OPENAI_API_KEY=your-key,S3_RESUME_BUCKET=resume-matcher-resumes}" \
    --region ap-south-1

# Job Scraper
aws lambda create-function \
    --function-name job-scraper \
    --runtime python3.12 \
    --role arn:aws:iam::YOUR_ACCOUNT_ID:role/ResumeMatcherLambdaRole \
    --handler job_scraper.lambda_handler \
    --zip-file fileb://job_scraper.zip \
    --timeout 300 \
    --memory-size 1024 \
    --region ap-south-1

# Match Engine
aws lambda create-function \
    --function-name match-engine \
    --runtime python3.12 \
    --role arn:aws:iam::YOUR_ACCOUNT_ID:role/ResumeMatcherLambdaRole \
    --handler match_engine.lambda_handler \
    --zip-file fileb://match_engine.zip \
    --timeout 300 \
    --memory-size 512 \
    --environment Variables="{OPENAI_API_KEY=your-key}" \
    --region ap-south-1
```

## Step 3: Set Up EventBridge Scheduler

```bash
# Create schedule for daily job scraping
aws scheduler create-schedule \
    --name daily-job-scraper \
    --schedule-expression "cron(0 0 * * ? *)" \
    --target '{
        "Arn": "arn:aws:lambda:ap-south-1:YOUR_ACCOUNT_ID:function:job-scraper",
        "RoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/EventBridgeSchedulerRole"
    }' \
    --flexible-time-window '{"Mode": "OFF"}' \
    --region ap-south-1
```

## Step 4: Verify SES Email

```bash
# Verify your email address for sending notifications
aws ses verify-email-identity \
    --email-address your-email@example.com \
    --region ap-south-1
```

Check your email and click the verification link.

## Step 5: Test Lambda Functions

```bash
# Test resume parser
aws lambda invoke \
    --function-name resume-parser \
    --payload '{"user_id":"test123","resume_key":"test.pdf"}' \
    response.json

# Test job scraper
aws lambda invoke \
    --function-name job-scraper \
    response.json

# Test match engine
aws lambda invoke \
    --function-name match-engine \
    --payload '{"user_id":"test123"}' \
    response.json
```

## Step 6: Monitor Costs

Set up billing alerts:

```bash
aws cloudwatch put-metric-alarm \
    --alarm-name resume-matcher-cost-alert \
    --alarm-description "Alert when costs exceed $10" \
    --metric-name EstimatedCharges \
    --namespace AWS/Billing \
    --statistic Maximum \
    --period 21600 \
    --evaluation-periods 1 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold
```

## Troubleshooting

### Lambda Function Errors
- Check CloudWatch Logs: `aws logs tail /aws/lambda/function-name --follow`
- Verify IAM permissions
- Check environment variables

### DynamoDB Issues
- Verify table names match configuration
- Check billing mode (should be PAY_PER_REQUEST for free tier)

### S3 Upload Failures
- Verify bucket names
- Check IAM role has S3 permissions
- Ensure bucket is in correct region

## Cost Monitoring

Monitor your AWS costs:
```bash
aws ce get-cost-and-usage \
    --time-period Start=2025-03-01,End=2025-03-31 \
    --granularity MONTHLY \
    --metrics BlendedCost
```

## Cleanup (When Done)

To avoid charges, delete all resources:

```bash
# Delete Lambda functions
aws lambda delete-function --function-name resume-parser
aws lambda delete-function --function-name job-scraper
aws lambda delete-function --function-name match-engine

# Delete DynamoDB tables
aws dynamodb delete-table --table-name ResumeMatcherUsers
aws dynamodb delete-table --table-name ResumeMatcherResumes
aws dynamodb delete-table --table-name ResumeMatcherJobs
aws dynamodb delete-table --table-name ResumeMatcherMatches
aws dynamodb delete-table --table-name ResumeMatcherApplications

# Empty and delete S3 buckets
aws s3 rm s3://resume-matcher-resumes --recursive
aws s3 rb s3://resume-matcher-resumes
aws s3 rm s3://resume-matcher-coverletters --recursive
aws s3 rb s3://resume-matcher-coverletters
```

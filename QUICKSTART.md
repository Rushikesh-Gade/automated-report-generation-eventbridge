# Quick Start Guide

Get the AWS EventBridge Report Automation system up and running in 15 minutes!

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] AWS Account with admin access
- [ ] AWS CLI installed (v2.0+)
- [ ] AWS CLI configured with credentials
- [ ] Python 3.12 or later
- [ ] Email address for receiving reports
- [ ] ~$0.02 budget for testing (almost free!)

## Quick Setup (5 Commands)

### 1. Clone and Navigate

```bash
git clone https://github.com/Rushikesh-Gade/automated-report-generation-eventbridge.git
cd automated-report-generation-eventbridge
```

### 2. Set Your Email

```bash
export VERIFIED_EMAIL="your-email@example.com"
```

### 3. Run Deployment Script

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 4. Verify Email

Check your email inbox and click the AWS SES verification link.

### 5. Test the System

```bash
aws lambda invoke \
    --function-name report-generator-XXXXXX \
    --payload '{}' \
    response.json
```

**Done!** Check your email (including spam folder) for the report.

---

## Manual Setup (Step-by-Step)

If you prefer manual control or the script doesn't work:

### Step 1: Configure AWS

```bash
# Verify AWS CLI is configured
aws sts get-caller-identity

# Set environment variables
export AWS_REGION=$(aws configure get region)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export VERIFIED_EMAIL="your-email@example.com"

# Generate unique suffix
export SUFFIX=$(date +%s | tail -c 7)
export DATA_BUCKET="report-data-${SUFFIX}"
export REPORTS_BUCKET="report-output-${SUFFIX}"
export LAMBDA_FUNCTION="report-generator-${SUFFIX}"
export SCHEDULE_NAME="daily-reports-${SUFFIX}"
```

### Step 2: Create S3 Buckets

```bash
# Create buckets
aws s3 mb s3://${DATA_BUCKET}
aws s3 mb s3://${REPORTS_BUCKET}

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket ${DATA_BUCKET} \
    --versioning-configuration Status=Enabled

aws s3api put-bucket-versioning \
    --bucket ${REPORTS_BUCKET} \
    --versioning-configuration Status=Enabled

# Upload sample data
aws s3 cp data/sample_sales.csv s3://${DATA_BUCKET}/sales/
aws s3 cp data/sample_inventory.csv s3://${DATA_BUCKET}/inventory/
```

### Step 3: Create IAM Roles

```bash
# Lambda role
aws iam create-role \
    --role-name ReportGeneratorRole \
    --assume-role-policy-document file://iam/lambda-trust-policy.json

aws iam attach-role-policy \
    --role-name ReportGeneratorRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Update and create custom policy (replace bucket names)
sed "s/report-data-mwkvgt/${DATA_BUCKET}/g; s/report-output-mwkvgt/${REPORTS_BUCKET}/g" \
    iam/lambda-permissions-policy.json > /tmp/lambda-policy.json

aws iam create-policy \
    --policy-name ReportGeneratorPolicy \
    --policy-document file:///tmp/lambda-policy.json

aws iam attach-role-policy \
    --role-name ReportGeneratorRole \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/ReportGeneratorPolicy
```

### Step 4: Deploy Lambda

```bash
# Wait for IAM propagation
sleep 10

# Create Lambda function
aws lambda create-function \
    --function-name ${LAMBDA_FUNCTION} \
    --runtime python3.12 \
    --role arn:aws:iam::${AWS_ACCOUNT_ID}:role/ReportGeneratorRole \
    --handler report_generator.lambda_handler \
    --zip-file fileb://lambda/function.zip \
    --timeout 300 \
    --memory-size 512 \
    --environment Variables="{DATA_BUCKET=${DATA_BUCKET},REPORTS_BUCKET=${REPORTS_BUCKET},EMAIL_ADDRESS=${VERIFIED_EMAIL}}"
```

### Step 5: Create EventBridge Schedule

```bash
# Scheduler role
aws iam create-role \
    --role-name EventBridgeSchedulerRole \
    --assume-role-policy-document file://iam/scheduler-trust-policy.json

# Update and create scheduler policy
sed "s/report-generator-mwkvgt/${LAMBDA_FUNCTION}/g; s/ap-south-1/${AWS_REGION}/g; s/936998755370/${AWS_ACCOUNT_ID}/g" \
    iam/scheduler-permissions-policy.json > /tmp/scheduler-policy.json

aws iam create-policy \
    --policy-name EventBridgeSchedulerPolicy \
    --policy-document file:///tmp/scheduler-policy.json

aws iam attach-role-policy \
    --role-name EventBridgeSchedulerRole \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/EventBridgeSchedulerPolicy

# Create schedule
aws scheduler create-schedule \
    --name ${SCHEDULE_NAME} \
    --schedule-expression "cron(0 9 * * ? *)" \
    --target "{\"Arn\":\"arn:aws:lambda:${AWS_REGION}:${AWS_ACCOUNT_ID}:function:${LAMBDA_FUNCTION}\",\"RoleArn\":\"arn:aws:iam::${AWS_ACCOUNT_ID}:role/EventBridgeSchedulerRole\"}" \
    --flexible-time-window "{\"Mode\":\"OFF\"}"
```

### Step 6: Verify Email

```bash
# Initiate verification
aws ses verify-email-identity --email-address ${VERIFIED_EMAIL}

# Check status (wait for email and click link first)
aws ses get-identity-verification-attributes \
    --identities ${VERIFIED_EMAIL}
```

---

## Testing

### Test Lambda Function

```bash
aws lambda invoke \
    --function-name ${LAMBDA_FUNCTION} \
    --payload '{}' \
    response.json

cat response.json
```

Expected output:
```json
{"statusCode": 200, "body": "\"Report generated successfully: reports/daily_report_YYYYMMDD_HHMMSS.csv\""}
```

### View Generated Reports

```bash
# List reports
aws s3 ls s3://${REPORTS_BUCKET}/reports/

# Download latest report
aws s3 cp s3://${REPORTS_BUCKET}/reports/ . --recursive --exclude "*" --include "*.csv"
```

### Check Email

1. Open your email inbox
2. Check spam/junk folder if not in inbox
3. Look for "Daily Business Report" email
4. Verify CSV attachment is present

### Monitor Logs

```bash
# View recent logs
aws logs tail /aws/lambda/${LAMBDA_FUNCTION} --follow

# Or view in AWS Console
# Navigate to: CloudWatch > Log groups > /aws/lambda/your-function-name
```

---

## Troubleshooting

### Email Not Received

**Problem:** Email not appearing in inbox

**Solutions:**
1. Check spam/junk folder
2. Verify email address in SES:
   ```bash
   aws ses get-identity-verification-attributes --identities ${VERIFIED_EMAIL}
   ```
3. Check CloudWatch logs for errors
4. Verify SES sending statistics:
   ```bash
   aws ses get-send-statistics
   ```

### Lambda Function Fails

**Problem:** Lambda returns error

**Solutions:**
1. Check CloudWatch logs:
   ```bash
   aws logs tail /aws/lambda/${LAMBDA_FUNCTION}
   ```
2. Verify IAM permissions
3. Check S3 bucket names in environment variables
4. Ensure sample data exists in S3

### IAM Permission Errors

**Problem:** Access denied errors

**Solutions:**
1. Wait 10-15 seconds for IAM propagation
2. Verify role trust policies
3. Check policy attachments:
   ```bash
   aws iam list-attached-role-policies --role-name ReportGeneratorRole
   ```

### Schedule Not Triggering

**Problem:** Reports not generated automatically

**Solutions:**
1. Verify schedule is enabled:
   ```bash
   aws scheduler get-schedule --name ${SCHEDULE_NAME}
   ```
2. Check schedule expression (cron syntax)
3. Verify target Lambda function ARN
4. Check EventBridge Scheduler role permissions

---

## Next Steps

After successful deployment:

1. **Customize the Schedule**
   - Modify cron expression for different times
   - Create multiple schedules for different reports

2. **Add Your Data**
   - Replace sample CSV files with real data
   - Update Lambda code for your data structure

3. **Enhance Reports**
   - Add more metrics and calculations
   - Include charts and visualizations
   - Support multiple output formats

4. **Monitor and Optimize**
   - Set up CloudWatch alarms
   - Review costs in Cost Explorer
   - Optimize Lambda memory settings

5. **Take Screenshots**
   - Capture AWS Console screenshots for portfolio
   - Document your deployment
   - Add to resume/LinkedIn

---

## Cleanup

When you're done testing:

```bash
# Run cleanup script
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh

# Or manually delete resources (see DEPLOYMENT_SUMMARY.md)
```

---

## Getting Help

- **Documentation:** See [README.md](README.md) and [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)
- **Issues:** Check [GitHub Issues](https://github.com/Rushikesh-Gade/automated-report-generation-eventbridge/issues)
- **AWS Docs:** [AWS Lambda](https://docs.aws.amazon.com/lambda/) | [EventBridge](https://docs.aws.amazon.com/eventbridge/)

---

**Estimated Setup Time:** 15-20 minutes  
**Estimated Monthly Cost:** ~$0.02-0.05

Happy automating! 🚀

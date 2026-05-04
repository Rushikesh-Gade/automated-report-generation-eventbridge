# AWS EventBridge Automated Report Generation System

![AWS](https://img.shields.io/badge/AWS-EventBridge-orange)
![Python](https://img.shields.io/badge/Python-3.12-blue)
![License](https://img.shields.io/badge/License-MIT-green)

A serverless automated reporting system that generates and distributes business reports on a scheduled basis using AWS EventBridge Scheduler, Lambda, S3, and SES.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Cost Analysis](#cost-analysis)
- [Screenshots](#screenshots)
- [Lessons Learned](#lessons-learned)
- [Future Enhancements](#future-enhancements)
- [Cleanup](#cleanup)
- [License](#license)

## 🎯 Overview

This project demonstrates a fully serverless solution for automated business report generation and distribution. The system processes sales and inventory data stored in S3, generates comprehensive reports with business metrics, and automatically emails them to stakeholders on a daily schedule.

**Problem Solved:** Organizations often struggle with manual report generation, leading to delays and inconsistent delivery. This solution automates the entire process, ensuring timely and reliable report distribution.

### Current Deployment Status

**Status:** ✅ Successfully Deployed and Running

**AWS Account:** 368428768532  
**Region:** ap-south-1 (Mumbai)

**Deployed Resources:**
- Lambda Function: `report-generator-18620`
- S3 Data Bucket: `report-data-18620`
- S3 Reports Bucket: `report-output-18620`
- EventBridge Schedule: `daily-reports-18620`
- IAM Roles: `ReportGeneratorRole`, `EventBridgeSchedulerRole`

**Schedule:** Daily at 9:00 PM IST (15:30 UTC)

**Email Recipients:**
- rushikeshgade093@gmail.com
- rushikeshgade2540@gmail.com
- rushikeshgade2066@gmail.com

## 🏗️ Architecture

```
┌─────────────────────┐
│ EventBridge         │
│ Scheduler           │
│ (Daily 9 AM UTC)    │
└──────────┬──────────┘
           │ Trigger
           ▼
┌─────────────────────┐
│ Lambda Function     │
│ (Python 3.12)       │
│ - Read S3 Data      │
│ - Generate Report   │
│ - Send Email        │
└──────────┬──────────┘
           │
    ┌──────┴──────┐
    ▼             ▼
┌─────────┐  ┌─────────┐
│ S3      │  │ SES     │
│ Buckets │  │ Email   │
└─────────┘  └─────────┘
```

### Architecture Components:

1. **EventBridge Scheduler**: Triggers Lambda function daily at 9 AM UTC
2. **Lambda Function**: Processes data and generates reports
3. **S3 Buckets**: 
   - Data bucket: Stores source sales and inventory data
   - Reports bucket: Archives generated reports
4. **Amazon SES**: Sends email notifications with report attachments
5. **IAM Roles**: Manages permissions with least-privilege access

## ✨ Features

- ✅ **Fully Serverless**: No server management required
- ✅ **Automated Scheduling**: Daily report generation at specified time
- ✅ **Data Processing**: Combines sales and inventory data with business logic
- ✅ **Email Distribution**: Automatic email delivery with CSV attachments
- ✅ **Cost Effective**: ~$0.02-0.05 per month operational cost
- ✅ **Scalable**: Handles growth from small to large datasets
- ✅ **Reliable**: Built-in retry logic and error handling
- ✅ **Audit Trail**: Complete report history stored in S3

## 🛠️ Technologies Used

- **AWS EventBridge Scheduler** - Serverless scheduling service
- **AWS Lambda** - Serverless compute (Python 3.12)
- **Amazon S3** - Object storage for data and reports
- **Amazon SES** - Email delivery service
- **AWS IAM** - Identity and access management
- **Python 3.12** - Lambda runtime with boto3 SDK
- **CSV Processing** - Data manipulation and report generation

## 📋 Prerequisites

- AWS Account with appropriate permissions
- AWS CLI installed and configured (v2.0+)
- Python 3.12 or later
- Verified email address in Amazon SES
- Basic understanding of AWS services and Python

## 🚀 Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/Rushikesh-Gade/automated-report-generation-eventbridge.git
cd automated-report-generation-eventbridge
```

### Step 2: Set Environment Variables

```bash
export AWS_REGION=$(aws configure get region)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export DATA_BUCKET="report-data-$(date +%s)"
export REPORTS_BUCKET="report-output-$(date +%s)"
export LAMBDA_FUNCTION="report-generator-$(date +%s)"
export SCHEDULE_NAME="daily-reports-$(date +%s)"
export VERIFIED_EMAIL="your-email@example.com"
```

### Step 3: Create S3 Buckets

```bash
aws s3 mb s3://${DATA_BUCKET} --region ${AWS_REGION}
aws s3 mb s3://${REPORTS_BUCKET} --region ${AWS_REGION}

# Enable versioning
aws s3api put-bucket-versioning --bucket ${DATA_BUCKET} --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket ${REPORTS_BUCKET} --versioning-configuration Status=Enabled
```

### Step 4: Upload Sample Data

```bash
aws s3 cp sample_sales.csv s3://${DATA_BUCKET}/sales/
aws s3 cp sample_inventory.csv s3://${DATA_BUCKET}/inventory/
```

### Step 5: Create IAM Roles

```bash
# Create Lambda execution role
aws iam create-role --role-name ReportGeneratorRole --assume-role-policy-document file://iam/lambda-trust-policy.json

# Attach policies
aws iam attach-role-policy --role-name ReportGeneratorRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam create-policy --policy-name ReportGeneratorPolicy --policy-document file://iam/lambda-permissions-policy.json

aws iam attach-role-policy --role-name ReportGeneratorRole --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/ReportGeneratorPolicy
```

### Step 6: Deploy Lambda Function

```bash
# Create deployment package
cd lambda
zip function.zip report_generator.py
cd ..

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

### Step 7: Create EventBridge Schedule

```bash
# Create scheduler role
aws iam create-role --role-name EventBridgeSchedulerRole --assume-role-policy-document file://iam/scheduler-trust-policy.json

aws iam create-policy --policy-name EventBridgeSchedulerPolicy --policy-document file://iam/scheduler-permissions-policy.json

aws iam attach-role-policy --role-name EventBridgeSchedulerRole --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/EventBridgeSchedulerPolicy

# Create schedule
aws scheduler create-schedule \
    --name ${SCHEDULE_NAME} \
    --schedule-expression "cron(0 9 * * ? *)" \
    --target "{\"Arn\":\"arn:aws:lambda:${AWS_REGION}:${AWS_ACCOUNT_ID}:function:${LAMBDA_FUNCTION}\",\"RoleArn\":\"arn:aws:iam::${AWS_ACCOUNT_ID}:role/EventBridgeSchedulerRole\"}" \
    --flexible-time-window "{\"Mode\":\"OFF\"}" \
    --description "Daily business report generation"
```

### Step 8: Verify Email in SES

```bash
aws ses verify-email-identity --email-address ${VERIFIED_EMAIL}
# Check your email and click the verification link
```

## 📖 Usage

### Manual Test

```bash
# Invoke Lambda function manually
aws lambda invoke --function-name ${LAMBDA_FUNCTION} --payload '{}' response.json
cat response.json
```

### View Generated Reports

```bash
# List reports
aws s3 ls s3://${REPORTS_BUCKET}/reports/

# Download latest report
aws s3 cp s3://${REPORTS_BUCKET}/reports/ . --recursive
```

### Check Schedule Status

```bash
aws scheduler get-schedule --name ${SCHEDULE_NAME}
```

### Monitor Logs

```bash
aws logs tail /aws/lambda/${LAMBDA_FUNCTION} --follow
```

## 📁 Project Structure

```
aws-eventbridge-report-automation/
├── README.md                           # This file
├── DEPLOYMENT_SUMMARY.md               # Deployment details
├── automated-report-generation-eventbridge.md  # Original recipe
├── lambda/
│   ├── report_generator.py            # Lambda function code
│   └── function.zip                   # Deployment package
├── iam/
│   ├── lambda-trust-policy.json       # Lambda role trust policy
│   ├── lambda-permissions-policy.json # Lambda permissions
│   ├── scheduler-trust-policy.json    # Scheduler role trust policy
│   └── scheduler-permissions-policy.json # Scheduler permissions
├── data/
│   ├── sample_sales.csv               # Sample sales data
│   └── sample_inventory.csv           # Sample inventory data
├── screenshots/
│   ├── architecture-diagram.png       # Architecture diagram
│   ├── lambda-function.png            # Lambda console
│   ├── eventbridge-schedule.png       # EventBridge schedule
│   ├── s3-buckets.png                 # S3 buckets
│   └── email-received.png             # Email screenshot
├── examples/
│   ├── sample-report.csv              # Example generated report
│   └── email-template.txt             # Email body template
└── scripts/
    ├── deploy.sh                      # Automated deployment script
    └── cleanup.sh                     # Resource cleanup script
```

## 💰 Cost Analysis

### Monthly Cost Breakdown (After Free Tier)

| Service | Usage | Cost |
|---------|-------|------|
| EventBridge Scheduler | 30 invocations/month | $0.00003 |
| Lambda | 30 executions, 512MB, 5s | $0.01 |
| S3 | ~10MB storage | $0.01 |
| SES | 30 emails | $0.003 |
| **Total** | | **~$0.02-0.05/month** |

### Free Tier Coverage

- **Lambda**: 1M requests/month, 400,000 GB-seconds
- **S3**: 5GB storage, 20,000 GET requests
- **SES**: 62,000 emails/month (when sending from EC2)
- **EventBridge**: 14M invocations/month (EventBridge Rules, not Scheduler)

**Note:** This project costs almost nothing even after free tier expires!

## 📸 Screenshots

### Architecture Diagram
![Architecture](screenshots/architecture-diagram.png)

### Lambda Function Configuration
![Lambda](screenshots/lambda-function.png)

### EventBridge Schedule
![EventBridge](screenshots/eventbridge-schedule.png)

### Email Received
![Email](screenshots/email-received.png)

### Generated Report
![Report](screenshots/sample-report.png)

## 📚 Lessons Learned

1. **SES Sandbox Mode**: New AWS accounts start in SES sandbox mode, requiring email verification for both sender and recipient
2. **Gmail Spam Filtering**: Emails from new AWS SES senders often go to spam initially
3. **IAM Role Propagation**: Need to wait 10-15 seconds after creating IAM roles before using them
4. **Lambda Cold Starts**: First invocation takes longer due to initialization
5. **Cost Optimization**: Serverless architecture provides excellent cost efficiency for scheduled tasks
6. **Error Handling**: Comprehensive error handling and logging are crucial for production systems

## 🚀 Future Enhancements

- [ ] Add support for multiple report formats (PDF, Excel, JSON)
- [ ] Implement data visualization with charts and graphs
- [ ] Add Amazon QuickSight integration for dashboards
- [ ] Create multiple schedules for different report types
- [ ] Add SNS notifications for failed report generation
- [ ] Implement dynamic data discovery using S3 event notifications
- [ ] Add CloudWatch alarms for monitoring
- [ ] Create Terraform/CloudFormation templates for IaC
- [ ] Add unit tests and integration tests
- [ ] Implement report customization via parameter store

## 🧹 Cleanup

To delete all resources and avoid charges:

```bash
# Run the cleanup script
./scripts/cleanup.sh

# Or manually:
aws scheduler delete-schedule --name ${SCHEDULE_NAME}
aws lambda delete-function --function-name ${LAMBDA_FUNCTION}
aws s3 rm s3://${DATA_BUCKET} --recursive && aws s3 rb s3://${DATA_BUCKET}
aws s3 rm s3://${REPORTS_BUCKET} --recursive && aws s3 rb s3://${REPORTS_BUCKET}
# Delete IAM roles and policies (see DEPLOYMENT_SUMMARY.md for complete commands)
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Rushikesh Gade**
- GitHub: [@Rushikesh-Gade](https://github.com/Rushikesh-Gade)
- LinkedIn: [Rushikesh Gade](https://linkedin.com/in/rushikesh-gade)](https://www.linkedin.com/in/rishi-gade-9032a9238?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app)
- Email: rushikeshgade093@gmail.com

## 🙏 Acknowledgments

- AWS Documentation and Best Practices
- AWS Well-Architected Framework
- Serverless Architecture Patterns

---

**⭐ If you found this project helpful, please give it a star!**

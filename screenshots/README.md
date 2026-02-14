# Screenshots

This directory contains screenshots demonstrating the deployed AWS EventBridge Report Automation system.

## Required Screenshots

To complete this portfolio project, capture the following screenshots from your AWS Console:

### 1. Architecture Overview
- **File:** `architecture-diagram.png`
- **Content:** Overall system architecture (can use draw.io or AWS Architecture Icons)

### 2. Lambda Function
- **File:** `lambda-function.png`
- **What to capture:**
  - Lambda function configuration page
  - Show function name, runtime (Python 3.12), memory (512 MB)
  - Environment variables section
  - Recent invocations

### 3. EventBridge Scheduler
- **File:** `eventbridge-schedule.png`
- **What to capture:**
  - EventBridge Scheduler console
  - Schedule details showing cron expression
  - Target configuration (Lambda function)
  - Schedule state (ENABLED)

### 4. S3 Buckets
- **File:** `s3-buckets.png`
- **What to capture:**
  - S3 console showing both buckets
  - Data bucket with sales/ and inventory/ folders
  - Reports bucket with generated reports
  - File timestamps

### 5. Generated Report
- **File:** `sample-report.png`
- **What to capture:**
  - CSV file opened in Excel or text editor
  - Show the report data with columns and values
  - Highlight the calculated metrics

### 6. Email Received
- **File:** `email-received.png`
- **What to capture:**
  - Gmail inbox showing received email
  - Email subject and sender
  - Email body with report details
  - CSV attachment visible

### 7. CloudWatch Logs
- **File:** `cloudwatch-logs.png`
- **What to capture:**
  - CloudWatch Logs console
  - Lambda function log stream
  - Successful execution logs
  - Show duration and memory usage

### 8. IAM Roles
- **File:** `iam-roles.png`
- **What to capture:**
  - IAM console showing created roles
  - ReportGeneratorRole with attached policies
  - EventBridgeSchedulerRole

### 9. SES Email Verification
- **File:** `ses-verification.png`
- **What to capture:**
  - SES console showing verified email
  - Verification status: Success

### 10. Cost Explorer (Optional)
- **File:** `cost-analysis.png`
- **What to capture:**
  - AWS Cost Explorer showing minimal costs
  - Service breakdown

## How to Take Screenshots

### AWS Console Screenshots:
1. Navigate to the specific service in AWS Console
2. Use Windows Snipping Tool (Win + Shift + S) or similar
3. Capture the relevant section showing key information
4. Save with the filename specified above
5. Place in this `screenshots/` directory

### Email Screenshot:
1. Open the received email in Gmail
2. Capture the full email including subject, body, and attachment
3. Ensure no sensitive information is visible
4. Save as `email-received.png`

## Privacy Note

⚠️ **Important:** Before sharing screenshots publicly:
- Blur or remove AWS Account IDs if sensitive
- Remove any personal email addresses (or use a demo email)
- Ensure no sensitive data is visible in reports
- Check that no API keys or credentials are shown

## Alternative: Use Provided Examples

If you've already cleaned up the AWS resources, you can:
1. Use the example files in the `examples/` directory
2. Create mockups using draw.io or similar tools
3. Document that this is a demonstration project

---

**Status:** Screenshots pending - capture from AWS Console before cleanup

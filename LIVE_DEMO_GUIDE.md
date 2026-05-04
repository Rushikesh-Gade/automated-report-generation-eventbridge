# Live Demo Guide for Faculty Presentation

## Project: Automated Report Generation using AWS EventBridge

**Student:** Rushikesh Gade  
**Date:** May 5, 2026  
**Time:** 11:00 AM

---

## Current Deployment Details

### AWS Account
- **Account ID:** 3684........
- **Region:** ap-south-1 (Mumbai)
- **User:** Ru....

### Resource Names
- **S3 Data Bucket:** `report-data-18620`
- **S3 Output Bucket:** `report-output-18620`
- **Lambda Function:** `report-generator-18620`
- **EventBridge Schedule:** `daily-reports-18620`
- **IAM Roles:**
  - `ReportGeneratorRole` (for Lambda)
  - `EventBridgeSchedulerRole` (for EventBridge)

### Email Recipients
- rushikeshgade093@gmail.com
- rushikeshgade2540@gmail.com
- rushikeshgade2066@gmail.com

### Schedule
- **Frequency:** Daily
- **Time:** 9:00 PM IST (15:30 UTC)

---

## Live Demo Steps (5-7 minutes)

### Step 1: Show AWS Console Overview (1 min)

1. Open AWS Console: https://console.aws.amazon.com
2. Login with your credentials
3. Verify region is set to **ap-south-1 (Mumbai)**
4. Show the services we're using:
   - Lambda
   - S3
   - EventBridge Scheduler
   - SES (Simple Email Service)

### Step 2: Show S3 Buckets with Data (1 min)

1. Go to **S3** service
2. Show **report-data-18620** bucket:
   - Click on bucket name
   - Navigate to `sales/` folder → show `sample_sales.csv`
   - Navigate to `inventory/` folder → show `sample_inventory.csv`
   - Explain: "This is our source data that gets processed daily"

3. Show **report-output-18620** bucket:
   - Click on bucket name
   - Navigate to `reports/` folder
   - Show generated reports with timestamps
   - Explain: "These are automatically generated reports"

### Step 3: Show Lambda Function (1 min)

1. Go to **Lambda** service
2. Click on **report-generator-18620** function
3. Show the **Code** tab:
   - Explain: "This Python code reads data from S3, processes it, and generates reports"
4. Show **Configuration** tab → **Environment variables**:
   - DATA_BUCKET: report-data-18620
   - REPORTS_BUCKET: report-output-18620
   - EMAIL_ADDRESS: rushikeshgade093@gmail.com

### Step 4: Show EventBridge Schedule (1 min)

1. Go to **EventBridge** service
2. Click on **Schedules** in left menu
3. Click on **daily-reports-18620**
4. Show:
   - Schedule pattern: `cron(30 15 * * ? *)`
   - Explain: "Runs daily at 9 PM IST"
   - Target: Lambda function `report-generator-18620`
   - Status: **Enabled**

### Step 5: LIVE EXECUTION - Manual Trigger (2-3 min)

**This is the most important part!**

#### Option A: Using AWS Console (Recommended for Faculty)

1. Go to **Lambda** service
2. Click on **report-generator-18620**
3. Click **Test** tab
4. Click **Test** button (orange button)
5. Wait 5-10 seconds
6. Show **Execution result**:
   - Status: Succeeded (green)
   - Response: `"Report generated successfully: reports/daily_report_YYYYMMDD_HHMMSS.csv"`

7. **Immediately show the result:**
   - Go to S3 → report-output-18620 → reports/
   - Refresh the page
   - Show the NEW report file with current timestamp
   - Click on it and download to show the CSV content

8. **Show email received:**
   - Open your email inbox on phone/laptop
   - Show the email with subject "Daily Business Report - YYYY-MM-DD"
   - Open the email and show the CSV attachment

#### Option B: Using AWS CLI (If Faculty Prefers Command Line)

Open PowerShell/Terminal and run:

```bash
# Check AWS account
aws sts get-caller-identity

# Trigger Lambda function manually
aws lambda invoke --function-name report-generator-18620 --region ap-south-1 response.json

# Show the response
cat response.json

# List generated reports
aws s3 ls s3://report-output-18620/reports/ --region ap-south-1
```

### Step 6: Show Email Notification (1 min)

1. Open email inbox (rushikeshgade093@gmail.com)
2. Show the latest email with subject "Daily Business Report"
3. Open the email
4. Show the email body with report details
5. Download and open the CSV attachment
6. Show the report content:
   - Product names
   - Total Sales
   - Total Inventory
   - Sales Ratio

---

## Key Points to Mention

### Architecture
- **Serverless:** No servers to manage, fully cloud-based
- **Event-Driven:** Triggered automatically by EventBridge schedule
- **Scalable:** Can handle large datasets and multiple users
- **Cost-Effective:** Uses AWS free tier, costs ~$0.02-0.05/month

### Technologies Used
- **AWS Lambda:** Serverless compute (Python 3.12)
- **AWS S3:** Object storage for data and reports
- **AWS EventBridge:** Scheduled event trigger
- **AWS SES:** Email service for notifications
- **AWS IAM:** Security and access management
- **Python:** boto3, csv, email libraries

### Business Value
- **Automation:** Eliminates manual report generation
- **Consistency:** Reports generated at same time daily
- **Reliability:** Cloud-based, highly available
- **Scalability:** Can process any amount of data
- **Notifications:** Automatic email delivery to stakeholders

---

## Troubleshooting (If Something Goes Wrong)

### If Lambda Test Fails:
1. Check CloudWatch Logs:
   - Go to Lambda → Monitor tab → View CloudWatch logs
   - Show the error message
   - Explain: "We can debug using logs"

### If Email Not Received:
1. Check spam folder
2. Verify email in SES:
   ```bash
   aws ses get-identity-verification-attributes --identities rushikeshgade093@gmail.com --region ap-south-1
   ```

### If S3 Report Not Created:
1. Check Lambda execution result for errors
2. Verify IAM permissions
3. Show CloudWatch logs

---

## Questions Faculty Might Ask

### Q1: How does the schedule work?
**A:** EventBridge uses cron expressions. `cron(30 15 * * ? *)` means:
- 30 minutes past the hour
- 15th hour (3:30 PM UTC = 9:00 PM IST)
- Every day of month
- Every month
- Any day of week

### Q2: What if the Lambda function fails?
**A:** 
- CloudWatch logs capture all errors
- We can set up SNS alerts for failures
- Lambda has automatic retry mechanism
- We can configure Dead Letter Queues (DLQ)

### Q3: How much does this cost?
**A:**
- Lambda: 1M requests/month free
- S3: 5GB storage free
- EventBridge: Free for scheduled rules
- SES: 62,000 emails/month free
- **Total cost: ~$0.02-0.05/month**

### Q4: Can this scale to handle more data?
**A:** Yes! We can:
- Increase Lambda memory (up to 10GB)
- Increase Lambda timeout (up to 15 minutes)
- Use S3 batch operations for large files
- Add parallel processing

### Q5: How secure is this?
**A:**
- IAM roles with least privilege access
- S3 buckets are private by default
- Email addresses verified in SES
- All data encrypted at rest and in transit

### Q6: Can we add more features?
**A:** Yes! Possible enhancements:
- Add data visualization (charts/graphs)
- Send reports to Slack/Teams
- Add data validation and error handling
- Create dashboard using QuickSight
- Add multiple report formats (PDF, Excel)

---

## Backup Plan (If AWS Console Access Issues)

If you can't access AWS Console during demo:

1. **Show GitHub Repository:**
   - https://github.com/Rushikesh-Gade/automated-report-generation-eventbridge
   - Show code, documentation, architecture diagrams

2. **Show Screenshots:**
   - Take screenshots now of all AWS resources
   - Save in `screenshots/` folder

3. **Show Email:**
   - Have multiple emails ready to show
   - Download CSV reports beforehand

4. **Show Local Testing:**
   - Run Python script locally to show logic
   - Explain how it would work in cloud

---

## Time Management

- **Total Demo Time:** 7 minutes
- Introduction: 30 seconds
- AWS Console Overview: 1 minute
- S3 Buckets: 1 minute
- Lambda Function: 1 minute
- EventBridge Schedule: 1 minute
- **Live Execution: 2-3 minutes** ⭐ (Most Important)
- Q&A: Remaining time

---

## Final Checklist Before Demo

- [ ] AWS Console login working
- [ ] All resources visible in Mumbai region
- [ ] Email inbox accessible
- [ ] Internet connection stable
- [ ] Browser tabs pre-opened:
  - [ ] AWS Lambda console
  - [ ] AWS S3 console
  - [ ] AWS EventBridge console
  - [ ] Email inbox
- [ ] GitHub repository open (backup)
- [ ] This demo guide open for reference

---

## Good Luck! 🎓

Remember:
- Speak clearly and confidently
- Explain each step as you do it
- Show the live execution - that's the proof!
- Be ready for questions
- If something fails, stay calm and check logs

**The project is working perfectly. You've got this!** 💪

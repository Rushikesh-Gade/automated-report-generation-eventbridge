import boto3
import csv
import json
import os
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import io

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    ses = boto3.client('ses')
    
    data_bucket = os.environ['DATA_BUCKET']
    reports_bucket = os.environ['REPORTS_BUCKET']
    email_address = os.environ['EMAIL_ADDRESS']
    
    try:
        # Read sales data from S3
        response = s3.get_object(Bucket=data_bucket, Key='sales/sample_sales.csv')
        sales_data = response['Body'].read().decode('utf-8')
        
        # Read inventory data from S3
        response = s3.get_object(Bucket=data_bucket, Key='inventory/sample_inventory.csv')
        inventory_data = response['Body'].read().decode('utf-8')
        
        # Generate comprehensive report
        report_content = generate_report(sales_data, inventory_data)
        
        # Save report to S3 with timestamp
        report_key = f"reports/daily_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
        s3.put_object(
            Bucket=reports_bucket,
            Key=report_key,
            Body=report_content,
            ContentType='text/csv'
        )
        
        # Send email notification with report attachment
        send_email_report(ses, email_address, report_content, report_key)
        
        return {
            'statusCode': 200,
            'body': json.dumps(f'Report generated successfully: {report_key}')
        }
        
    except Exception as e:
        print(f"Error generating report: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error generating report: {str(e)}')
        }

def generate_report(sales_data, inventory_data):
    # Process sales data and calculate totals
    sales_reader = csv.DictReader(io.StringIO(sales_data))
    sales_summary = {}
    
    for row in sales_reader:
        product = row['Product']
        sales = int(row['Sales'])
        if product not in sales_summary:
            sales_summary[product] = 0
        sales_summary[product] += sales
    
    # Process inventory data and calculate totals
    inventory_reader = csv.DictReader(io.StringIO(inventory_data))
    inventory_summary = {}
    
    for row in inventory_reader:
        product = row['Product']
        stock = int(row['Stock'])
        if product not in inventory_summary:
            inventory_summary[product] = 0
        inventory_summary[product] += stock
    
    # Generate combined business report
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(['Product', 'Total Sales', 'Total Inventory', 'Sales Ratio'])
    
    for product in sales_summary:
        total_sales = sales_summary[product]
        total_inventory = inventory_summary.get(product, 0)
        sales_ratio = total_sales / total_inventory if total_inventory > 0 else 0
        writer.writerow([product, total_sales, total_inventory, f"{sales_ratio:.2f}"])
    
    return output.getvalue()

def send_email_report(ses, email_address, report_content, report_key):
    subject = f"Daily Business Report - {datetime.now().strftime('%Y-%m-%d')}"
    
    msg = MIMEMultipart()
    msg['From'] = email_address
    msg['To'] = email_address
    msg['Subject'] = subject
    
    body = f"""
Dear Team,

Please find attached the daily business report generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}.

Report includes:
- Sales summary by product
- Inventory levels by product
- Sales ratio analysis

This report has been automatically generated and stored in S3 at: {report_key}

Best regards,
Automated Reporting System
"""
    
    msg.attach(MIMEText(body, 'plain'))
    
    # Attach CSV report
    attachment = MIMEBase('application', 'octet-stream')
    attachment.set_payload(report_content.encode())
    encoders.encode_base64(attachment)
    attachment.add_header(
        'Content-Disposition',
        f'attachment; filename=daily_report_{datetime.now().strftime("%Y%m%d")}.csv'
    )
    msg.attach(attachment)
    
    # Send email using SES
    ses.send_raw_email(
        Source=email_address,
        Destinations=[email_address],
        RawMessage={'Data': msg.as_string()}
    )

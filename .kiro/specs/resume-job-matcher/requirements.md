# Requirements Document

## Introduction

The AI-Powered Resume-Job Matcher is a cloud-based platform designed to help Indian students optimize their job search during campus placements. The system analyzes student resumes, scrapes job postings from Indian job portals, uses AI to calculate match scores, and provides personalized recommendations for resume improvements and cover letter generation. The platform operates within a strict $10/month budget constraint using AWS free tier services and OpenAI API.

## Glossary

- **Resume_Parser**: Component that extracts structured data from uploaded resume files
- **Job_Scraper**: Component that collects job postings from external job portals
- **Match_Engine**: Component that calculates compatibility scores between resumes and jobs
- **Resume_Optimizer**: Component that generates resume improvement suggestions
- **Cover_Letter_Generator**: Component that creates tailored cover letters
- **Application_Tracker**: Component that records and monitors job application outcomes
- **Student_Profile**: Structured representation of student's skills, experience, and education
- **Job_Posting**: Structured representation of a job opportunity with requirements
- **Match_Score**: Numerical value (0-100) indicating resume-job compatibility
- **Job_Portal**: External website containing job listings (Naukri, LinkedIn, Internshala)
- **Storage_Service**: AWS S3 bucket for storing resumes and generated documents
- **Database_Service**: AWS DynamoDB for storing structured data
- **API_Gateway**: AWS service exposing backend functionality to frontend
- **Scheduler_Service**: AWS EventBridge for triggering periodic tasks
- **Email_Service**: AWS SES for sending notifications
- **AI_Service**: OpenAI API for natural language processing tasks

## Requirements

### Requirement 1: Resume Upload and Storage

**User Story:** As a student, I want to upload my resume, so that the system can analyze my qualifications and match me with relevant jobs.

#### Acceptance Criteria

1. WHEN a student uploads a PDF file, THE Storage_Service SHALL store the file with a unique identifier
2. WHEN a student uploads a DOCX file, THE Storage_Service SHALL store the file with a unique identifier
3. THE Storage_Service SHALL reject files larger than 5MB
4. THE Storage_Service SHALL reject files that are not PDF or DOCX format
5. WHEN a resume is successfully stored, THE Database_Service SHALL create a record linking the student to the resume identifier

### Requirement 2: Resume Parsing and Profile Extraction

**User Story:** As a student, I want my resume automatically analyzed, so that I don't have to manually enter my skills and experience.

#### Acceptance Criteria

1. WHEN a resume is uploaded, THE Resume_Parser SHALL extract the student's name, email, and phone number
2. WHEN a resume is uploaded, THE Resume_Parser SHALL extract all listed skills and technologies
3. WHEN a resume is uploaded, THE Resume_Parser SHALL extract work experience entries with company names, roles, and durations
4. WHEN a resume is uploaded, THE Resume_Parser SHALL extract education details including degree, institution, and graduation year
5. WHEN parsing is complete, THE Resume_Parser SHALL create a Student_Profile in the Database_Service
6. IF parsing fails, THEN THE Resume_Parser SHALL return an error message indicating which sections could not be extracted
7. THE Resume_Parser SHALL complete parsing within 30 seconds

### Requirement 3: Job Scraping from Multiple Sources

**User Story:** As a student, I want the system to automatically find relevant jobs from multiple portals, so that I don't have to manually search each website.

#### Acceptance Criteria

1. THE Job_Scraper SHALL collect job postings from Naukri.com daily
2. THE Job_Scraper SHALL collect job postings from LinkedIn India daily
3. THE Job_Scraper SHALL collect job postings from Internshala daily
4. WHEN scraping a Job_Portal, THE Job_Scraper SHALL extract job title, company name, location, required skills, experience level, and job description
5. WHEN scraping is complete, THE Job_Scraper SHALL store each Job_Posting in the Database_Service with a unique identifier
6. THE Job_Scraper SHALL mark duplicate job postings to avoid redundant processing
7. IF a Job_Portal is unavailable, THEN THE Job_Scraper SHALL log the error and continue with remaining portals
8. THE Scheduler_Service SHALL trigger the Job_Scraper once every 24 hours

### Requirement 4: AI-Powered Match Scoring

**User Story:** As a student, I want to see how well I match each job, so that I can prioritize applications for positions where I have the best chance.

#### Acceptance Criteria

1. WHEN a new Job_Posting is added, THE Match_Engine SHALL calculate a Match_Score against all Student_Profiles
2. THE Match_Engine SHALL compare required skills in the Job_Posting against skills in the Student_Profile
3. THE Match_Engine SHALL compare experience requirements against the student's work history
4. THE Match_Engine SHALL compare education requirements against the student's qualifications
5. THE Match_Engine SHALL generate a Match_Score between 0 and 100
6. WHEN calculating a Match_Score, THE Match_Engine SHALL generate an explanation describing why the score was assigned
7. THE Match_Engine SHALL store each Match_Score and explanation in the Database_Service
8. THE Match_Engine SHALL complete scoring for one student-job pair within 5 seconds

### Requirement 5: Match Results Display

**User Story:** As a student, I want to view my job matches ranked by score, so that I can quickly identify the best opportunities.

#### Acceptance Criteria

1. WHEN a student requests their matches, THE API_Gateway SHALL return Job_Postings sorted by Match_Score in descending order
2. THE API_Gateway SHALL include the Match_Score and explanation for each Job_Posting
3. THE API_Gateway SHALL support filtering matches by minimum Match_Score threshold
4. THE API_Gateway SHALL support filtering matches by location
5. THE API_Gateway SHALL support filtering matches by company name
6. THE API_Gateway SHALL return match results within 2 seconds

### Requirement 6: Resume Optimization Suggestions

**User Story:** As a student, I want personalized suggestions to improve my resume for specific jobs, so that I can increase my chances of getting interviews.

#### Acceptance Criteria

1. WHEN a student requests optimization for a specific Job_Posting, THE Resume_Optimizer SHALL analyze gaps between the Student_Profile and job requirements
2. THE Resume_Optimizer SHALL identify missing skills that appear in the Job_Posting
3. THE Resume_Optimizer SHALL suggest specific resume sections to emphasize based on job requirements
4. THE Resume_Optimizer SHALL recommend keywords to include for applicant tracking systems
5. THE Resume_Optimizer SHALL generate suggestions in plain language within 10 seconds
6. THE Resume_Optimizer SHALL store suggestions in the Database_Service linked to the student and Job_Posting

### Requirement 7: Tailored Cover Letter Generation

**User Story:** As a student, I want automatically generated cover letters customized for each job, so that I can save time while still personalizing my applications.

#### Acceptance Criteria

1. WHEN a student requests a cover letter for a specific Job_Posting, THE Cover_Letter_Generator SHALL create a personalized cover letter
2. THE Cover_Letter_Generator SHALL incorporate the student's relevant experience from the Student_Profile
3. THE Cover_Letter_Generator SHALL reference specific requirements from the Job_Posting
4. THE Cover_Letter_Generator SHALL maintain a professional tone appropriate for Indian job applications
5. THE Cover_Letter_Generator SHALL generate cover letters between 250 and 400 words
6. THE Cover_Letter_Generator SHALL complete generation within 15 seconds
7. THE Cover_Letter_Generator SHALL store the generated cover letter in the Storage_Service

### Requirement 8: Application Tracking

**User Story:** As a student, I want to track which jobs I've applied to and their outcomes, so that I can measure my success rate and improve my strategy.

#### Acceptance Criteria

1. WHEN a student marks a job as applied, THE Application_Tracker SHALL record the application date in the Database_Service
2. THE Application_Tracker SHALL allow students to update application status to "Applied", "Interview Scheduled", "Rejected", or "Offer Received"
3. WHEN a student requests their application history, THE Application_Tracker SHALL return all tracked applications with current status
4. THE Application_Tracker SHALL calculate the student's overall response rate as a percentage
5. THE Application_Tracker SHALL calculate average Match_Score for applications that resulted in interviews
6. THE Application_Tracker SHALL calculate average Match_Score for applications that resulted in rejections

### Requirement 9: Budget and Cost Management

**User Story:** As a student with limited funds, I want the system to operate within my $10/month budget, so that I can afford to use it throughout my job search.

#### Acceptance Criteria

1. THE Storage_Service SHALL use AWS S3 free tier for resume and document storage
2. THE Database_Service SHALL use AWS DynamoDB free tier for structured data storage
3. THE API_Gateway SHALL use AWS API Gateway free tier for API requests
4. THE Scheduler_Service SHALL use AWS EventBridge free tier for job scheduling
5. THE Email_Service SHALL use AWS SES free tier for notification emails
6. THE AI_Service SHALL limit OpenAI API calls to stay within $8/month budget
7. WHEN AI_Service usage approaches $8 for the current month, THE system SHALL queue non-urgent AI requests for the next billing cycle
8. THE system SHALL log all AWS service usage for cost monitoring

### Requirement 10: User Authentication and Data Security

**User Story:** As a student, I want my resume and personal information kept secure, so that my data is not exposed to unauthorized users.

#### Acceptance Criteria

1. WHEN a student creates an account, THE API_Gateway SHALL require a valid email address and password
2. THE API_Gateway SHALL hash passwords before storing them in the Database_Service
3. WHEN a student logs in, THE API_Gateway SHALL verify credentials and issue a session token
4. THE API_Gateway SHALL require a valid session token for all protected endpoints
5. THE Storage_Service SHALL restrict resume access to the owning student only
6. THE Database_Service SHALL restrict Student_Profile access to the owning student only
7. THE API_Gateway SHALL expire session tokens after 24 hours of inactivity

### Requirement 11: Daily Job Scraping Scheduler

**User Story:** As a student, I want new jobs automatically discovered every day, so that I don't miss recent opportunities.

#### Acceptance Criteria

1. THE Scheduler_Service SHALL trigger the Job_Scraper at 6:00 AM IST daily
2. WHEN the Job_Scraper completes successfully, THE Scheduler_Service SHALL log the completion time and job count
3. IF the Job_Scraper fails, THEN THE Scheduler_Service SHALL retry after 1 hour
4. THE Scheduler_Service SHALL trigger match scoring after job scraping completes
5. WHEN new matches above 70% are found, THE Email_Service SHALL send a notification email to the student

### Requirement 12: Email Notifications

**User Story:** As a student, I want email notifications for high-quality matches, so that I can apply quickly to promising opportunities.

#### Acceptance Criteria

1. WHEN a new Job_Posting has a Match_Score above 70% for a student, THE Email_Service SHALL send a notification email
2. THE Email_Service SHALL include the job title, company name, Match_Score, and a link to view details
3. THE Email_Service SHALL batch notifications to send at most one email per day per student
4. WHERE a student has disabled notifications, THE Email_Service SHALL not send emails to that student
5. THE Email_Service SHALL use the student's email address from their Student_Profile

### Requirement 13: Frontend User Interface

**User Story:** As a student, I want an intuitive web interface, so that I can easily navigate the platform and access all features.

#### Acceptance Criteria

1. THE frontend SHALL display a dashboard showing total matches, applications, and response rate
2. THE frontend SHALL display a list of Job_Postings with Match_Scores and filtering options
3. WHEN a student clicks a Job_Posting, THE frontend SHALL display full job details and match explanation
4. THE frontend SHALL provide buttons to request resume optimization and cover letter generation
5. THE frontend SHALL display application tracking history with status updates
6. THE frontend SHALL allow students to upload a new resume
7. THE frontend SHALL display loading indicators while AI operations are in progress
8. THE frontend SHALL be responsive and functional on mobile devices

### Requirement 14: Error Handling and Logging

**User Story:** As a system administrator, I want comprehensive error logging, so that I can troubleshoot issues and maintain system reliability.

#### Acceptance Criteria

1. WHEN any component encounters an error, THE system SHALL log the error message, timestamp, and stack trace
2. THE system SHALL log all API requests with endpoint, user identifier, and response time
3. THE system SHALL log all Job_Scraper runs with success/failure status and job counts
4. THE system SHALL log all AI_Service API calls with token usage and cost
5. IF the Database_Service is unavailable, THEN THE system SHALL return a user-friendly error message
6. IF the AI_Service is unavailable, THEN THE system SHALL queue the request and notify the student
7. THE system SHALL retain logs for 30 days

### Requirement 15: System Performance and Scalability

**User Story:** As a student, I want fast response times, so that I can efficiently browse jobs and generate documents.

#### Acceptance Criteria

1. THE API_Gateway SHALL respond to dashboard requests within 1 second
2. THE API_Gateway SHALL respond to job list requests within 2 seconds
3. THE Database_Service SHALL support at least 100 concurrent student users
4. THE Job_Scraper SHALL process at least 500 job postings per scraping session
5. THE Match_Engine SHALL score at least 50 student-job pairs per minute
6. THE Storage_Service SHALL support storing at least 1000 resumes
7. THE system SHALL handle at least 10 concurrent cover letter generation requests

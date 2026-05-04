---
name: AI-Powered Resume-Job Matcher
status: requirements
created: 2025-03-11
updated: 2025-03-11
---

# AI-Powered Resume-Job Matcher

## Project Overview

A cloud-based platform that helps students and job seekers find the best-matching jobs by analyzing their resume against available job postings using AI. The system scrapes job listings from multiple sources, scores each match, and provides personalized recommendations with resume optimization suggestions.

**Target Users:** Students and early-career professionals in India
**Budget:** $10/month maximum
**Timeline:** 5-6 weeks
**Tech Focus:** AWS Cloud + AI/ML

---

## Requirements

### 1. Core Features

#### 1.1 Resume Management
- [ ] Users can upload resume (PDF/DOCX format)
- [ ] System extracts text and parses key information:
  - Skills (technical and soft skills)
  - Experience (years, companies, roles)
  - Education (degree, college, graduation year)
  - Projects and achievements
  - Certifications
- [ ] Users can edit/update parsed information
- [ ] Support for multiple resume versions
- [ ] Resume stored securely in cloud storage

#### 1.2 Job Scraping & Aggregation
- [ ] Scrape jobs from multiple sources:
  - Naukri.com (primary source)
  - LinkedIn Jobs (if feasible)
  - AngelList/Wellfound (startup jobs)
  - Company career pages (optional)
- [ ] Extract job details:
  - Job title and description
  - Required skills
  - Experience level
  - Company name and location
  - Salary range (if available)
  - Application deadline
  - Job posting URL
- [ ] Run scraping daily/weekly (configurable)
- [ ] Store jobs in database with deduplication
- [ ] Filter jobs by:
  - Location (remote, specific cities)
  - Experience level (0-2 years for freshers)
  - Job type (full-time, internship, contract)

#### 1.3 AI-Powered Matching
- [ ] Calculate match score (0-100%) for each job:
  - Skills overlap (weighted heavily)
  - Experience level match
  - Education requirements
  - Location preference
  - Job description keyword analysis
- [ ] Provide match explanation:
  - "You match 8/10 required skills"
  - "Missing: React, Docker"
  - "Your Python experience is a strong fit"
- [ ] Rank jobs by match score
- [ ] Filter by minimum match threshold (e.g., show only 60%+ matches)

#### 1.4 Resume Optimization
- [ ] For each high-match job (70%+ score):
  - Suggest resume modifications
  - Highlight which skills to emphasize
  - Recommend adding missing keywords
  - Generate tailored resume bullet points
- [ ] AI generates job-specific cover letter template
- [ ] Show before/after resume comparison

#### 1.5 User Dashboard
- [ ] Display top 20 matched jobs
- [ ] Show match score with visual indicator (color-coded)
- [ ] Quick apply links to job postings
- [ ] Track application status:
  - Not applied
  - Applied
  - Interview scheduled
  - Rejected
  - Offer received
- [ ] Analytics:
  - Total jobs matched
  - Applications sent
  - Response rate
  - Average match score

#### 1.6 Notifications
- [ ] Email notifications for:
  - New high-match jobs (80%+ score)
  - Daily/weekly job digest
  - Application deadline reminders
- [ ] Configurable notification preferences

---

### 2. Technical Requirements

#### 2.1 AWS Services (Free Tier Focus)
- [ ] **S3:** Store resumes and scraped job data
- [ ] **Lambda:** Serverless functions for:
  - Resume parsing
  - Job scraping
  - Match scoring
  - API endpoints
- [ ] **DynamoDB:** Store user profiles, jobs, match scores
- [ ] **API Gateway:** REST API for frontend
- [ ] **EventBridge/CloudWatch:** Schedule daily job scraping
- [ ] **SES:** Send email notifications
- [ ] **Cognito:** User authentication (optional for MVP)

#### 2.2 AI/ML Integration
- [ ] **OpenAI API (GPT-4o-mini):** 
  - Resume parsing and skill extraction
  - Match scoring and explanation
  - Resume optimization suggestions
  - Cover letter generation
- [ ] Cost optimization:
  - Use smaller models where possible
  - Cache common responses
  - Batch API calls
  - Target: $5-8/month for OpenAI

#### 2.3 Web Scraping
- [ ] Use Python libraries:
  - BeautifulSoup4 for HTML parsing
  - Requests for HTTP calls
  - Selenium (if needed for dynamic content)
- [ ] Implement rate limiting and respectful scraping
- [ ] Handle anti-scraping measures (user agents, delays)
- [ ] Error handling for failed scrapes

#### 2.4 Frontend
- [ ] Simple React web app (or static HTML/JS for MVP)
- [ ] Responsive design (mobile-friendly)
- [ ] Hosted on S3 + CloudFront (optional)
- [ ] Key pages:
  - Upload resume
  - Dashboard (matched jobs)
  - Job details with match explanation
  - Profile settings

---

### 3. User Stories

#### As a job seeker, I want to:
1. Upload my resume once and get matched with relevant jobs automatically
2. See why each job is a good/bad match for me
3. Get suggestions on how to improve my resume for specific jobs
4. Track which jobs I've applied to and their status
5. Receive notifications when high-match jobs are posted
6. Save time by not manually searching through hundreds of irrelevant jobs

#### As the system, I need to:
1. Scrape jobs daily without getting blocked
2. Parse resumes accurately to extract skills and experience
3. Calculate meaningful match scores using AI
4. Store data efficiently within free tier limits
5. Send timely notifications without spamming users
6. Handle errors gracefully (failed scrapes, API limits)

---

### 4. Success Metrics

#### MVP Success Criteria:
- [ ] Successfully scrape 100+ jobs daily from at least 2 sources
- [ ] Parse resume with 90%+ accuracy for skills extraction
- [ ] Generate match scores for all jobs within 5 seconds
- [ ] Send daily email digest with top 10 matches
- [ ] Stay within $10/month budget
- [ ] Handle 10-20 concurrent users (for demo/portfolio)

#### Future Enhancements (Post-MVP):
- Multi-user support with authentication
- Job application tracking with company feedback
- Interview preparation suggestions based on job requirements
- Salary negotiation insights
- Chrome extension for one-click job saving
- Mobile app (React Native)

---

### 5. Constraints & Assumptions

#### Constraints:
- Budget: Maximum $10/month
- Timeline: 5-6 weeks to MVP
- Free tier: Must maximize AWS free tier usage
- Scraping: Must respect robots.txt and rate limits
- Data: No personal data storage beyond resume (GDPR-like considerations)

#### Assumptions:
- Users have resumes in PDF/DOCX format
- Job sites allow scraping (or have public APIs)
- OpenAI API costs stay within $5-8/month for moderate usage
- Users check dashboard at least weekly
- Initial user base: 1-10 users (portfolio/demo)

---

### 6. Out of Scope (For MVP)

- ❌ Real-time job alerts (push notifications)
- ❌ Video resume analysis
- ❌ Interview scheduling integration
- ❌ Salary comparison tools
- ❌ Company reviews/ratings
- ❌ Referral request features
- ❌ Mobile app
- ❌ Multi-language support
- ❌ Advanced analytics (ML-based career path suggestions)

---

## Next Steps

1. ✅ Requirements defined
2. ⏳ Design architecture and data models
3. ⏳ Break down into implementation tasks
4. ⏳ Build and test MVP
5. ⏳ Deploy to AWS
6. ⏳ Create documentation and demo

---

## Questions to Resolve

1. **Job Sources:** Start with Naukri only, or add LinkedIn from day 1?
2. **Authentication:** Use AWS Cognito or simple email-based access for MVP?
3. **Resume Parsing:** Use OpenAI or open-source library (pyresparser)?
4. **Matching Algorithm:** Pure AI-based or hybrid (keyword + AI)?
5. **Notification Frequency:** Daily digest or real-time for high matches?

**Please review and provide feedback on these requirements before we move to design phase.**

# Navigate to the AI-Resume-Job-Matcher directory
Set-Location "C:\Users\hp\Downloads\s\AI-Resume-Job-Matcher"

# Copy new files
Copy-Item -Path "..\automated-report-generation-eventbridge\AI-Resume-Job-Matcher-Files\docs" -Destination "." -Recurse -Force
Copy-Item -Path "..\automated-report-generation-eventbridge\AI-Resume-Job-Matcher-Files\backend" -Destination "." -Recurse -Force

# Commit architecture documentation
git add docs/ARCHITECTURE.md
git commit -m "Add system architecture documentation"

# Commit backend configuration
git add backend/requirements.txt
git commit -m "Add Python dependencies for backend"

git add backend/config.py
git commit -m "Add configuration settings for AWS and OpenAI"

# Push all commits
git push origin master

Write-Host "New files committed and pushed successfully!"

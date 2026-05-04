# Navigate to the AI-Resume-Job-Matcher directory
Set-Location "C:\Users\hp\Downloads\s\AI-Resume-Job-Matcher"

# Commit each file separately
git add README.md
git commit -m "Add project README with overview and features"

git add .gitignore
git commit -m "Add gitignore for Python and AWS projects"

git add LICENSE
git commit -m "Add MIT license"

git add REQUIREMENTS.md
git commit -m "Add detailed requirements documentation"

# Push all commits
git push origin main

Write-Host "All files committed and pushed successfully!"

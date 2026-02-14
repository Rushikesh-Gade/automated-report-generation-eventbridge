# Contributing to AWS EventBridge Report Automation

Thank you for your interest in contributing to this project! This document provides guidelines for contributions.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in the [Issues](../../issues) section
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs. actual behavior
   - Your environment (AWS region, Python version, etc.)
   - Screenshots if applicable

### Suggesting Enhancements

We welcome enhancement suggestions! Please:

1. Check existing issues and pull requests first
2. Create an issue describing:
   - The enhancement and its benefits
   - Potential implementation approach
   - Any breaking changes

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/aws-eventbridge-report-automation.git
   cd aws-eventbridge-report-automation
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation as needed

4. **Test your changes**
   - Test locally with your AWS account
   - Verify no breaking changes
   - Check for security issues

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add: Brief description of changes"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Provide a clear description of changes
   - Reference any related issues
   - Include screenshots if UI changes

## Development Guidelines

### Code Style

- **Python:** Follow PEP 8 style guide
- **Comments:** Use clear, concise comments
- **Functions:** Keep functions small and focused
- **Error Handling:** Always include try-catch blocks

### AWS Best Practices

- Use least-privilege IAM policies
- Implement proper error handling
- Add CloudWatch logging
- Consider cost optimization
- Follow AWS Well-Architected Framework

### Documentation

- Update README.md for new features
- Add inline code comments
- Update PROJECT_DOCUMENTATION.md for architecture changes
- Include examples for new functionality

### Testing

Before submitting:

- [ ] Code runs without errors
- [ ] Lambda function executes successfully
- [ ] Reports are generated correctly
- [ ] Emails are sent properly
- [ ] IAM permissions are minimal
- [ ] Documentation is updated

## Enhancement Ideas

Looking for contribution ideas? Check out:

- [ ] Add PDF report generation
- [ ] Implement multiple report schedules
- [ ] Add data visualization with charts
- [ ] Create Terraform/CDK templates
- [ ] Add unit tests
- [ ] Implement SNS notifications
- [ ] Add QuickSight integration
- [ ] Create CI/CD pipeline
- [ ] Add multi-region support
- [ ] Implement report customization

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the project
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Personal or political attacks
- Publishing others' private information
- Unprofessional conduct

## Questions?

Feel free to:
- Open an issue for questions
- Reach out via email
- Start a discussion in the Discussions tab

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing! 🎉

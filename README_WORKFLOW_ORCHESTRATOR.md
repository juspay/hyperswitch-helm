# Claude Code Workflow Orchestrator (Google Vertex AI)

This Python script orchestrates a complete development workflow using Claude via Google Vertex AI for automated issue generation, development, code review, and PR creation.

## Workflow Overview

```
Feature Request → Issue Generator → Dev Agent → Reviewer Agent → Dev Agent (feedback loop) → PR Creation
```

## Features

- **Issue Generator**: Uses `helm-github-issue-creator` agent to create comprehensive GitHub issues
- **Development**: Uses `helm-chart-architect` agent to implement features in Helm charts
- **Code Review**: Uses `helm-chart-reviewer` agent for thorough code review
- **Iterative Feedback**: Automatic feedback loop between dev and reviewer agents
- **PR Management**: Automated branch creation, pushing, and PR creation

## Prerequisites

1. **Google Cloud Project**: Access to Google Vertex AI with Claude models enabled
2. **Google Cloud Authentication**: Set up Application Default Credentials (ADC)
3. **GitHub CLI**: Install and configure `gh` CLI for issue and PR management
4. **Git Repository**: Run from within a git repository
5. **Python Dependencies**: Install required packages

## Setup

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Set up Google Cloud authentication:
```bash
# Option 1: Service Account Key (recommended for production)
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"

# Option 2: User Account (for development)
gcloud auth application-default login
```

3. Set up environment variables (using your existing configuration):
```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=dev-ai-delta
```

4. Enable Vertex AI API and Claude models:
```bash
gcloud services enable aiplatform.googleapis.com
```

5. Ensure GitHub CLI is configured:
```bash
gh auth login
```

## Usage

### Basic Usage

```bash
python claude_workflow_orchestrator.py "Add support for custom annotations in Helm charts"
```

### Interactive Mode

```bash
python claude_workflow_orchestrator.py
# Will prompt for feature description
```

### Advanced Configuration

You can modify the `WorkflowConfig` in the script to customize:

- `base_branch`: Base branch for PRs (default: "main")
- `max_review_iterations`: Maximum review cycles (default: 3)
- `agent_timeout`: Timeout for agent responses (default: 300 seconds)

## Workflow Steps

### 1. Issue Generation
- Uses `helm-github-issue-creator` agent
- Creates comprehensive GitHub issue with:
  - Clear title and description
  - Acceptance criteria
  - Technical considerations
  - Appropriate labels

### 2. Branch Creation
- Creates feature branch with sanitized name
- Ensures base branch is up to date
- Switches to new development branch

### 3. Initial Development
- Uses `helm-chart-architect` agent
- Implements feature following Helm best practices
- Makes atomic commits with clear messages
- Focuses on:
  - Chart template modifications
  - Values.yaml updates
  - Documentation updates
  - Backwards compatibility

### 4. Review and Iteration
- Uses `helm-chart-reviewer` agent for code review
- Reviews focus on:
  - Helm chart best practices
  - Kubernetes resource correctness
  - Security considerations
  - Documentation completeness
  - Code quality

- **Feedback Loop**: If review is not approved:
  - Reviewer provides detailed feedback
  - Dev agent applies feedback
  - Process repeats up to `max_review_iterations`

### 5. PR Creation
- Pushes branch to remote repository
- Creates GitHub PR with:
  - Descriptive title from issue
  - Comprehensive body with commits and test plan
  - Links to related issue
  - Claude Code attribution

## Example Output

```
🚀 Starting Claude Code workflow orchestration...

📝 Step 1: Generating GitHub issue...
✅ Issue created: https://github.com/user/repo/issues/123

🌿 Step 2: Creating development branch...
✅ Branch created: feature/add-custom-annotations-support

⚡ Step 3: Initial development on branch 'feature/add-custom-annotations-support'...
✅ Initial implementation completed

🔍 Step 4: Starting review and iteration process...
   🔄 Review iteration 1/3
   📝 Applying reviewer feedback...
   🔄 Review iteration 2/3
   ✅ Review approved on iteration 2

🚀 Step 5: Creating pull request...
✅ PR created: https://github.com/user/repo/pull/124

✅ Workflow completed successfully!
📄 Issue: https://github.com/user/repo/issues/123
🌿 Branch: feature/add-custom-annotations-support
🔗 PR: https://github.com/user/repo/pull/124
```

## Error Handling

- **Network Issues**: Retries with exponential backoff
- **Git Conflicts**: Automatic cleanup and base branch restoration
- **Agent Timeouts**: Configurable timeout with fallback behaviors
- **Review Failures**: Maximum iteration limits prevent infinite loops

## Customization

### Agent Prompts
Modify the prompts in each agent method to customize behavior:
- `_generate_issue()`: Issue generation prompts
- `_run_dev_agent()`: Development implementation prompts  
- `_run_reviewer_agent()`: Code review criteria and prompts

### Workflow Logic
Extend the workflow by:
- Adding additional agent types
- Implementing custom validation steps
- Adding notification systems
- Integrating with CI/CD pipelines

## Troubleshooting

### Common Issues

1. **Google Cloud Authentication Issues**:
```bash
# Verify project is set
echo $ANTHROPIC_VERTEX_PROJECT_ID

# Check authentication status
gcloud auth list

# Test Vertex AI access
gcloud ai models list --region=$CLOUD_ML_REGION
```

2. **GitHub CLI Issues**:
```bash
# Check authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

3. **Git Repository Issues**:
```bash
# Ensure you're in a git repository
git status

# Check remote configuration
git remote -v
```

4. **Permission Issues**:
- Ensure GitHub token has repository write permissions
- Verify branch protection rules allow pushes

### Debug Mode

Enable debug logging by modifying the script:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## Security Considerations

- **Service Account Keys**: Never commit service account keys to version control
- **IAM Permissions**: Use minimal required permissions for Vertex AI access
- **GitHub Tokens**: Use tokens with minimal required permissions
- **Code Review**: Always review generated code before merging
- **Branch Protection**: Consider requiring manual review for AI-generated PRs
- **Data Privacy**: Be aware that code will be sent to Google Cloud/Anthropic for processing

## Contributing

To extend this orchestrator:

1. Follow the existing async/await patterns
2. Add comprehensive error handling
3. Update the todo tracking system
4. Add appropriate logging
5. Test with various feature descriptions

## License

This workflow orchestrator follows the same license as the hyperswitch-helm repository.
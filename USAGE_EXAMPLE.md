# Quick Usage Guide

## Your Current Configuration

You already have Vertex AI configured with these environment variables:

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=dev-ai-delta
```

## Quick Start

1. **Install dependencies:**
```bash
pip install -r requirements.txt
```

2. **Ensure GitHub CLI is configured:**
```bash
gh auth login
```

3. **Run the workflow:**
```bash
python claude_workflow_orchestrator.py "Add support for custom Pod annotations in Helm charts"
```

## Example Workflow

```bash
# Example: Add a new feature to the Helm charts
python claude_workflow_orchestrator.py "Add ConfigMap support for application configuration files"

# The script will:
# 1. Generate a GitHub issue
# 2. Create a feature branch
# 3. Implement the feature using helm-chart-architect agent
# 4. Review the code using helm-chart-reviewer agent
# 5. Iterate on feedback if needed
# 6. Create and push a pull request
```

## Expected Output

```
🚀 Starting Claude Code workflow orchestration...

📝 Step 1: Generating GitHub issue...
✅ Issue created: https://github.com/juspay/hyperswitch-helm/issues/176

🌿 Step 2: Creating development branch...
✅ Branch created: feature/add-configmap-support-for-application

⚡ Step 3: Initial development on branch 'feature/add-configmap-support-for-application'...
✅ Initial implementation completed

🔍 Step 4: Starting review and iteration process...
   🔄 Review iteration 1/3
   📝 Applying reviewer feedback...
   🔄 Review iteration 2/3
   ✅ Review approved on iteration 2

🚀 Step 5: Creating pull request...
✅ PR created: https://github.com/juspay/hyperswitch-helm/pull/177

✅ Workflow completed successfully!
📄 Issue: https://github.com/juspay/hyperswitch-helm/issues/176
🌿 Branch: feature/add-configmap-support-for-application
🔗 PR: https://github.com/juspay/hyperswitch-helm/pull/177
```

## Troubleshooting

If you get authentication errors:

```bash
# Check your configuration
echo $ANTHROPIC_VERTEX_PROJECT_ID  # Should be: dev-ai-delta
echo $CLOUD_ML_REGION              # Should be: us-east5
echo $CLAUDE_CODE_USE_VERTEX       # Should be: 1

# Re-authenticate if needed
gcloud auth application-default login
```

## Cost Estimation

With your Vertex AI setup, each workflow run typically costs:
- **Simple features**: $0.30 - $0.50
- **Complex features**: $0.50 - $1.00
- **Features requiring multiple review iterations**: $0.80 - $1.50

This is based on Claude 3.5 Sonnet pricing in us-east5 region.
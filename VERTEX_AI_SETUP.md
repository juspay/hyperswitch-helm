# Google Vertex AI Setup Guide

This guide walks you through setting up Google Vertex AI to use Claude models for the workflow orchestrator.

## Prerequisites

- Google Cloud Project with billing enabled
- Google Cloud CLI (`gcloud`) installed
- Appropriate IAM permissions

## Step 1: Enable Required APIs

```bash
# Enable Vertex AI API
gcloud services enable aiplatform.googleapis.com

# Enable Cloud Resource Manager API (if not already enabled)
gcloud services enable cloudresourcemanager.googleapis.com
```

## Step 2: Set Up Authentication

### Option A: Service Account (Recommended for Production)

1. Create a service account:
```bash
gcloud iam service-accounts create claude-workflow-orchestrator \
    --description="Service account for Claude workflow orchestrator" \
    --display-name="Claude Workflow Orchestrator"
```

2. Grant necessary permissions:
```bash
# Basic Vertex AI access
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:claude-workflow-orchestrator@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"

# Optional: If you need to create custom models or endpoints
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:claude-workflow-orchestrator@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
    --role="roles/aiplatform.admin"
```

3. Create and download service account key:
```bash
gcloud iam service-accounts keys create ~/claude-workflow-key.json \
    --iam-account=claude-workflow-orchestrator@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
```

4. Set environment variable:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/claude-workflow-key.json"
```

### Option B: User Account (For Development)

```bash
# Authenticate with your user account
gcloud auth application-default login

# Ensure you have the necessary roles
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="user:your-email@domain.com" \
    --role="roles/aiplatform.user"
```

## Step 3: Configure Claude Model Access

### Check Available Models

```bash
# List available models in your region
gcloud ai models list --region=us-central1 --filter="displayName~claude"

# If no Claude models are shown, you may need to request access
```

### Request Claude Model Access

If Claude models are not available in your project:

1. Contact Google Cloud Support or your account manager
2. Request access to Anthropic Claude models on Vertex AI
3. Specify which Claude model versions you need:
   - `claude-3-5-sonnet@20241022` (recommended)
   - `claude-3-haiku@20240307` (faster, less capable)
   - `claude-3-opus@20240229` (most capable, slower)

### Regional Availability

Claude models are available in specific regions. Check current availability:

- `us-central1` (Iowa) - Primary region
- `us-east4` (Northern Virginia)
- `europe-west1` (Belgium)
- `asia-southeast1` (Singapore)

Set your preferred region:
```bash
export GOOGLE_CLOUD_LOCATION="us-central1"
```

## Step 4: Test Setup

Create a test script to verify everything works:

```python
import vertexai
from vertexai.generative_models import GenerativeModel
import os

# Initialize Vertex AI
project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
location = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")

vertexai.init(project=project_id, location=location)

# Test Claude model
model = GenerativeModel("claude-3-5-sonnet@20241022")
response = model.generate_content("Hello, are you working correctly?")
print(response.text)
```

Run the test:
```bash
python test_vertex_ai.py
```

## Step 5: Environment Variables

Add these to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
# Required
export GOOGLE_CLOUD_PROJECT="your-project-id"

# Optional (defaults to us-central1)
export GOOGLE_CLOUD_LOCATION="us-central1"

# If using service account
export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account-key.json"
```

## Pricing Considerations

Claude on Vertex AI pricing (as of 2024):

### Claude 3.5 Sonnet
- Input: $3.00 per 1M tokens
- Output: $15.00 per 1M tokens

### Claude 3 Haiku
- Input: $0.25 per 1M tokens  
- Output: $1.25 per 1M tokens

### Cost Estimation for Workflow

Typical workflow costs:
- Issue generation: ~1,000 tokens input, ~2,000 tokens output
- Development: ~3,000 tokens input, ~8,000 tokens output  
- Review: ~5,000 tokens input, ~3,000 tokens output
- Feedback iteration: ~3,000 tokens input, ~5,000 tokens output (per iteration)

**Estimated cost per workflow: $0.30 - $0.80** (depending on complexity and iterations)

## IAM Roles Reference

### Minimal Permissions
```yaml
roles/aiplatform.user:
  - aiplatform.endpoints.predict
  - aiplatform.models.predict
```

### Extended Permissions (if needed)
```yaml
roles/aiplatform.admin:
  - Full access to Vertex AI resources
  - Ability to create/manage models and endpoints
```

## Troubleshooting

### "Model not found" Error
```
Publisher Model `claude-3-5-sonnet@20241022` was not found
```

**Solutions:**
1. Check if you have access to Claude models in your project
2. Verify the model name and version
3. Ensure you're using the correct region
4. Contact Google Cloud Support for model access

### Authentication Errors
```
google.auth.exceptions.DefaultCredentialsError
```

**Solutions:**
1. Run `gcloud auth application-default login`
2. Check `GOOGLE_APPLICATION_CREDENTIALS` path
3. Verify service account permissions

### Permission Denied
```
Permission 'aiplatform.endpoints.predict' denied
```

**Solutions:**
1. Add `roles/aiplatform.user` role to your account/service account
2. Check project billing is enabled
3. Verify APIs are enabled

## Additional Resources

- [Vertex AI Documentation](https://cloud.google.com/vertex-ai/docs)
- [Claude on Vertex AI](https://cloud.google.com/vertex-ai/generative-ai/docs/partner-models/use-claude)
- [Vertex AI Python SDK](https://cloud.google.com/python/docs/reference/aiplatform/latest)
- [Google Cloud IAM](https://cloud.google.com/iam/docs)

## Support

For issues with:
- **Google Cloud**: Contact Google Cloud Support
- **Claude Models**: Contact Anthropic or Google Cloud Support  
- **Workflow Script**: Create an issue in this repository
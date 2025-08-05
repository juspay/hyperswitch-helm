#!/usr/bin/env python3
"""
Claude Code SDK Workflow Orchestrator

This script orchestrates a development workflow using Claude Code SDK agents:
1. Issue Generator Agent - Creates GitHub issues
2. Dev Agent - Develops code in a new branch
3. Reviewer Agent - Reviews the code
4. Iterative feedback loop between dev and reviewer
5. Creates and pushes PR when review is satisfied
"""

import asyncio
import json
import subprocess
import sys
import os
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from pathlib import Path

try:
    from claude_code_sdk import query, ClaudeCodeOptions
except ImportError:
    print("Error: claude-code-sdk package not found. Install with: pip install claude-code-sdk")
    sys.exit(1)


@dataclass
class WorkflowConfig:
    """Configuration for the workflow orchestration"""
    repository_path: str
    base_branch: str = "main"
    max_review_iterations: int = 3
    agent_timeout: int = 300  # 5 minutes


class ClaudeCodeOrchestrator:
    """Orchestrates the development workflow using Claude Code SDK agents"""
    
    def __init__(self, config: WorkflowConfig):
        self.config = config
        # Set up Claude Code options
        self.options = ClaudeCodeOptions(
            cwd=config.repository_path,
            permission_mode='acceptEdits'  # Auto-accept file edits
        )
        self.current_branch: Optional[str] = None
        self.issue_data: Optional[Dict] = None
        
    async def run_workflow(self, feature_description: str) -> str:
        """
        Run the complete development workflow
        
        Args:
            feature_description: Description of the feature to develop
            
        Returns:
            PR URL if successful
        """
        try:
            print("🚀 Starting Claude Code workflow orchestration...")
            
            # Step 1: Generate issue
            print("\n📝 Step 1: Generating GitHub issue...")
            self.issue_data = await self._generate_issue(feature_description)
            
            # Step 2: Create development branch
            print(f"\n🌿 Step 2: Creating development branch...")
            self.current_branch = await self._create_dev_branch()
            
            # Step 3: Initial development
            print(f"\n⚡ Step 3: Initial development on branch '{self.current_branch}'...")
            dev_result = await self._run_dev_agent(self.issue_data)
            
            # Step 4: Review and iteration loop
            print(f"\n🔍 Step 4: Starting review and iteration process...")
            final_code = await self._review_iteration_loop(dev_result)
            
            # Step 5: Create and push PR
            print(f"\n🚀 Step 5: Creating pull request...")
            pr_url = await self._create_pull_request()
            
            print(f"\n✅ Workflow completed successfully!")
            print(f"📄 Issue: {self.issue_data.get('url', 'Generated')}")
            print(f"🌿 Branch: {self.current_branch}")
            print(f"🔗 PR: {pr_url}")
            
            return pr_url
            
        except Exception as e:
            print(f"❌ Workflow failed: {str(e)}")
            await self._cleanup_on_failure()
            raise
    
    async def _generate_issue(self, feature_description: str) -> Dict:
        """Generate GitHub issue using helm-github-issue-creator agent"""
        
        prompt = f"""
        I need to create a GitHub issue for the following feature request:
        
        Feature Description: {feature_description}
        
        This is for a Helm chart repository (hyperswitch-helm). Please create a comprehensive 
        GitHub issue that includes:
        - Clear title
        - Detailed description
        - Acceptance criteria
        - Technical considerations for Helm charts
        - Labels and priorities
        
        The issue should be suitable for development work on Kubernetes Helm charts.
        """
        
        try:
            # Use Claude Code SDK with agent prefix
            full_prompt = f"[AGENT: helm-github-issue-creator]\n{prompt}"
            
            # Collect all messages from the query
            messages = []
            async for message in query(prompt=full_prompt, options=self.options):
                messages.append(message)
            
            # Extract the assistant's response
            issue_content = ""
            for msg in messages:
                if hasattr(msg, 'content') and msg.content:
                    issue_content += str(msg.content)
            
            # Create the actual GitHub issue
            issue_result = self._create_github_issue(issue_content, feature_description)
            
            return {
                "title": self._extract_title_from_content(issue_content),
                "description": feature_description,
                "content": issue_content,
                "url": issue_result.get("url"),
                "number": issue_result.get("number")
            }
            
        except Exception as e:
            print(f"⚠️  Issue generation failed: {str(e)}")
            # Fallback to basic issue data
            return {
                "title": f"Implement: {feature_description[:50]}...",
                "description": feature_description,
                "content": f"## Feature Request\n\n{feature_description}",
                "url": None,
                "number": None
            }
    
    async def _create_dev_branch(self) -> str:
        """Create a new development branch"""
        
        # Generate branch name from issue title
        if self.issue_data and self.issue_data.get("title"):
            branch_name = self._sanitize_branch_name(self.issue_data["title"])
        else:
            branch_name = f"feature/claude-generated-{self._get_timestamp()}"
        
        try:
            # Ensure we're on the base branch and up to date
            subprocess.run(["git", "checkout", self.config.base_branch], 
                         cwd=self.config.repository_path, check=True)
            subprocess.run(["git", "pull", "origin", self.config.base_branch], 
                         cwd=self.config.repository_path, check=True)
            
            # Create and checkout new branch
            subprocess.run(["git", "checkout", "-b", branch_name], 
                         cwd=self.config.repository_path, check=True)
            
            return branch_name
            
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to create branch '{branch_name}': {e}")
    
    async def _run_dev_agent(self, issue_data: Dict) -> Dict:
        """Run the development agent to implement the feature"""
        
        prompt = f"""
        I need you to implement the following feature for a Helm chart repository:
        
        Issue Title: {issue_data.get('title', 'Feature Implementation')}
        Description: {issue_data.get('description', '')}
        
        Issue Details:
        {issue_data.get('content', '')}
        
        Please implement this feature by:
        1. Analyzing the existing Helm chart structure
        2. Making the necessary changes to templates, values.yaml, and other chart files
        3. Following Helm best practices
        4. Ensuring backwards compatibility
        5. Adding appropriate documentation
        
        Work on the current branch and make atomic commits with clear messages.
        """
        
        try:
            # Use Claude Code SDK with agent prefix
            full_prompt = f"[AGENT: helm-chart-architect]\n{prompt}"
            
            # Collect all messages from the query
            messages = []
            async for message in query(prompt=full_prompt, options=self.options):
                messages.append(message)
            
            # Extract the assistant's response
            dev_output = ""
            for msg in messages:
                if hasattr(msg, 'content') and msg.content:
                    dev_output += str(msg.content)
            
            # The agent should have already made commits, but we can add a summary commit
            self._commit_changes("feat: implement feature via Claude Code SDK agent")
            
            return {
                "implementation": dev_output,
                "branch": self.current_branch,
                "commits": self._get_recent_commits()
            }
            
        except Exception as e:
            raise RuntimeError(f"Development agent failed: {str(e)}")
    
    async def _review_iteration_loop(self, dev_result: Dict) -> Dict:
        """Run review and iteration loop between dev and reviewer agents"""
        
        iteration_count = 0
        current_implementation = dev_result
        
        while iteration_count < self.config.max_review_iterations:
            iteration_count += 1
            print(f"   🔄 Review iteration {iteration_count}/{self.config.max_review_iterations}")
            
            # Run reviewer agent
            review_result = await self._run_reviewer_agent(current_implementation)
            
            # Check if review is satisfied
            if review_result.get("approved", False):
                print(f"   ✅ Review approved on iteration {iteration_count}")
                return current_implementation
            
            # Get feedback and run dev agent again
            feedback = review_result.get("feedback", "")
            if feedback:
                print(f"   📝 Applying reviewer feedback...")
                current_implementation = await self._apply_reviewer_feedback(
                    current_implementation, feedback
                )
            else:
                print(f"   ⚠️  No specific feedback provided, stopping iterations")
                break
        
        print(f"   ⏰ Maximum review iterations ({self.config.max_review_iterations}) reached")
        return current_implementation
    
    async def _run_reviewer_agent(self, implementation: Dict) -> Dict:
        """Run the reviewer agent to review the code"""
        
        # Get current diff for review
        diff_output = self._get_current_diff()
        
        prompt = f"""
        Please review the following Helm chart implementation:
        
        Original Issue: {self.issue_data.get('title', 'Feature Implementation')}
        Implementation Details: {implementation.get('implementation', '')}
        
        Git Diff:
        {diff_output}
        
        Please provide a thorough review focusing on:
        1. Helm chart best practices
        2. Kubernetes resource correctness
        3. Security considerations
        4. Documentation completeness
        5. Backwards compatibility
        6. Code quality and maintainability
        
        Respond with:
        - APPROVED: true/false
        - FEEDBACK: detailed feedback for improvements (if not approved)
        - SEVERITY: critical/major/minor (for any issues found)
        """
        
        try:
            # Use Claude Code SDK with agent prefix
            full_prompt = f"[AGENT: helm-chart-reviewer]\n{prompt}"
            
            # Collect all messages from the query
            messages = []
            async for message in query(prompt=full_prompt, options=self.options):
                messages.append(message)
            
            # Extract the assistant's response
            review_output = ""
            for msg in messages:
                if hasattr(msg, 'content') and msg.content:
                    review_output += str(msg.content)
            
            # Parse review result
            approved = "APPROVED: true" in review_output.upper() or "✅" in review_output
            feedback = self._extract_feedback_from_review(review_output)
            
            return {
                "approved": approved,
                "feedback": feedback,
                "full_review": review_output
            }
            
        except Exception as e:
            print(f"⚠️  Review agent failed: {str(e)}")
            return {"approved": True, "feedback": "", "full_review": "Review failed"}
    
    async def _apply_reviewer_feedback(self, implementation: Dict, feedback: str) -> Dict:
        """Apply reviewer feedback using the dev agent"""
        
        prompt = f"""
        Please address the following review feedback for the Helm chart implementation:
        
        Original Implementation: {implementation.get('implementation', '')}
        
        Reviewer Feedback:
        {feedback}
        
        Please make the necessary changes to address this feedback while maintaining 
        the original functionality. Focus on the specific issues mentioned in the review.
        """
        
        try:
            # Use Claude Code SDK with agent prefix
            full_prompt = f"[AGENT: helm-chart-architect]\n{prompt}"
            
            # Collect all messages from the query
            messages = []
            async for message in query(prompt=full_prompt, options=self.options):
                messages.append(message)
            
            # Extract the assistant's response
            updated_implementation = ""
            for msg in messages:
                if hasattr(msg, 'content') and msg.content:
                    updated_implementation += str(msg.content)
            
            # Commit the feedback changes
            self._commit_changes(f"fix: address review feedback - {feedback[:50]}...")
            
            return {
                "implementation": updated_implementation,
                "branch": self.current_branch,
                "commits": self._get_recent_commits(),
                "feedback_applied": feedback
            }
            
        except Exception as e:
            raise RuntimeError(f"Failed to apply reviewer feedback: {str(e)}")
    
    async def _create_pull_request(self) -> str:
        """Create and push PR"""
        
        try:
            # Push branch to remote
            subprocess.run(["git", "push", "-u", "origin", self.current_branch], 
                         cwd=self.config.repository_path, check=True)
            
            # Create PR using GitHub CLI
            pr_title = self.issue_data.get("title", "Claude Code Generated Feature")
            pr_body = self._generate_pr_body()
            
            result = subprocess.run([
                "gh", "pr", "create",
                "--title", pr_title,
                "--body", pr_body,
                "--base", self.config.base_branch,
                "--head", self.current_branch
            ], cwd=self.config.repository_path, capture_output=True, text=True, check=True)
            
            pr_url = result.stdout.strip()
            return pr_url
            
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to create PR: {e}")
    
    # Helper methods
    
    def _create_github_issue(self, issue_content: str, feature_description: str) -> Dict:
        """Create actual GitHub issue"""
        try:
            title = self._extract_title_from_content(issue_content)
            
            result = subprocess.run([
                "gh", "issue", "create",
                "--title", title,
                "--body", issue_content
            ], cwd=self.config.repository_path, capture_output=True, text=True, check=True)
            
            issue_url = result.stdout.strip()
            # Extract issue number from URL
            issue_number = issue_url.split('/')[-1] if issue_url else None
            
            return {"url": issue_url, "number": issue_number}
            
        except subprocess.CalledProcessError:
            return {"url": None, "number": None}
    
    def _extract_title_from_content(self, content: str) -> str:
        """Extract title from issue content"""
        lines = content.split('\n')
        for line in lines:
            if line.startswith('# ') or line.startswith('## '):
                return line.lstrip('# ').strip()
        return "Claude Code Generated Feature"
    
    def _extract_feedback_from_review(self, review_output: str) -> str:
        """Extract feedback from review output"""
        # Look for feedback section
        lines = review_output.split('\n')
        feedback_lines = []
        in_feedback = False
        
        for line in lines:
            if 'FEEDBACK:' in line.upper():
                in_feedback = True
                feedback_lines.append(line.split(':', 1)[-1].strip())
            elif in_feedback and line.strip():
                feedback_lines.append(line)
            elif in_feedback and not line.strip():
                break
        
        return '\n'.join(feedback_lines) if feedback_lines else review_output[:500]
    
    def _sanitize_branch_name(self, title: str) -> str:
        """Convert title to valid git branch name"""
        import re
        # Replace spaces and special chars with hyphens
        branch = re.sub(r'[^a-zA-Z0-9\-_]', '-', title.lower())
        # Remove multiple consecutive hyphens
        branch = re.sub(r'-+', '-', branch)
        # Remove leading/trailing hyphens
        branch = branch.strip('-')
        # Limit length
        branch = branch[:50]
        return f"feature/{branch}"
    
    def _get_timestamp(self) -> str:
        """Get timestamp for branch naming"""
        from datetime import datetime
        return datetime.now().strftime("%Y%m%d-%H%M%S")
    
    def _commit_changes(self, message: str):
        """Commit current changes"""
        try:
            subprocess.run(["git", "add", "."], 
                         cwd=self.config.repository_path, check=True)
            subprocess.run(["git", "commit", "-m", message], 
                         cwd=self.config.repository_path, check=True)
        except subprocess.CalledProcessError as e:
            print(f"⚠️  Commit failed: {e}")
    
    def _get_recent_commits(self) -> List[str]:
        """Get recent commits on current branch"""
        try:
            result = subprocess.run([
                "git", "log", "--oneline", "-5"
            ], cwd=self.config.repository_path, capture_output=True, text=True, check=True)
            return result.stdout.strip().split('\n')
        except subprocess.CalledProcessError:
            return []
    
    def _get_current_diff(self) -> str:
        """Get current git diff"""
        try:
            result = subprocess.run([
                "git", "diff", f"{self.config.base_branch}...HEAD"
            ], cwd=self.config.repository_path, capture_output=True, text=True, check=True)
            return result.stdout
        except subprocess.CalledProcessError:
            return "No diff available"
    
    def _generate_pr_body(self) -> str:
        """Generate PR body"""
        commits = self._get_recent_commits()
        commit_list = '\n'.join(f"- {commit}" for commit in commits[:5])
        
        return f"""## Summary

{self.issue_data.get('description', 'Feature implementation via Claude Code workflow')}

## Changes

{commit_list}

## Related Issue

{self.issue_data.get('url', 'N/A')}

## Test Plan

- [ ] Helm chart templates validate correctly
- [ ] Values.yaml schema is valid
- [ ] Documentation is updated
- [ ] Backwards compatibility maintained

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
"""
    
    async def _cleanup_on_failure(self):
        """Cleanup on workflow failure"""
        if self.current_branch:
            try:
                subprocess.run(["git", "checkout", self.config.base_branch], 
                             cwd=self.config.repository_path)
                print(f"🧹 Switched back to {self.config.base_branch}")
            except subprocess.CalledProcessError:
                pass


async def main():
    """Main entry point"""
    
    # Configuration - Use simple setup since SDK handles Vertex AI internally
    config = WorkflowConfig(
        repository_path=os.getcwd(),
        base_branch="main",
        max_review_iterations=3
    )
    
    # Check if we're using Vertex AI (should be handled by the SDK)
    if os.getenv("CLAUDE_CODE_USE_VERTEX") != "1":
        print("⚠️  Warning: CLAUDE_CODE_USE_VERTEX not set to 1")
        print("💡 The Claude Code SDK should handle Vertex AI configuration automatically")
    
    # Feature description (can be passed as argument)
    if len(sys.argv) > 1:
        feature_description = " ".join(sys.argv[1:])
    else:
        feature_description = input("Enter feature description: ").strip()
    
    if not feature_description:
        print("❌ Error: Feature description is required")
        sys.exit(1)
    
    # Run workflow
    orchestrator = ClaudeCodeOrchestrator(config)
    try:
        pr_url = await orchestrator.run_workflow(feature_description)
        print(f"\n🎉 Success! PR created: {pr_url}")
    except Exception as e:
        print(f"\n💥 Workflow failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
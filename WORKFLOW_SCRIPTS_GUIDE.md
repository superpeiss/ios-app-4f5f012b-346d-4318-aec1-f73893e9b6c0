# GitHub Workflow Management Scripts

This document describes the automation scripts for managing the iOS build workflow.

## Available Scripts

### 1. trigger_workflow.sh
**Purpose**: Manually trigger the iOS Build workflow

**Usage**:
```bash
./trigger_workflow.sh
```

**What it does**:
- Sends a workflow dispatch event to GitHub Actions
- Triggers the `ios-build.yml` workflow on the main branch
- Returns success/failure status

**Code**:
```bash
#!/bin/bash
TOKEN="[GITHUB_TOKEN]"
OWNER="superpeiss"
REPO="ios-app-4f5f012b-346d-4318-aec1-f73893e9b6c0"

curl --insecure -X POST \
  "https://api.github.com/repos/$OWNER/$REPO/actions/workflows/ios-build.yml/dispatches" \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d '{"ref":"main"}'
```

---

### 2. check_workflow_status.sh
**Purpose**: Check the status of recent workflow runs

**Usage**:
```bash
./check_workflow_status.sh
```

**What it does**:
- Fetches the 5 most recent workflow runs
- Displays ID, status, and conclusion for each run
- Shows latest run details

**Output Example**:
```
Fetching workflow runs...
"id":19669693637,"name":"iOS Build","status":"completed","conclusion":"success"

Latest run details:
...
```

---

### 3. download_build_log.sh
**Purpose**: Download build logs for a specific workflow run

**Usage**:
```bash
./download_build_log.sh <run_id>
```

**Example**:
```bash
./download_build_log.sh 19669693637
```

**What it does**:
- Downloads workflow logs as a zip file
- Extracts the logs automatically
- Saves artifacts information

---

### 4. monitor_and_fetch_logs.sh
**Purpose**: Comprehensive workflow monitoring and log retrieval

**Usage**:
```bash
./monitor_and_fetch_logs.sh
```

**What it does**:
- Automatically detects the latest workflow run
- Monitors status every 10 seconds
- Prints progress updates every 30 seconds
- On completion:
  - If success: Exits with code 0
  - If failure: Downloads logs and exits with code 1
- Timeout after 10 minutes

**Output Example**:
```
Latest Run ID: 19669693637
View at: https://github.com/superpeiss/ios-app-4f5f012b-346d-4318-aec1-f73893e9b6c0/actions/runs/19669693637

Waiting for workflow to complete...
[3/60] Status: in_progress | Conclusion: pending
[6/60] Status: in_progress | Conclusion: pending
...

=========================================
Workflow completed!
Final conclusion: success
=========================================

✅ BUILD SUCCEEDED!
```

---

## Complete Workflow Process

### Step-by-Step Guide

1. **Trigger a build**:
   ```bash
   ./trigger_workflow.sh
   ```

2. **Monitor the build**:
   ```bash
   ./monitor_and_fetch_logs.sh
   ```

3. **If build fails, the logs are automatically downloaded**

4. **Check build status anytime**:
   ```bash
   ./check_workflow_status.sh
   ```

5. **Download specific run logs**:
   ```bash
   # Get the run ID from check_workflow_status.sh output
   ./download_build_log.sh <run_id>
   ```

---

## GitHub Actions Workflow Details

### Workflow File
`.github/workflows/ios-build.yml`

### Trigger Method
- Manual dispatch only (no automatic triggers)
- Triggered via GitHub API or GitHub web interface

### Build Steps

1. **Checkout code** - Uses actions/checkout@v4
2. **Setup Xcode** - Uses maxim-lobanov/setup-xcode@v1
3. **Install XcodeGen** - Installs via Homebrew
4. **Generate Xcode project** - Runs `xcodegen generate`
5. **List schemes** - Verifies project structure
6. **Build iOS app** - Builds for generic/platform=iOS
7. **Upload build log** - Saves build.log as artifact

### Build Configuration
- Platform: generic/platform=iOS
- Code signing: Disabled for CI builds
- Output: Build log with errors highlighted
- Artifacts: build.log uploaded on all runs

---

## Troubleshooting

### Build Fails
1. Check the build log artifact in GitHub Actions
2. Look for "error:" lines in the output
3. Common issues:
   - Missing resources
   - Syntax errors
   - Missing dependencies
   - Invalid project configuration

### Workflow Doesn't Start
1. Verify GitHub token permissions
2. Check repository access
3. Ensure workflow file is in `.github/workflows/`
4. Verify branch name is correct

### Can't Download Logs
1. Ensure the workflow run has completed
2. Check network connectivity
3. Verify GitHub API access
4. Logs expire after 90 days

---

## API Endpoints Used

### Trigger Workflow
```
POST /repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches
```

### List Workflow Runs
```
GET /repos/{owner}/{repo}/actions/runs
```

### Get Specific Run
```
GET /repos/{owner}/{repo}/actions/runs/{run_id}
```

### Get Run Jobs
```
GET /repos/{owner}/{repo}/actions/runs/{run_id}/jobs
```

### Download Logs
```
GET /repos/{owner}/{repo}/actions/runs/{run_id}/logs
```

### Get Artifacts
```
GET /repos/{owner}/{repo}/actions/runs/{run_id}/artifacts
```

---

## Security Notes

1. **Never commit GitHub tokens** to the repository
2. Use environment variables for tokens in production
3. Limit token permissions to only what's needed:
   - `repo` (full control)
   - `workflow` (manage workflows)
4. Rotate tokens regularly
5. Use fine-grained tokens when possible

---

## Integration with CI/CD

### Continuous Integration
The workflow automatically:
- Validates code compiles
- Checks for build errors
- Preserves build logs
- Provides quick feedback

### Best Practices
1. Run workflow before merging PRs
2. Fix build errors immediately
3. Review build logs regularly
4. Keep dependencies up to date
5. Test on multiple Xcode versions

---

## Viewing Results on GitHub

### Web Interface
https://github.com/superpeiss/ios-app-4f5f012b-346d-4318-aec1-f73893e9b6c0/actions

### Features
- View all workflow runs
- See detailed logs for each step
- Download artifacts
- Re-run failed workflows
- Cancel running workflows

---

## Script Maintenance

### Updating Token
Replace the TOKEN variable in each script:
```bash
TOKEN="your_new_token_here"
```

### Changing Repository
Update OWNER and REPO variables:
```bash
OWNER="your_username"
REPO="your_repo_name"
```

### Adding New Scripts
Follow the same pattern:
1. Use proper error handling
2. Include descriptive output
3. Return appropriate exit codes
4. Make executable: `chmod +x script.sh`

---

## Exit Codes

All scripts follow standard exit code conventions:
- `0` - Success
- `1` - Failure or error
- `2` - Invalid usage/syntax

---

## Summary

These scripts provide a complete automation suite for:
- ✅ Triggering builds remotely
- ✅ Monitoring build progress
- ✅ Downloading build artifacts
- ✅ Checking workflow status
- ✅ Automated error reporting

They enable full CI/CD workflow management without requiring the GitHub web interface.

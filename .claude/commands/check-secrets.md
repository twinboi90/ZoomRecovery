# Check for Secrets

Run `gitleaks` against the repo to detect any exposed secrets, API keys, or tokens before pushing.

```bash
gitleaks git --source /Users/drewbrowder/Documents/GitHub/ZoomRecovery --no-banner 2>&1
```

If gitleaks reports any findings, show them clearly and DO NOT proceed with the push. Ask the user how they want to handle each finding before continuing.

If gitleaks exits clean (exit code 0), confirm it's safe to push and proceed.

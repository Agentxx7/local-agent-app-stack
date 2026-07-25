# Secrets and sensitive data

- Rule: Secrets, tokens, private paths, personal data, and operator state do not enter Git or reports.
- Purpose: Protect confidentiality and keep templates portable.
- Applies when: Creating files, fixtures, logs, examples, commits, or evidence.
- Prohibited behaviour: Real credentials, identifying paths, raw private payloads, or unsafe examples.
- Required evidence: Reviewed diff and project-selected scans or redaction checks.
- Enforcement type: WRITTEN RULE.
- Operator override: No override for committing live secrets; sanitized fixtures require explicit review.
- Remaining limitations: Detection depends on the checks selected by the adopting project.

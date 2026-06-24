[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000005-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-3%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000005 — Audit Credential Validation (Failure)

**Category:** Account Logon
**Subcategory:** Credential Validation
**Audit Type:** Failure events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing failed credential validation attempts**. This means that when a user or process attempts to authenticate with incorrect credentials, no security event is generated. Brute force attacks, password spray attacks, and unauthorized access attempts could occur entirely undetected.

Credential validation is the process Windows uses to authenticate a user's supplied credentials (username/password) against the local Security Account Manager (SAM) database. Failure events in this subcategory capture every rejected authentication attempt — the forensic breadcrumbs that make intrusion detection possible.

**Without this audit enabled:** An attacker making 10,000 failed login attempts produces zero log entries. The attack is invisible.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"Credential Validation" /category:"Account Logon" /failure:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"Credential Validation"** subcategory within the **"Account Logon"** category
- Enables logging of **failure** events (authentication rejections)
- Takes effect immediately — no reboot required

---

## Verification Command

```powershell
auditpol /get /subcategory:"Credential Validation"
```

**Expected Output:**

```
System audit policy
Category/Subcategory                      Setting
Account Logon
  Credential Validation                   Failure
```

The `Setting` column must show `Failure` (or `Success and Failure` if success auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 3 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 3: WN11-AU-000005
# Audit Credential Validation (Failure)
Set-AuditPolicy -Category "Account Logon" -Subcategory "Credential Validation" -AuditType "failure"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **Brute force detection** | Invisible | Every failed attempt logged (Event ID 4776) |
| **Incident response** | No forensic trail | Timeline reconstruction possible |
| **Compliance** | STIG FAIL | STIG PASS |
| **Threat hunting** | Blind | Source IP, account, timestamp all captured |

**Windows Event ID generated:** `4776` — "The computer attempted to validate the credentials for an account"

This is one of the most fundamental audit policies for detecting credential-based attacks. Its absence on any production system represents a significant visibility gap.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations) | [→ Next: WN11-AU-000020](../WN11-AU-000020-Account-Logon-Success/README.md)

[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000020-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-5%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000020 — Audit Logon (Success)

**Category:** Account Logon
**Subcategory:** Logon
**Audit Type:** Success events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing successful logon events**. This means that every successful authentication — every time a user or process logged into the system — produced zero security log entries. Without this record, there is no baseline of normal access patterns to compare against, no way to detect lateral movement using valid credentials, and no forensic trail of who accessed the system and when.

Successful logon auditing is foundational to access accountability. It answers the most basic security question: *who was on this system and when?*

**Without this audit enabled:** A threat actor who has compromised valid credentials can log into the system repeatedly over days or weeks — undetected. No Event ID is generated. No session is recorded. The intrusion is invisible to log-based detection systems.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"Logon" /category:"Account Logon" /success:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"Logon"** subcategory within the **"Account Logon"** category
- Enables logging of **success** events (authenticated sessions)
- Takes effect immediately — no reboot required

---

## Verification Command

```powershell
auditpol /get /subcategory:"Logon"
```

**Expected Output:**

```
System audit policy
Category/Subcategory                      Setting
Account Logon
  Logon                                   Success
```

The `Setting` column must show `Success` (or `Success and Failure` if failure auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 5 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 5: WN11-AU-000020
# Audit Account Logon Events (Success)
Set-AuditPolicy -Category "Account Logon" -Subcategory "Logon" -AuditType "success"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **Access accountability** | No record of who logged in | Every successful logon logged (Event ID 4624) |
| **Lateral movement detection** | Valid credentials = invisible access | Unusual logon times/sources flagged |
| **Incident response** | No session timeline | Full access history reconstructible |
| **Compliance** | STIG FAIL | STIG PASS |
| **Insider threat detection** | Blind | Logon frequency and pattern analysis possible |

**Windows Event ID generated:** `4624` — "An account was successfully logged on"

Event ID 4624 is one of the most critical Windows security events. It captures the logon type (interactive, network, service), the source IP, the account name, and the authentication package used. This data is irreplaceable for incident response — and its absence makes even basic forensic reconstruction impossible.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations) | [→ Next: WN11-AU-000025](../WN11-AU-000025-Account-Logon-Failure/README.md)

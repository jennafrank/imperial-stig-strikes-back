[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000025-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-6%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000025 — Audit Logon (Failure)

**Category:** Account Logon
**Subcategory:** Logon
**Audit Type:** Failure events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing failed logon attempts**. This is a critical blind spot: failed logon events are the primary signal for detecting brute force attacks, password spraying campaigns, unauthorized access attempts, and misconfigured service accounts hammering the system with bad credentials.

Unlike credential validation failures (WN11-AU-000005, which captures SAM-level authentication rejections), logon failure events capture the broader logon process — including network logons, remote desktop attempts, and service-based authentication failures across all logon types.

**Without this audit enabled:** An attacker can attempt thousands of password combinations against the system via RDP, SMB, or local console — generating no log entries. The attack leaves no trace.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"Logon" /category:"Account Logon" /failure:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"Logon"** subcategory within the **"Account Logon"** category
- Enables logging of **failure** events (rejected authentication attempts)
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
  Logon                                   Failure
```

The `Setting` column must show `Failure` (or `Success and Failure` if success auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 6 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 6: WN11-AU-000025
# Audit Account Logon Events (Failure)
Set-AuditPolicy -Category "Account Logon" -Subcategory "Logon" -AuditType "failure"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **Brute force detection** | Attack is invisible | Event ID 4625 generated per failed attempt |
| **Password spray detection** | No pattern to analyze | Multiple accounts × single password = spike visible |
| **RDP attack surface** | Remote attacks unlogged | Source IP captured for every failed RDP attempt |
| **Account lockout forensics** | Unknown cause | Failed logon sequence reconstructible |
| **Compliance** | STIG FAIL | STIG PASS |

**Windows Event ID generated:** `4625` — "An account failed to log on"

Event ID 4625 includes the failure reason (wrong password, account disabled, account locked out), the logon type, the source IP address, and the target account. This data is essential for detecting credential-based attacks and understanding account lockout root causes. Without it, security operations are operating blind on one of the most common attack vectors.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations) | [→ Next: WN11-AU-000030](../WN11-AU-000030-Account-Management/README.md)

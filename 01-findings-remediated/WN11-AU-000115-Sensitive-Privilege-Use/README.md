[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000115-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-1%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000115 — Audit Sensitive Privilege Use (Success)

**Category:** Privilege Use
**Subcategory:** Sensitive Privilege Use
**Audit Type:** Success events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing successful sensitive privilege use events**. Sensitive privileges are the highest-tier Windows rights — capabilities that, when exercised, can bypass security controls, access protected memory, impersonate users, or load unsigned kernel code. Their use is a strong indicator of both legitimate administrative activity and active exploitation.

Without this audit, an attacker who has escalated to a privileged context can exercise powerful rights — loading kernel drivers, taking ownership of protected files, acting as part of the operating system — and none of these actions produce a log entry.

**Without this audit enabled:** SeDebugPrivilege (used to inject into other processes), SeTcbPrivilege (act as part of the OS), and SeLoadDriverPrivilege (load kernel drivers) can all be successfully exercised with zero visibility to defenders. This is precisely the privileged access level exploited in advanced post-exploitation toolchains.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"Sensitive Privilege Use" /category:"Privilege Use" /success:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"Sensitive Privilege Use"** subcategory within the **"Privilege Use"** category
- Enables logging of **success** events (privilege exercise completions)
- Takes effect immediately — no reboot required

---

## Verification Command

```powershell
auditpol /get /subcategory:"Sensitive Privilege Use"
```

**Expected Output:**

```
System audit policy
Category/Subcategory                      Setting
Privilege Use
  Sensitive Privilege Use                 Success
```

The `Setting` column must show `Success` (or `Success and Failure` if failure auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 1 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 1: WN11-AU-000115
# Audit Privilege Use - Sensitive Privilege Use (Success)
Set-AuditPolicy -Category "Privilege Use" -Subcategory "Sensitive Privilege Use" -AuditType "success"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **Kernel exploitation** | Driver loading undetected | SeLoadDriverPrivilege use logged (Event ID 4673) |
| **Process injection** | SeDebugPrivilege use invisible | Debugging privilege exercises captured |
| **Token impersonation** | SeImpersonatePrivilege silent | Impersonation attempts logged |
| **Security bypass** | Privilege escalation untracked | Full chain of privilege exercise visible |
| **Compliance** | STIG FAIL | STIG PASS |

**Windows Event ID generated:** `4673` — "A privileged service was called"

Event ID 4673 is generated whenever a sensitive privilege is successfully invoked. The event identifies the privilege name, the calling process, and the account that exercised the right. This data is invaluable for identifying privilege abuse — both by insider threats and by external attackers who have achieved privilege escalation. This was the first remediation applied in the hardening campaign because of its outsized detection value.

**Sensitive privileges tracked include:**
- `SeDebugPrivilege` — Debug programs
- `SeLoadDriverPrivilege` — Load and unload device drivers
- `SeTcbPrivilege` — Act as part of the operating system
- `SeSecurityPrivilege` — Manage auditing and security log
- `SeImpersonatePrivilege` — Impersonate a client after authentication

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations) | [→ Next: WN11-AU-000584](../WN11-AU-000584-Handle-Manipulation/README.md)

[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000030-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-7%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000030 — Audit User Account Management (Success)

**Category:** Account Management
**Subcategory:** User Account Management
**Audit Type:** Success events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing successful user account management events**. This subcategory captures every modification to user accounts: creations, deletions, password resets, account enables/disables, and group membership changes. Without this audit, an attacker with sufficient privileges can create backdoor accounts, elevate existing accounts to administrator, or delete accounts to cover their tracks — all without leaving a single log entry.

Account management auditing is the primary mechanism for detecting privilege escalation and persistence establishment. It answers critical incident response questions: *Was a new account created? When? By whom?*

**Without this audit enabled:** A threat actor who establishes persistence by creating a local administrator account leaves zero forensic evidence of that action. The account simply exists — with no log of its creation.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"User Account Management" /category:"Account Management" /success:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"User Account Management"** subcategory within the **"Account Management"** category
- Enables logging of **success** events (completed account modifications)
- Takes effect immediately — no reboot required

---

## Verification Command

```powershell
auditpol /get /subcategory:"User Account Management"
```

**Expected Output:**

```
System audit policy
Category/Subcategory                      Setting
Account Management
  User Account Management                 Success
```

The `Setting` column must show `Success` (or `Success and Failure` if failure auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 7 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 7: WN11-AU-000030
# Audit Account Management (Success)
Set-AuditPolicy -Category "Account Management" -Subcategory "User Account Management" -AuditType "success"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **Backdoor account detection** | New accounts created silently | Event ID 4720 generated on every account creation |
| **Privilege escalation** | Admin grants invisible | Group membership changes logged (Event ID 4728/4732) |
| **Account tampering** | Password resets untracked | All credential changes timestamped and attributed |
| **Persistence detection** | Invisible foothold establishment | Account lifecycle fully audited |
| **Compliance** | STIG FAIL | STIG PASS |

**Key Windows Event IDs generated:**
- `4720` — A user account was created
- `4722` — A user account was enabled
- `4723` / `4724` — Password change / reset
- `4726` — A user account was deleted
- `4738` — A user account was changed

This subcategory is essential for detecting the most common post-exploitation persistence techniques. An attacker who creates a new account — or modifies an existing one — leaves a clear audit trail under this policy.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations) | [→ Next: WN11-AU-000045](../WN11-AU-000045-Directory-Service-Access/README.md)

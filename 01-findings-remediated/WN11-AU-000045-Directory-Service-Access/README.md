[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000045-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-8%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000045 — Audit Directory Service Access (Success)

**Category:** DS Access
**Subcategory:** Directory Service Access
**Audit Type:** Success events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing successful directory service access events**. This subcategory captures access to Active Directory objects — the backbone of enterprise identity and access management. Without this audit, reconnaissance operations against AD (enumeration of users, groups, Group Policy Objects, and organizational units) leave no trace.

Directory Service Access auditing is the primary detection mechanism for AD-based attack techniques including AD enumeration, LDAP reconnaissance, Kerberoasting preparation, and DCSync attack staging. These are foundational techniques in nearly every enterprise intrusion chain.

**Without this audit enabled:** An attacker enumerating your entire Active Directory — mapping every user, group, and privilege — generates zero log entries. Tools like BloodHound can complete full AD reconnaissance in minutes with no audit trail.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"Directory Service Access" /category:"DS Access" /success:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"Directory Service Access"** subcategory within the **"DS Access"** category
- Enables logging of **success** events (completed AD object access operations)
- Takes effect immediately — no reboot required

---

## Verification Command

```powershell
auditpol /get /subcategory:"Directory Service Access"
```

**Expected Output:**

```
System audit policy
Category/Subcategory                      Setting
DS Access
  Directory Service Access                Success
```

The `Setting` column must show `Success` (or `Success and Failure` if failure auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 8 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 8: WN11-AU-000045
# Audit Directory Service Access (Success)
Set-AuditPolicy -Category "DS Access" -Subcategory "Directory Service Access" -AuditType "success"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **AD reconnaissance** | BloodHound runs silently | Object access patterns visible (Event ID 4662) |
| **Kerberoasting preparation** | SPN enumeration invisible | Service account queries logged |
| **Privilege escalation staging** | Admin account enumeration untracked | Sensitive group queries captured |
| **DCSync detection** | Replication requests unseen | Directory replication operations logged |
| **Compliance** | STIG FAIL | STIG PASS |

**Windows Event ID generated:** `4662` — "An operation was performed on an object"

Event 4662 fires when an AD object is accessed with a matching System Access Control List (SACL). When combined with proper SACL configuration on sensitive AD objects, this audit policy enables detection of the most dangerous AD-targeting attack techniques in the modern threat landscape. Its absence represents a significant blind spot for any domain-connected system.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations) | [→ Next: WN11-AU-000055](../WN11-AU-000055-Audit-Logoff/README.md)

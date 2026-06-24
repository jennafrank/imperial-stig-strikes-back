[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000070-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-10%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000070 — Audit Policy Change (Success)

**Category:** Policy Change
**Subcategory:** Audit Policy Change
**Audit Type:** Success events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing successful audit policy change events**. This is one of the most critical gaps in the security posture: without this audit, an attacker who gains elevated privileges can disable the system's audit policies — eliminating the very logging mechanisms that would detect their activity — and that act itself produces no log entry.

This is an anti-forensics enabler. Audit policy manipulation is a well-documented attacker technique for covering tracks after gaining a foothold. When audit policy changes aren't logged, an attacker can systematically disable every other audit category, operate freely, then restore the policies before leaving — and the entire sequence is undetectable.

**Without this audit enabled:** An attacker runs `auditpol /set /category:* /success:disable /failure:disable`. Every audit policy on the system is disabled. This action leaves no log entry. The system is now completely blind.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"Audit Policy Change" /category:"Policy Change" /success:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"Audit Policy Change"** subcategory within the **"Policy Change"** category
- Enables logging of **success** events (completed policy modifications)
- Takes effect immediately — no reboot required

---

## Verification Command

```powershell
auditpol /get /subcategory:"Audit Policy Change"
```

**Expected Output:**

```
System audit policy
Category/Subcategory                      Setting
Policy Change
  Audit Policy Change                     Success
```

The `Setting` column must show `Success` (or `Success and Failure` if failure auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 10 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 10: WN11-AU-000070
# Audit Policy Change (Success)
Set-AuditPolicy -Category "Policy Change" -Subcategory "Audit Policy Change" -AuditType "success"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **Anti-forensics detection** | Audit disabling is invisible | Every policy change logged (Event ID 4719) |
| **Attacker track-covering** | Log wiping preparation undetected | Policy manipulation leaves an audit trail |
| **Unauthorized configuration changes** | Policy drift undetectable | All auditpol modifications attributed and timestamped |
| **Compliance** | STIG FAIL | STIG PASS |
| **Security control integrity** | Controls can be silently disabled | Changes immediately visible to SIEM/SOC |

**Windows Event ID generated:** `4719` — "System audit policy was changed"

Event ID 4719 is the sentinel event — it fires when any audit policy is modified, including when audit policies are *disabled*. This creates a self-protecting audit chain: as long as this subcategory is enabled, any attempt to disable other audit categories will generate a logged event. It's the audit policy for audit policies — and its absence is a fundamental gap in any security logging architecture.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations) | [→ Next: WN11-AU-000075](../WN11-AU-000075-Auth-Policy-Change/README.md)

[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000075-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-11%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000075 — Audit Authentication Policy Change (Success)

**Category:** Policy Change
**Subcategory:** Authentication Policy Change
**Audit Type:** Success events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing successful authentication policy change events**. This subcategory captures changes to the authentication framework itself — Kerberos policy modifications, trust additions and removals, domain policy changes, and password policy alterations. These are the highest-privilege configuration changes in a Windows environment, directly impacting how the system validates identity.

Authentication policy changes are a hallmark of advanced persistent threat (APT) activity. Attackers who achieve domain administrator access frequently modify authentication policies to weaken security controls, create persistent authentication pathways, or establish conditions for Golden Ticket or Silver Ticket attacks.

**Without this audit enabled:** A threat actor who modifies the Kerberos ticket lifetime, adds a rogue domain trust, or weakens password policies — all of which require significant privilege — does so with no logged evidence of the change.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"Authentication Policy Change" /category:"Policy Change" /success:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"Authentication Policy Change"** subcategory within the **"Policy Change"** category
- Enables logging of **success** events (completed authentication policy modifications)
- Takes effect immediately — no reboot required

---

## Verification Command

```powershell
auditpol /get /subcategory:"Authentication Policy Change"
```

**Expected Output:**

```
System audit policy
Category/Subcategory                      Setting
Policy Change
  Authentication Policy Change            Success
```

The `Setting` column must show `Success` (or `Success and Failure` if failure auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 11 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 11: WN11-AU-000075
# Audit Authentication Policy Change (Success)
Set-AuditPolicy -Category "Policy Change" -Subcategory "Authentication Policy Change" -AuditType "success"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **Kerberos policy tampering** | Ticket lifetime changes invisible | Event ID 4713 generated on Kerberos policy change |
| **Domain trust manipulation** | Rogue trust additions undetected | Trust additions/removals logged (Event ID 4706/4707) |
| **Password policy weakening** | Policy degradation unlogged | Policy changes attributed and timestamped |
| **APT persistence** | Authentication framework silently modified | Configuration drift immediately visible |
| **Compliance** | STIG FAIL | STIG PASS |

**Key Windows Event IDs generated:**
- `4706` — A new trust was created to a domain
- `4707` — A trust to a domain was removed
- `4713` — Kerberos policy was changed
- `4716` — Trusted domain information was modified
- `4739` — Domain Policy was changed

Authentication policy changes are among the most consequential modifications that can be made to a Windows environment. This audit subcategory ensures that changes to the authentication framework — regardless of how they were made or by whom — leave a permanent, attributable record in the security log. This is the final layer of the audit policy hardening chain.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations)

[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000584-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-2%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000584 — Audit Handle Manipulation (Success)

**Category:** Object Access
**Subcategory:** Handle Manipulation
**Audit Type:** Success events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing successful handle manipulation events**. Handles are how Windows processes interact with objects — files, registry keys, processes, and other kernel objects. Every time a process opens a handle to an object (gaining access to read, write, or execute it), a handle manipulation event can be generated. Without this audit, a process accessing sensitive files, registry keys, or other processes leaves no trace of that access at the handle level.

Handle manipulation auditing is a supporting subcategory to file and object access auditing — it captures the *opening* of access channels to objects, complementing higher-level object access events. It is particularly valuable for detecting credential dumping (which involves opening handles to the LSASS process) and unauthorized access to protected system objects.

**Without this audit enabled:** A process that opens a handle to `lsass.exe` — the first step in most credential dumping operations — does so without generating any audit event. The credential theft that follows has no forensic precursor.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"Handle Manipulation" /category:"Object Access" /success:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"Handle Manipulation"** subcategory within the **"Object Access"** category
- Enables logging of **success** events (handle open operations that complete successfully)
- Takes effect immediately — no reboot required

---

## Verification Command

```powershell
auditpol /get /subcategory:"Handle Manipulation"
```

**Expected Output:**

```
System audit policy
Category/Subcategory                      Setting
Object Access
  Handle Manipulation                     Success
```

The `Setting` column must show `Success` (or `Success and Failure` if failure auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 2 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 2: WN11-AU-000584
# Audit Handle Manipulation (Success)
Set-AuditPolicy -Category "Object Access" -Subcategory "Handle Manipulation" -AuditType "success"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **Credential dumping detection** | LSASS handle opens invisible | Process access to LSASS visible (Event ID 4658) |
| **Unauthorized file access** | Protected file handle requests untracked | Handle close events with access rights logged |
| **Registry manipulation** | Registry handle operations undetected | Key access patterns visible |
| **Process injection precursor** | Cross-process handle operations unlogged | Inter-process access attempts captured |
| **Compliance** | STIG FAIL | STIG PASS |

**Windows Event IDs generated:**
- `4656` — A handle to an object was requested
- `4658` — The handle to an object was closed

Handle manipulation events work in conjunction with object-level SACLs. When an object (such as `lsass.exe` or a sensitive registry key) has a SACL configured for auditing, handle manipulation events capture both the opening (4656) and closing (4658) of access to that object — including the specific access rights requested. This makes handle manipulation auditing a key component of credential theft and unauthorized access detection chains.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations) | [→ Next: WN11-SO-000215](../WN11-SO-000215-NTLM-Session-Security/README.md)

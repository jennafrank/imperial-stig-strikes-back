[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--AU--000055-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-9%20of%2011-blue?style=for-the-badge)

</div>

# WN11-AU-000055 — Audit Logoff (Success)

**Category:** Logon/Logoff
**Subcategory:** Logoff
**Audit Type:** Success events
**Remediation Method:** `auditpol` — audit policy configuration

---

## The Vulnerability

The Windows 11 system was **not auditing successful logoff events**. While this may appear less critical than logon auditing, logoff events are the other half of the session record — without them, there is no way to determine session duration, detect abnormally long sessions, or identify sessions that were never properly terminated.

Logoff auditing completes the access timeline. Paired with logon events (WN11-AU-000020), it enables calculation of session durations, identification of overnight sessions that shouldn't exist, and detection of session hijacking where a legitimate session continues beyond when the user believes they logged off.

**Without this audit enabled:** A compromised session that persists for 72 hours appears identical to a 5-minute session. There is no way to determine when access ended — or whether it ended at all.

---

## Remediation Command

```powershell
auditpol /set /subcategory:"Logoff" /category:"Logon/Logoff" /success:enable
```

### How It Works

The `auditpol` utility is the native Windows tool for configuring the Security Audit Policy. This command:
- Targets the **"Logoff"** subcategory within the **"Logon/Logoff"** category
- Enables logging of **success** events (completed logoff operations)
- Takes effect immediately — no reboot required

---

## Verification Command

```powershell
auditpol /get /subcategory:"Logoff"
```

**Expected Output:**

```
System audit policy
Category/Subcategory                      Setting
Logon/Logoff
  Logoff                                  Success
```

The `Setting` column must show `Success` (or `Success and Failure` if failure auditing is also enabled).

---

## In the Remediation Script

This finding was addressed as **Finding 9 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 9: WN11-AU-000055
# Audit Logoff (Success)
Set-AuditPolicy -Category "Logon/Logoff" -Subcategory "Logoff" -AuditType "success"
```

The script's `Set-AuditPolicy` function applies the change and immediately verifies it — logging `✓ Successfully configured` on success or `✗ Configuration verification failed` on failure.

---

## Security Rationale

| Risk | Without Auditing | With Auditing |
|------|-----------------|---------------|
| **Session duration tracking** | No start-to-end record | Full session window reconstructible |
| **Zombie session detection** | Stale sessions invisible | Sessions without logoff flaggable |
| **Access timeline gaps** | Incomplete forensic picture | Complete logon/logoff pairs for all sessions |
| **After-hours access** | Session end time unknown | Exact access window documented |
| **Compliance** | STIG FAIL | STIG PASS |

**Windows Event ID generated:** `4634` — "An account was logged off"

Event ID 4634, paired with Event ID 4624 (logon), provides a complete picture of system access: who logged in, from where, and exactly how long they maintained access. This pairing is essential for establishing timeline accuracy during incident response and for detecting sessions that far outlasted their expected duration.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations) | [→ Next: WN11-AU-000070](../WN11-AU-000070-Audit-Policy-Change/README.md)

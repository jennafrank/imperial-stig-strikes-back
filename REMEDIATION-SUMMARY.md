<div align="center">

![Imperial Security Division](https://img.shields.io/badge/⚫%20IMPERIAL%20SECURITY%20DIVISION-CLASSIFIED-red?style=for-the-badge&labelColor=000000)
![Status](https://img.shields.io/badge/Mission-ACCOMPLISHED-success?style=for-the-badge)

</div>

# Remediation Summary — All 11 Operations

Quick-reference for every hardening action taken during the Imperial STIG Remediation Campaign on endpoint `imperial-win11`.

---

## Audit Policy Remediations (10 Operations)

All audit policy changes were applied using `auditpol.exe`. Each command takes effect immediately with no reboot required.

| # | STIG ID | Category | Subcategory | Type | Command |
|---|---------|----------|-------------|------|---------|
| 1 | WN11-AU-000115 | Privilege Use | Sensitive Privilege Use | Success | `auditpol /set /subcategory:"Sensitive Privilege Use" /category:"Privilege Use" /success:enable` |
| 2 | WN11-AU-000584 | Object Access | Handle Manipulation | Success | `auditpol /set /subcategory:"Handle Manipulation" /category:"Object Access" /success:enable` |
| 3 | WN11-AU-000005 | Account Logon | Credential Validation | Failure | `auditpol /set /subcategory:"Credential Validation" /category:"Account Logon" /failure:enable` |
| 5 | WN11-AU-000020 | Account Logon | Logon | Success | `auditpol /set /subcategory:"Logon" /category:"Account Logon" /success:enable` |
| 6 | WN11-AU-000025 | Account Logon | Logon | Failure | `auditpol /set /subcategory:"Logon" /category:"Account Logon" /failure:enable` |
| 7 | WN11-AU-000030 | Account Management | User Account Management | Success | `auditpol /set /subcategory:"User Account Management" /category:"Account Management" /success:enable` |
| 8 | WN11-AU-000045 | DS Access | Directory Service Access | Success | `auditpol /set /subcategory:"Directory Service Access" /category:"DS Access" /success:enable` |
| 9 | WN11-AU-000055 | Logon/Logoff | Logoff | Success | `auditpol /set /subcategory:"Logoff" /category:"Logon/Logoff" /success:enable` |
| 10 | WN11-AU-000070 | Policy Change | Audit Policy Change | Success | `auditpol /set /subcategory:"Audit Policy Change" /category:"Policy Change" /success:enable` |
| 11 | WN11-AU-000075 | Policy Change | Authentication Policy Change | Success | `auditpol /set /subcategory:"Authentication Policy Change" /category:"Policy Change" /success:enable` |

---

## Registry Remediation (1 Operation)

| # | STIG ID | Registry Path | Value Name | Value | Description |
|---|---------|--------------|------------|-------|-------------|
| 4 | WN11-SO-000215 | `HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0` | `NTLMMinClientSec` | `537395200` | NTLMv2 + 128-bit encryption required |

**Value breakdown:** `537395200` = `0x20080000` = `NTLMSSP_NEGOTIATE_NTLM2` (`0x00080000`) + `NTLMSSP_NEGOTIATE_128` (`0x20000000`)

---

## Windows Event IDs Now Active

After remediation, the following Event IDs will be generated on the endpoint:

| Event ID | Description | Enabled By |
|----------|-------------|-----------|
| `4624` | Account successfully logged on | WN11-AU-000020 |
| `4625` | Account failed to log on | WN11-AU-000025 |
| `4634` | Account was logged off | WN11-AU-000055 |
| `4656` | Handle to an object was requested | WN11-AU-000584 |
| `4658` | Handle to an object was closed | WN11-AU-000584 |
| `4662` | Operation performed on an object | WN11-AU-000045 |
| `4673` | Privileged service was called | WN11-AU-000115 |
| `4706` / `4707` | Domain trust created / removed | WN11-AU-000075 |
| `4713` | Kerberos policy changed | WN11-AU-000075 |
| `4719` | System audit policy was changed | WN11-AU-000070 |
| `4720` | User account was created | WN11-AU-000030 |
| `4726` | User account was deleted | WN11-AU-000030 |
| `4738` | User account was changed | WN11-AU-000030 |
| `4739` | Domain policy was changed | WN11-AU-000075 |
| `4776` | Credential validation attempted | WN11-AU-000005 |

---

## Script Execution Summary

The remediation was automated via `02-remediation-scripts/remediation-script.ps1`:

```powershell
# Preview mode (no changes):
.\remediation-script.ps1 -WhatIf

# Apply all remediations:
.\remediation-script.ps1
```

**Pre-execution:** Audit policy backed up to `C:\Windows\Temp\STIG-Backups\audit-policy-backup_[timestamp].csv`
**Log file:** `C:\Windows\Temp\STIG-Backups\remediation-log_[timestamp].txt`

---

[← Back to Main README](./README.md) | [→ Verification Guide](./VERIFICATION-GUIDE.md)

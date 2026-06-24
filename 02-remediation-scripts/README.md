[← Back to Main README](../README.md)

---

<div align="center">

![Imperial Security Division](https://img.shields.io/badge/⚫%20IMPERIAL%20SECURITY%20DIVISION-CLASSIFIED-red?style=for-the-badge&labelColor=000000)
![PowerShell](https://img.shields.io/badge/Language-PowerShell-blue?style=for-the-badge&logo=powershell&logoColor=white)
![Findings](https://img.shields.io/badge/Findings%20Covered-11%20of%2011-success?style=for-the-badge)

</div>

# 02 — Remediation Scripts

This directory contains the PowerShell automation used to execute all 11 STIG hardening operations on endpoint `imperial-win11` during the remediation campaign.

---

## Contents

| File | Description |
|------|-------------|
| `remediation-script.ps1` | Main remediation script — 305 lines, covers all 11 findings |

---

## remediation-script.ps1

### What It Does

The script automates the complete remediation campaign in a single execution:

1. **Creates a backup directory** at `C:\Windows\Temp\STIG-Backups\`
2. **Exports the current audit policy** to a timestamped CSV backup before making any changes
3. **Applies all 11 remediations** in sequence with inline success/failure logging
4. **Verifies each change** immediately after applying it
5. **Writes a timestamped log** of every action taken

### Remediations Covered

| Order | STIG ID | Finding |
|-------|---------|---------|
| 1 | WN11-AU-000115 | Audit Sensitive Privilege Use — Success |
| 2 | WN11-AU-000584 | Audit Handle Manipulation — Success |
| 3 | WN11-AU-000005 | Audit Credential Validation — Failure |
| 4 | WN11-SO-000215 | NTLM SSP Minimum Session Security |
| 5 | WN11-AU-000020 | Audit Logon — Success |
| 6 | WN11-AU-000025 | Audit Logon — Failure |
| 7 | WN11-AU-000030 | Audit User Account Management — Success |
| 8 | WN11-AU-000045 | Audit Directory Service Access — Success |
| 9 | WN11-AU-000055 | Audit Logoff — Success |
| 10 | WN11-AU-000070 | Audit Policy Change — Success |
| 11 | WN11-AU-000075 | Audit Authentication Policy Change — Success |

---

## Usage

### Prerequisites

- Must be run in an **elevated PowerShell session** (Run as Administrator)
- PowerShell 5.1 or later
- Windows 11 (or Windows 10/Server 2019+)

### Preview Mode (Recommended First Step)

```powershell
.\remediation-script.ps1 -WhatIf
```

`-WhatIf` mode uses PowerShell's native `SupportsShouldProcess` framework — every remediation prints what *would* happen without making any changes. Use this to audit the script's intended actions before executing.

### Apply Remediations

```powershell
.\remediation-script.ps1
```

The script will:
- Back up current audit policy to `C:\Windows\Temp\STIG-Backups\audit-policy-backup_[timestamp].csv`
- Apply all 11 remediations
- Write a log to `C:\Windows\Temp\STIG-Backups\remediation-log_[timestamp].txt`
- Print status for each finding: `✓ Successfully configured` or `✗ Configuration verification failed`

### Execution Policy Note

If execution policy blocks the script:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\remediation-script.ps1
```

---

## Script Architecture

```
remediation-script.ps1
│
├── Configuration & Logging
│   ├── $BackupPath, $Timestamp, $LogFile, $BackupFile variables
│   └── Write-Log function (INFO / SUCCESS / WARNING / ERROR levels)
│
├── Backup
│   └── Backup-AuditPolicy: exports auditpol /get /category:* to CSV
│
├── Remediation Functions
│   ├── Set-AuditPolicy: wraps auditpol /set with verification
│   └── Set-RegistryPolicy: wraps Set-ItemProperty with read/verify/log
│
└── Execution Block
    ├── Backup (abort if backup fails)
    ├── Remediations 1–11 in sequence
    └── Final verification: auditpol /get /category:*
```

---

## Rollback

To restore the original audit policy from backup:

```powershell
# List available backups
Get-ChildItem "C:\Windows\Temp\STIG-Backups\" -Filter "audit-policy-backup_*.csv"

# Restore a specific backup
auditpol /restore /file:"C:\Windows\Temp\STIG-Backups\audit-policy-backup_[timestamp].csv"
```

> **Note:** The NTLM session security registry change (WN11-SO-000215) is not captured in the audit policy backup. To roll back that change, set `NTLMMinClientSec` back to its original value (typically `0`).

---

[← Back to Main README](../README.md)

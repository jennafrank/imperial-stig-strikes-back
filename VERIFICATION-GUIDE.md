<div align="center">

![Imperial Security Division](https://img.shields.io/badge/⚫%20IMPERIAL%20SECURITY%20DIVISION-CLASSIFIED-red?style=for-the-badge&labelColor=000000)
![Guide](https://img.shields.io/badge/Document-Verification%20Guide-blue?style=for-the-badge)

</div>

# Verification Guide

Step-by-step commands to independently verify every remediation applied during the Imperial STIG Remediation Campaign. Run these commands on `imperial-win11` from an elevated PowerShell session.

---

## Prerequisites

All verification commands require **Administrator privileges**.

```powershell
# Confirm you are running as Administrator
$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
# Expected: True
```

---

## Batch Verification — All Audit Policies at Once

Run a single command to see the current state of all relevant subcategories:

```powershell
auditpol /get /category:*
```

Or target only the categories modified in this campaign:

```powershell
auditpol /get /category:"Account Logon","Account Management","DS Access","Logon/Logoff","Policy Change","Privilege Use","Object Access"
```

---

## Individual Verification Commands

### WN11-AU-000005 — Credential Validation (Failure)

```powershell
auditpol /get /subcategory:"Credential Validation"
```

**Expected:**
```
System audit policy
Category/Subcategory                      Setting
Account Logon
  Credential Validation                   Failure
```

---

### WN11-AU-000020 — Logon (Success)

```powershell
auditpol /get /subcategory:"Logon"
```

**Expected:**
```
System audit policy
Category/Subcategory                      Setting
Account Logon
  Logon                                   Success and Failure
```
*(Both Success and Failure should be set after WN11-AU-000020 and WN11-AU-000025 remediations)*

---

### WN11-AU-000025 — Logon (Failure)

```powershell
auditpol /get /subcategory:"Logon"
```

**Expected:** Same as above — `Success and Failure`

---

### WN11-AU-000030 — User Account Management (Success)

```powershell
auditpol /get /subcategory:"User Account Management"
```

**Expected:**
```
System audit policy
Category/Subcategory                      Setting
Account Management
  User Account Management                 Success
```

---

### WN11-AU-000045 — Directory Service Access (Success)

```powershell
auditpol /get /subcategory:"Directory Service Access"
```

**Expected:**
```
System audit policy
Category/Subcategory                      Setting
DS Access
  Directory Service Access                Success
```

---

### WN11-AU-000055 — Logoff (Success)

```powershell
auditpol /get /subcategory:"Logoff"
```

**Expected:**
```
System audit policy
Category/Subcategory                      Setting
Logon/Logoff
  Logoff                                  Success
```

---

### WN11-AU-000070 — Audit Policy Change (Success)

```powershell
auditpol /get /subcategory:"Audit Policy Change"
```

**Expected:**
```
System audit policy
Category/Subcategory                      Setting
Policy Change
  Audit Policy Change                     Success
```

---

### WN11-AU-000075 — Authentication Policy Change (Success)

```powershell
auditpol /get /subcategory:"Authentication Policy Change"
```

**Expected:**
```
System audit policy
Category/Subcategory                      Setting
Policy Change
  Authentication Policy Change            Success
```

---

### WN11-AU-000115 — Sensitive Privilege Use (Success)

```powershell
auditpol /get /subcategory:"Sensitive Privilege Use"
```

**Expected:**
```
System audit policy
Category/Subcategory                      Setting
Privilege Use
  Sensitive Privilege Use                 Success
```

---

### WN11-AU-000584 — Handle Manipulation (Success)

```powershell
auditpol /get /subcategory:"Handle Manipulation"
```

**Expected:**
```
System audit policy
Category/Subcategory                      Setting
Object Access
  Handle Manipulation                     Success
```

---

### WN11-SO-000215 — NTLM SSP Minimum Session Security

```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0" -Name "NTLMMinClientSec"
```

**Expected:**
```
NTLMMinClientSec : 537395200
```

To verify the bit flags are correct:
```powershell
$val = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0").NTLMMinClientSec
[System.Convert]::ToString($val, 16)
# Expected: 20080000
```

---

## Nessus Rescan Verification

The definitive verification method is a full authenticated Nessus STIG compliance rescan:

1. Run Nessus scan using **Plugin 21156 (Windows Compliance Checks)** with the DoD STIG policy
2. Compare results against baseline `scan-before.csv` in `04-scan-results/`
3. All 11 findings above should show **PASSED**

**Baseline:** `04-scan-results/scan-before.csv` — PASSED: 158, FAILED: 185
**Post-remediation:** `04-scan-results/scan-after.csv` — PASSED: 173, FAILED: 170

Net improvement: **+15 controls brought into compliance**, **-15 failures closed**

---

[← Back to Main README](./README.md) | [← Remediation Summary](./REMEDIATION-SUMMARY.md)

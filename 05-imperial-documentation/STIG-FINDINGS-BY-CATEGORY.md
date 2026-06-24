<div align="center">

![Imperial Security Division](https://img.shields.io/badge/⚫%20IMPERIAL%20SECURITY%20DIVISION-CLASSIFIED-red?style=for-the-badge&labelColor=000000)
![Reference](https://img.shields.io/badge/Document-Findings%20by%20Category-blue?style=for-the-badge)

</div>

# STIG Findings by Category

Reference document organizing all 11 remediated HIGH severity findings by their STIG category. Use this to understand the attack surface coverage achieved by the remediation campaign.

---

## Category Overview

| STIG Category | Findings Remediated | Controls Enabled |
|--------------|:-------------------:|-----------------|
| Account Logon | 3 | Credential Validation (Failure), Logon (Success), Logon (Failure) |
| Account Management | 1 | User Account Management (Success) |
| DS Access | 1 | Directory Service Access (Success) |
| Logon/Logoff | 1 | Logoff (Success) |
| Object Access | 1 | Handle Manipulation (Success) |
| Policy Change | 2 | Audit Policy Change (Success), Authentication Policy Change (Success) |
| Privilege Use | 1 | Sensitive Privilege Use (Success) |
| Security Options | 1 | NTLM SSP Minimum Session Security |

---

## Account Logon Category

**Purpose:** Audit events related to credential authentication at the account level.

### WN11-AU-000005 — Credential Validation (Failure)
- **Subcategory:** Credential Validation
- **Event Type:** Failure
- **Event ID:** 4776
- **What it detects:** Failed SAM-level authentication — brute force, password spray, bad credential attempts
- **Operation #:** 3 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000005-Credential-Validation/README.md)

### WN11-AU-000020 — Logon (Success)
- **Subcategory:** Logon
- **Event Type:** Success
- **Event ID:** 4624
- **What it detects:** Every successful authentication event — who logged in and when
- **Operation #:** 5 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000020-Account-Logon-Success/README.md)

### WN11-AU-000025 — Logon (Failure)
- **Subcategory:** Logon
- **Event Type:** Failure
- **Event ID:** 4625
- **What it detects:** Failed logon attempts including RDP, network, and local — brute force indicator
- **Operation #:** 6 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000025-Account-Logon-Failure/README.md)

---

## Account Management Category

**Purpose:** Audit changes to user accounts — creation, deletion, modification, password resets.

### WN11-AU-000030 — User Account Management (Success)
- **Subcategory:** User Account Management
- **Event Type:** Success
- **Event IDs:** 4720, 4722, 4723, 4724, 4726, 4738
- **What it detects:** Account creation (persistence), privilege grants, account deletion (anti-forensics)
- **Operation #:** 7 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000030-Account-Management/README.md)

---

## DS Access Category

**Purpose:** Audit access to Active Directory objects — users, groups, GPOs, OUs.

### WN11-AU-000045 — Directory Service Access (Success)
- **Subcategory:** Directory Service Access
- **Event Type:** Success
- **Event ID:** 4662
- **What it detects:** AD enumeration, LDAP reconnaissance, Kerberoasting preparation, DCSync staging
- **Operation #:** 8 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000045-Directory-Service-Access/README.md)

---

## Logon/Logoff Category

**Purpose:** Audit session start and end events on the local system.

### WN11-AU-000055 — Logoff (Success)
- **Subcategory:** Logoff
- **Event Type:** Success
- **Event ID:** 4634
- **What it detects:** Session termination — completes the access timeline when paired with Event 4624
- **Operation #:** 9 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000055-Audit-Logoff/README.md)

---

## Object Access Category

**Purpose:** Audit access to system objects — files, registry keys, processes, and other kernel objects.

### WN11-AU-000584 — Handle Manipulation (Success)
- **Subcategory:** Handle Manipulation
- **Event Type:** Success
- **Event IDs:** 4656, 4658
- **What it detects:** Process handle opens — key precursor to credential dumping via LSASS handle access
- **Operation #:** 2 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000584-Handle-Manipulation/README.md)

---

## Policy Change Category

**Purpose:** Audit modifications to security and authentication policies.

### WN11-AU-000070 — Audit Policy Change (Success)
- **Subcategory:** Audit Policy Change
- **Event Type:** Success
- **Event ID:** 4719
- **What it detects:** Audit policy modifications — including attempts to disable logging (anti-forensics detection)
- **Operation #:** 10 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000070-Audit-Policy-Change/README.md)

### WN11-AU-000075 — Authentication Policy Change (Success)
- **Subcategory:** Authentication Policy Change
- **Event Type:** Success
- **Event IDs:** 4706, 4707, 4713, 4716, 4739
- **What it detects:** Kerberos policy changes, domain trust modifications, password policy alterations
- **Operation #:** 11 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000075-Auth-Policy-Change/README.md)

---

## Privilege Use Category

**Purpose:** Audit the exercise of powerful Windows rights and privileges.

### WN11-AU-000115 — Sensitive Privilege Use (Success)
- **Subcategory:** Sensitive Privilege Use
- **Event Type:** Success
- **Event ID:** 4673
- **What it detects:** Exercise of high-value privileges: SeDebugPrivilege, SeLoadDriverPrivilege, SeTcbPrivilege, SeImpersonatePrivilege
- **Operation #:** 1 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-AU-000115-Sensitive-Privilege-Use/README.md)

---

## Security Options (Registry)

**Purpose:** System-level security configuration enforced via registry settings.

### WN11-SO-000215 — NTLM SSP Minimum Session Security
- **Registry Path:** `HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0`
- **Value:** `NTLMMinClientSec = 537395200` (NTLMv2 + 128-bit encryption)
- **What it prevents:** NTLM downgrade attacks, weak encryption negotiation, session hijacking
- **Operation #:** 4 of 11
- [→ Full Finding Details](../01-findings-remediated/WN11-SO-000215-NTLM-Session-Security/README.md)

---

[← Back to Main README](../README.md)

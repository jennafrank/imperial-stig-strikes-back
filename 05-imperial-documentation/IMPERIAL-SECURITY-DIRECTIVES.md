<div align="center">

![Imperial Security Division](https://img.shields.io/badge/⚫%20IMPERIAL%20SECURITY%20DIVISION-CLASSIFIED-red?style=for-the-badge&labelColor=000000)
![Directives](https://img.shields.io/badge/Document-Security%20Directives-red?style=for-the-badge)
![Classification](https://img.shields.io/badge/Classification-CLASSIFIED-darkred?style=for-the-badge)

</div>

# Imperial Security Directives

Reference document outlining the security principles, standards, and directives that governed the `imperial-win11` STIG remediation campaign. These directives translate DoD DISA STIG requirements into operational guidance.

---

## Directive 1 — Audit Logging Is Non-Negotiable

> *"What cannot be observed cannot be defended. Every action on an Imperial system must be accountable."*

**Basis:** NIST SP 800-92, DoD DISA STIG AU family
**Implementation:** All 10 audit policy remediations in this campaign

Security event logging is the foundation of all detection, response, and forensic capability. A system that does not log its own activity is operationally blind — unable to detect intrusions in progress, unable to reconstruct incidents after the fact, and unable to attribute actions to accounts.

**Required audit categories (all now enabled on `imperial-win11`):**

| Category | Subcategory | Event Type |
|----------|-------------|-----------|
| Account Logon | Credential Validation | Failure |
| Account Logon | Logon | Success and Failure |
| Account Management | User Account Management | Success |
| DS Access | Directory Service Access | Success |
| Logon/Logoff | Logoff | Success |
| Object Access | Handle Manipulation | Success |
| Policy Change | Audit Policy Change | Success |
| Policy Change | Authentication Policy Change | Success |
| Privilege Use | Sensitive Privilege Use | Success |

---

## Directive 2 — Authentication Security Standards

> *"Weak authentication is an open gate. The Empire does not leave its gates open."*

**Basis:** DoD DISA STIG WN11-SO-000215, NIST SP 800-63
**Implementation:** WN11-SO-000215 NTLM SSP registry remediation

All NTLM-based authentication sessions on Imperial endpoints must enforce:
- **NTLMv2 session security** — Prohibit NTLMv1 and LM authentication
- **128-bit session encryption** — Prohibit 56-bit and 40-bit legacy encryption

**Registry enforcement:** `NTLMMinClientSec = 537395200 (0x20080000)`

This directive prevents authentication downgrade attacks that would allow adversaries to intercept and crack authentication material or conduct pass-the-hash attacks against Imperial systems.

---

## Directive 3 — Evidence Preservation Before Action

> *"Before striking, the Imperial Commander ensures the ability to retreat. Backup before remediation."*

**Basis:** Change management best practices, NIST SP 800-40
**Implementation:** Pre-remediation `auditpol` export in `remediation-script.ps1`

No hardening operation may be executed on a production Imperial endpoint without:

1. **Exporting the current configuration** to a timestamped backup
2. **Verifying the backup** is complete and readable
3. **Documenting the rollback procedure** before any changes are applied

The `remediation-script.ps1` enforces this directive by aborting the entire remediation if the backup phase fails.

---

## Directive 4 — Verify, Then Trust

> *"The Empire does not assume success. Every operation is verified before it is declared complete."*

**Basis:** NIST SP 800-137, Continuous Monitoring
**Implementation:** Inline verification in `remediation-script.ps1`, post-campaign Nessus rescan

Every remediation action must be immediately followed by verification. In this campaign:

**Layer 1 — Inline verification:** After each `auditpol /set` command, the script immediately runs `auditpol /get` and checks for the expected setting. A `✓ Successfully configured` or `✗ Configuration verification failed` message is written to the log.

**Layer 2 — Scan-based verification:** A full Nessus STIG compliance rescan was executed after all remediations were applied, using identical scan parameters as the baseline assessment. This provides independent, tool-based verification that each finding was resolved to the scanner's satisfaction.

---

## Directive 5 — Document Everything

> *"The campaign that isn't documented didn't happen. Imperial Security Division preserves its operational record."*

**Basis:** DoD 8500.01, NIST SP 800-53 AU-9
**Implementation:** This repository

Every STIG finding, every remediation command, every verification output, and every compliance metric from this campaign is preserved in this repository. The documentation serves three purposes:

1. **Operational record** — What was done, when, and with what result
2. **Knowledge transfer** — How to repeat or audit the remediation
3. **Compliance evidence** — Proof of remediation for auditors and commanders

Documentation is not optional. Undocumented remediations are not considered complete.

---

## Applicable Standards & Frameworks

| Standard | Applicability |
|----------|--------------|
| **DoD DISA STIG — Windows 11** | Primary compliance framework for this campaign |
| **NIST SP 800-92** — Guide to Computer Security Log Management | Audit logging principles |
| **NIST SP 800-53** — Security and Privacy Controls | AC, AU, IA control families |
| **NIST SP 800-63** — Digital Identity Guidelines | Authentication assurance levels |
| **NIST SP 800-137** — Information Security Continuous Monitoring | Verification and ongoing compliance |
| **DoD 8500.01** — Cybersecurity | DoD-wide cybersecurity policy |

---

## Campaign Compliance Statement

The Imperial STIG Remediation Campaign on `imperial-win11` was conducted in full accordance with these directives:

- ✅ All audit logging gaps identified and remediated
- ✅ Authentication security standards enforced via registry configuration
- ✅ Pre-remediation backup executed and verified
- ✅ All 11 remediations verified inline and via rescan
- ✅ Complete operational documentation preserved in this repository

**Campaign Status: MISSION ACCOMPLISHED**

---

*This document is an Imperial Security Division classified operational reference.*
*Distribution: Imperial Security Division and authorized command personnel only.*

---

[← Back to Main README](../README.md)

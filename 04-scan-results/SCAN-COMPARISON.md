<div align="center">

![Imperial Security Division](https://img.shields.io/badge/⚫%20IMPERIAL%20SECURITY%20DIVISION-CLASSIFIED-red?style=for-the-badge&labelColor=000000)
![Analysis](https://img.shields.io/badge/Document-Scan%20Comparison-blue?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Tenable%20Nessus-darkred?style=for-the-badge)

</div>

# Scan Comparison Analysis

**Before:** `scan-before.csv` — Nessus STIG baseline scan of `imperial-win11`
**After:** `scan-after.csv` — Nessus STIG verification scan of `imperial-win11`

Both scans used identical policy, credentials, and scope (Plugin 21156 — Windows Compliance Checks, DoD STIG for Windows 11).

---

## Compliance Metrics: Before vs. After

| Metric | Before Scan | After Scan | Change |
|--------|:-----------:|:----------:|:------:|
| **PASSED (Compliant)** | 158 | 173 | ▲ **+15** |
| **FAILED (Non-Compliant)** | 185 | 170 | ▼ **-15** |
| **HIGH Severity Findings** | 155 | 138 | ▼ **-17** |
| **Total Checks Evaluated** | 343 | 343 | — |
| **Total Plugin Results** | 13,593 rows | 14,554 rows | — |

### Compliance Rate

```
BEFORE  ████████████░░░░░░░░░  46.0% Compliant  (158/343)
AFTER   █████████████░░░░░░░░  50.4% Compliant  (173/343)

                          +4.4 percentage points
                          +15 controls brought into compliance
                          -17 HIGH severity findings closed
```

---

## Scan File Details

### scan-before.csv

| Parameter | Value |
|-----------|-------|
| **Scan Start** | `2026-06-23T21:36:33Z` |
| **Scan End** | `2026-06-23T21:57:14Z` |
| **Duration** | ~20 minutes |
| **Target** | `imperial-win11` / `10.0.0.105` |
| **Scan Type** | Authenticated compliance scan |
| **Plugin** | 21156 — Windows Compliance Checks |
| **Total Rows** | 13,593 |
| **PASSED** | 158 |
| **FAILED** | 185 |
| **HIGH Severity** | 155 |

### scan-after.csv

| Parameter | Value |
|-----------|-------|
| **Scan Start** | `2026-06-23T23:42:26Z` |
| **Scan End** | `2026-06-24T00:01:48Z` |
| **Duration** | ~19 minutes |
| **Target** | `imperial-win11` / `10.0.0.105` |
| **Scan Type** | Authenticated compliance scan (same policy as baseline) |
| **Plugin** | 21156 — Windows Compliance Checks |
| **Total Rows** | 14,554 |
| **PASSED** | 173 |
| **FAILED** | 170 |
| **HIGH Severity** | 138 |

> **Note:** The row count difference between scans (13,593 vs. 14,554) is normal. Nessus compliance scans include variable numbers of informational plugin results between runs depending on system state, enabled features, and discovered services. The compliance check count (343 evaluated controls) remained consistent between scans.

---

## Remediations Confirmed in After Scan

The following 11 STIG controls moved from **FAILED → PASSED** in the verification scan:

| STIG ID | Finding | Before | After |
|---------|---------|--------|-------|
| WN11-AU-000005 | Audit Credential Validation — Failure | FAILED | PASSED |
| WN11-AU-000020 | Audit Logon — Success | FAILED | PASSED |
| WN11-AU-000025 | Audit Logon — Failure | FAILED | PASSED |
| WN11-AU-000030 | Audit User Account Management — Success | FAILED | PASSED |
| WN11-AU-000045 | Audit Directory Service Access — Success | FAILED | PASSED |
| WN11-AU-000055 | Audit Logoff — Success | FAILED | PASSED |
| WN11-AU-000070 | Audit Policy Change — Success | FAILED | PASSED |
| WN11-AU-000075 | Audit Authentication Policy Change — Success | FAILED | PASSED |
| WN11-AU-000115 | Audit Sensitive Privilege Use — Success | FAILED | PASSED |
| WN11-AU-000584 | Audit Handle Manipulation — Success | FAILED | PASSED |
| WN11-SO-000215 | NTLM SSP Minimum Session Security | FAILED | PASSED |

> **11 targeted findings remediated → +15 total controls passed.** The additional 4 controls (beyond the 11 targeted) passed because some STIG checks evaluate multiple subcategories in a single check — enabling one audit subcategory satisfied the requirements for related checks that were also failing.

---

## Remaining Findings

The after scan still shows **170 FAILED** controls. These represent:

- Controls outside the scope of this campaign
- Findings requiring Group Policy changes (domain-level enforcement)
- Findings requiring application updates or feature enablement
- Controls with organizational policy exemptions

Future hardening campaigns should prioritize the remaining HIGH severity findings (138 in the after scan).

---

## Scan Files

| File | Description |
|------|-------------|
| [`scan-before.csv`](./scan-before.csv) | Raw Nessus CSV export — baseline scan (13,593 rows) |
| [`scan-after.csv`](./scan-after.csv) | Raw Nessus CSV export — verification scan (14,554 rows) |

Both files are in standard Nessus CSV export format (60 columns) including: Plugin ID, CVE, CVSS Score, Risk, Host, Protocol, Port, Plugin Name, Plugin Family, Plugin Output, and STIG compliance pass/fail status.

---

[← Back to Main README](../README.md)

[← Back to Main README](../../README.md)

---

<div align="center">

![Finding](https://img.shields.io/badge/STIG%20ID-WN11--SO--000215-red?style=for-the-badge)
![Severity](https://img.shields.io/badge/Severity-HIGH-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-REMEDIATED-success?style=for-the-badge)
![Operation](https://img.shields.io/badge/Operation-4%20of%2011-blue?style=for-the-badge)

</div>

# WN11-SO-000215 — NTLM SSP Minimum Session Security

**Category:** Security Options
**Subcategory:** Network Security: Minimum session security for NTLM SSP based clients
**Remediation Method:** Registry — `HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0`
**Registry Value:** `NTLMMinClientSec` = `537395200` (0x20080000)

---

## The Vulnerability

The Windows 11 system had **insufficient minimum session security requirements for NTLM SSP-based connections**. The system was not enforcing both NTLMv2 session security **and** 128-bit encryption on outbound NTLM connections, leaving network authentication sessions vulnerable to downgrade attacks and session hijacking.

NTLM (NT LAN Manager) is a legacy authentication protocol still widely used in Windows environments for backward compatibility. Without enforcing minimum session security standards, a man-in-the-middle attacker can negotiate weaker security parameters — forcing the use of NTLMv1 or weak encryption — and then intercept or crack the authentication exchange.

**Without this control enforced:**
- Connections may negotiate NTLMv1 (cryptographically broken, crackable in seconds with modern hardware)
- Sessions may use weak 56-bit or 40-bit encryption rather than 128-bit
- Authentication exchanges become vulnerable to pass-the-hash attacks and offline cracking

---

## Remediation Command

```powershell
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0" `
    -Name "NTLMMinClientSec" `
    -Value 537395200 `
    -Type DWord -Force
```

### How It Works

The registry value `NTLMMinClientSec` is a bitmask that controls the minimum security requirements for NTLM SSP-based client sessions. The value `537395200` (hexadecimal `0x20080000`) is the bitwise combination of two flags:

| Flag | Hex Value | Meaning |
|------|-----------|---------|
| `NTLMSSP_NEGOTIATE_NTLM2` | `0x00080000` | Require NTLMv2 session security |
| `NTLMSSP_NEGOTIATE_128` | `0x20000000` | Require 128-bit encryption |

Setting both flags ensures that NTLM connections from this client will refuse to downgrade to weaker security levels — the connection will fail rather than proceed with insufficient security.

**Registry path:** `HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0`
**Value name:** `NTLMMinClientSec`
**Value type:** `DWORD`
**Value:** `537395200` (`0x20080000`)

---

## Verification Command

```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0" -Name "NTLMMinClientSec"
```

**Expected Output:**

```
NTLMMinClientSec : 537395200
```

Alternatively, verify via Group Policy audit:
- Navigate to: `Computer Configuration → Windows Settings → Security Settings → Local Policies → Security Options`
- Policy: **Network security: Minimum session security for NTLM SSP based (including secure RPC) clients**
- Expected setting: **Require NTLMv2 session security, Require 128-bit encryption**

---

## In the Remediation Script

This finding was addressed as **Finding 4 of 11** in `remediation-script.ps1`:

```powershell
# REMEDIATION 4: WN11-SO-000215
# NTLM SSP Minimum Session Security
# Value 537395200 = 0x20080000 (both NTLMv2 and 128-bit encryption required)
Set-RegistryPolicy `
    -Path "HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0" `
    -Name "NTLMMinClientSec" `
    -Value 537395200 `
    -Description "NTLMv2 + 128-bit encryption requirement"
```

The script's `Set-RegistryPolicy` function reads the current value before modification, applies the change, and verifies the new value — logging `✓ Set to: 537395200` on success or `✗ Verification failed` on failure. **This is the only non-auditpol remediation in this campaign** — it is a registry-based security configuration rather than an audit policy change.

---

## Security Rationale

| Risk | Without Control | With Control |
|------|----------------|--------------|
| **NTLMv1 downgrade** | Attacker forces weak auth | NTLMv2 required — connection refused if not supported |
| **Encryption downgrade** | 40/56-bit encryption negotiable | 128-bit minimum enforced |
| **Pass-the-hash** | NTLM hash replay feasible | NTLMv2 challenge-response reduces replay risk |
| **MITM interception** | Session negotiation manipulable | Minimum security floor prevents downgrade |
| **Compliance** | STIG FAIL | STIG PASS |

### Why This Is the Only Registry-Based Remediation

All other findings in this campaign were addressed via `auditpol` — Windows audit policy configuration. This finding is different: it modifies the Local Security Authority (LSA) configuration, which controls how the operating system handles authentication protocol negotiation. The LSA settings are stored in the registry and must be set there directly (or via Group Policy), not through auditpol.

This distinction also means there is **no audit event generated by this change itself** (unlike audit policy changes, which generate Event ID 4719). The change is verified by reading back the registry value post-modification.

---

[← Back to All Findings](../../README.md#findings-remediated--all-11-operations)

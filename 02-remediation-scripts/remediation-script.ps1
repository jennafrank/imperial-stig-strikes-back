# Windows 11 STIG Remediation Script
# Purpose: Remediate 11 HIGH severity audit policy and security configuration findings
# Requires: Administrator privileges
# Usage: .\remediation-script.ps1 -WhatIf (preview) or .\remediation-script.ps1 (apply)

[CmdletBinding(SupportsShouldProcess)]
param()

# ============================================================================
# CONFIGURATION & LOGGING
# ============================================================================

$BackupPath = "C:\Windows\Temp\STIG-Backups"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $BackupPath "remediation-log_$Timestamp.txt"
$BackupFile = Join-Path $BackupPath "audit-policy-backup_$Timestamp.csv"

# Create backup directory
if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
}

# ============================================================================
# LOGGING FUNCTION
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Write-Host $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

# Initialize log file
Write-Log "=== Windows 11 STIG Remediation Started ===" 'INFO'
Write-Log "Timestamp: $Timestamp" 'INFO'
Write-Log "WhatIf Mode: $($PSCmdlet.ShouldProcess('dummy'))" 'INFO'

# ============================================================================
# BACKUP FUNCTION
# ============================================================================

function Backup-AuditPolicy {
    Write-Log "Backing up current audit policy..." 'INFO'
    
    try {
        $auditPolicy = auditpol /get /category:* /csv | Out-String
        $auditPolicy | Out-File -FilePath $BackupFile -Force
        Write-Log "Audit policy backed up to: $BackupFile" 'SUCCESS'
        return $true
    }
    catch {
        Write-Log "FAILED to backup audit policy: $_" 'ERROR'
        return $false
    }
}

# ============================================================================
# REMEDIATION FUNCTIONS
# ============================================================================

function Set-AuditPolicy {
    param(
        [string]$Category,
        [string]$Subcategory,
        [string]$AuditType
    )
    
    $DisplayName = "$Category > $Subcategory ($AuditType)"
    
    if ($PSCmdlet.ShouldProcess($DisplayName, "Enable audit policy")) {
        Write-Log "Configuring: $DisplayName" 'INFO'
        
        try {
            auditpol /set /subcategory:"$Subcategory" /category:"$Category" /$AuditType`:enable
            
            # Verify the change
            $result = auditpol /get /subcategory:"$Subcategory" /category:"$Category" | Select-String $AuditType
            
            if ($result) {
                Write-Log "  ✓ Successfully configured" 'SUCCESS'
                return $true
            }
            else {
                Write-Log "  ✗ Configuration verification failed" 'ERROR'
                return $false
            }
        }
        catch {
            Write-Log "  ✗ Error: $_" 'ERROR'
            return $false
        }
    }
    else {
        Write-Log "  [WhatIf] Would configure: $DisplayName" 'INFO'
        return $true
    }
}

function Set-RegistryPolicy {
    param(
        [string]$Path,
        [string]$Name,
        [int]$Value,
        [string]$Description
    )
    
    if ($PSCmdlet.ShouldProcess($Description, "Set registry value")) {
        Write-Log "Configuring: $Description" 'INFO'
        
        try {
            # Ensure path exists
            if (-not (Test-Path $Path)) {
                New-Item -Path $Path -Force | Out-Null
            }
            
            # Get current value for logging
            $CurrentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
            Write-Log "  Current value: $CurrentValue" 'INFO'
            
            # Set the value
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord -Force
            
            # Verify
            $NewValue = (Get-ItemProperty -Path $Path -Name $Name).$Name
            if ($NewValue -eq $Value) {
                Write-Log "  ✓ Set to: $Value" 'SUCCESS'
                return $true
            }
            else {
                Write-Log "  ✗ Verification failed. Value is: $NewValue" 'ERROR'
                return $false
            }
        }
        catch {
            Write-Log "  ✗ Error: $_" 'ERROR'
            return $false
        }
    }
    else {
        Write-Log "  [WhatIf] Would set $Name to $Value" 'INFO'
        return $true
    }
}

# ============================================================================
# BACKUP BEFORE STARTING
# ============================================================================

$BackupSuccess = Backup-AuditPolicy
if (-not $BackupSuccess) {
    Write-Log "CRITICAL: Backup failed. Aborting remediation." 'ERROR'
    Write-Log "=== Remediation Failed ===" 'ERROR'
    exit 1
}

# ============================================================================
# REMEDIATION 1: WN11-AU-000115
# Audit Privilege Use - Sensitive Privilege Use (Success)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 1/11: WN11-AU-000115 ---" 'INFO'
Write-Log "Enable: Audit Sensitive Privilege Use (Success)" 'INFO'

Set-AuditPolicy -Category "Privilege Use" -Subcategory "Sensitive Privilege Use" -AuditType "success"

# ============================================================================
# REMEDIATION 2: WN11-AU-000584
# Audit Handle Manipulation (Success)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 2/11: WN11-AU-000584 ---" 'INFO'
Write-Log "Enable: Audit Handle Manipulation (Success)" 'INFO'

Set-AuditPolicy -Category "Object Access" -Subcategory "Handle Manipulation" -AuditType "success"

# ============================================================================
# REMEDIATION 3: WN11-AU-000005
# Audit Credential Validation (Failure)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 3/11: WN11-AU-000005 ---" 'INFO'
Write-Log "Enable: Audit Credential Validation (Failure)" 'INFO'

Set-AuditPolicy -Category "Account Logon" -Subcategory "Credential Validation" -AuditType "failure"

# ============================================================================
# REMEDIATION 4: WN11-SO-000215
# NTLM SSP Minimum Session Security
# Require NTLMv2 session security AND 128-bit encryption
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 4/11: WN11-SO-000215 ---" 'INFO'
Write-Log "Set: NTLM SSP minimum session security (NTLMv2 + 128-bit encryption)" 'INFO'

# Value 537395200 = 0x20080000 (both NTLMv2 and 128-bit encryption required)
Set-RegistryPolicy `
    -Path "HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0" `
    -Name "NTLMMinClientSec" `
    -Value 537395200 `
    -Description "NTLMv2 + 128-bit encryption requirement"

# ============================================================================
# REMEDIATION 5: WN11-AU-000020
# Audit Account Logon Events (Success)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 5/11: WN11-AU-000020 ---" 'INFO'
Write-Log "Enable: Audit Account Logon Events (Success)" 'INFO'

Set-AuditPolicy -Category "Account Logon" -Subcategory "Logon" -AuditType "success"

# ============================================================================
# REMEDIATION 6: WN11-AU-000025
# Audit Account Logon Events (Failure)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 6/11: WN11-AU-000025 ---" 'INFO'
Write-Log "Enable: Audit Account Logon Events (Failure)" 'INFO'

Set-AuditPolicy -Category "Account Logon" -Subcategory "Logon" -AuditType "failure"

# ============================================================================
# REMEDIATION 7: WN11-AU-000030
# Audit Account Management (Success)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 7/11: WN11-AU-000030 ---" 'INFO'
Write-Log "Enable: Audit Account Management (Success)" 'INFO'

Set-AuditPolicy -Category "Account Management" -Subcategory "User Account Management" -AuditType "success"

# ============================================================================
# REMEDIATION 8: WN11-AU-000045
# Audit Directory Service Access (Success)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 8/11: WN11-AU-000045 ---" 'INFO'
Write-Log "Enable: Audit Directory Service Access (Success)" 'INFO'

Set-AuditPolicy -Category "DS Access" -Subcategory "Directory Service Access" -AuditType "success"

# ============================================================================
# REMEDIATION 9: WN11-AU-000055
# Audit Logoff (Success)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 9/11: WN11-AU-000055 ---" 'INFO'
Write-Log "Enable: Audit Logoff (Success)" 'INFO'

Set-AuditPolicy -Category "Logon/Logoff" -Subcategory "Logoff" -AuditType "success"

# ============================================================================
# REMEDIATION 10: WN11-AU-000070
# Audit Policy Change (Success)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 10/11: WN11-AU-000070 ---" 'INFO'
Write-Log "Enable: Audit Policy Change (Success)" 'INFO'

Set-AuditPolicy -Category "Policy Change" -Subcategory "Audit Policy Change" -AuditType "success"

# ============================================================================
# REMEDIATION 11: WN11-AU-000075
# Audit Authentication Policy Change (Success)
# ============================================================================

Write-Log "" 'INFO'
Write-Log "--- Finding 11/11: WN11-AU-000075 ---" 'INFO'
Write-Log "Enable: Audit Authentication Policy Change (Success)" 'INFO'

Set-AuditPolicy -Category "Policy Change" -Subcategory "Authentication Policy Change" -AuditType "success"

# ============================================================================
# VERIFICATION
# ============================================================================

Write-Log "" 'INFO'
Write-Log "=== Verification ===" 'INFO'
Write-Log "Running audit policy verification..." 'INFO'

$VerifyOutput = auditpol /get /category:*
Write-Log $VerifyOutput 'INFO'

Write-Log "" 'INFO'
Write-Log "=== Remediation Completed ===" 'SUCCESS'
Write-Log "Review the full log at: $LogFile" 'INFO'
Write-Log "Backup file at: $BackupFile" 'INFO'

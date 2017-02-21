#Requires -Version 3.0
<#
.SYNOPSIS
    LockOut-User will lock all users in a given OU.
.DESCRIPTION
    LockOut-User will lock all users in a given OU. This script can be executed from a DC.  
    
    Prerequisites: Modules ActiveDirectory, GroupPolicy
.NOTES
  Version:        1.0
  Author:         Bart Tacken - Client ICT Groep
  Creation Date:  21-02-2017
  Purpose/Change: Initial script development
.EXAMPLE
    LockOut-User.ps1
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'
#----------------------------------------------------------[Declarations]----------------------------------------------------------
 $DC = "<FQDN DC>"
 $OU = "<OU location>"
#-----------------------------------------------------------[Execution]------------------------------------------------------------
 if ($LockoutBadCount = ((([xml](Get-GPOReport -Name "Default Domain Policy" -ReportType Xml)).GPO.Computer.ExtensionData.Extension.Account |
            Where-Object name -eq LockoutBadCount).SettingNumber)) {
 
    $Password = ConvertTo-SecureString 'NotMyPassword' -AsPlainText -Force
 
    Get-ADUser -Filter * -SearchBase $OU -Properties SamAccountName, UserPrincipalName, LockedOut |
        ForEach-Object {
 
            for ($i = 1; $i -le $LockoutBadCount; $i++) { 
 
                Invoke-Command -ComputerName $DC {Get-Process
                } -Credential (New-Object System.Management.Automation.PSCredential ($($_.UserPrincipalName), $Password)) -ErrorAction SilentlyContinue            
 
            }
 
            Write-Output "$($_.SamAccountName) has been locked out: $((Get-ADUser -Identity $_.SamAccountName -Properties LockedOut).LockedOut)"
        }
}

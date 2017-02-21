#Requires -Version 3.0
<#
.SYNOPSIS
    Get-LockedOutUser.ps1 returns a list of users who were locked out in Active Directory.
.DESCRIPTION
    Get-LockedOutUser.ps1 is an advanced script that returns a list of users who were locked out in Active Directory
    by querying the event logs on a DC.

    Prerequisite is to enable Auditing on the right account events:
    Computer Configuration > Policies → Windows Settings → Security Settings → Advanced Audit Policy Configuration → Audit Policies → 
    Account Management: Audit User Account Management → Define → Success and Failures.
.PARAMETER UserName
    The userid of the specific user you are looking for lockouts for. The default is all locked out users.
.PARAMETER StartTime
    The datetime to start searching from. The default is all datetimes that exist in the event logs.
.NOTES
  Version:        1.0
  Author:         Bart Tacken - Client ICT Groep
  Creation Date:  21-02-2017
  Purpose/Change: Initial script development
.EXAMPLE
    Get-LockedOutUser.ps1
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'
#----------------------------------------------------------[Declarations]----------------------------------------------------------
$UserArray = @()
[string]$DomainName = $env:USERDOMAIN
[string]$UserName = "*"
[datetime]$StartTime = (Get-Date).AddDays(-5)
#-----------------------------------------------------------[Execution]------------------------------------------------------------

Get-WinEvent -FilterHashtable @{LogName='Security';Id=4740;StartTime=$StartTime} |
Where-Object {$_.Properties[0].Value -like "$UserName"} |
ForEach $PSITEM {
    $UserArray += New-Object -TypeName PSObject -Property @{ # Fill Array with custom objects
        'TimeCreated' = $($_.TimeCreated)
        'UserName' = $($_.Properties[0].Value)
        'ClientName' = $($_.Properties[1].Value)
    } # End PS Object
} # End ForEach

Write-output $UserArray | Sort-Object TimeCreated | Select-Object TimeCreated, UserName, ClientName

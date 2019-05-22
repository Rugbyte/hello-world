#Requires -Version 5.1
#Requires -Modules ActiveDirectory
#Requires -RunAsAdministrator

<#
.SYNOPSIS
  Used to create users within IMImobile North American Domain

.DESCRIPTION
  <Brief description of script>

.PARAMETER userName
  The user name of the new user.
  The default is fistname.lastname

.PARAMETER firstName
  The first name of the new user

.PARAMETER lastName
  The last name of the new user
  
.PARAMETER role
  The role in which the user has been hired for. 
  This currently only works for the following:

.PARAMETER title
  The title of the user that is being created. 
    
.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  Log file stored in %CurrentDirectory%\Create-User-userName.log

.NOTES
  Version:        1.7
  Author:         Simon Varlow
  Creation Date:  October 19,2018 
  Purpose/Change: Initial script development
  
.EXAMPLE
  .\Create-User.ps1 -username "gjungle" -firstname George -lastname Jungle -role SysAdmin -title "King of the Jungle"

.EXAMPLE
  .\Create-User.ps1 -firstname George -lastname Jungle -role SysAdmin -title "King of the Jungle"
#>

Param(
    [Parameter(Mandatory = $true)][string] $role,
    [Parameter(Mandatory = $true)][string] $firstName,
    [Parameter(Mandatory = $true)][string] $lastName,
    [Parameter(Mandatory = $false)][string] $userName,
    [Parameter(Mandatory = $false)][string] $title,
    [Parameter(Mandatory = $false)][switch] $WhatIf

)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries\
$currentDirectory = Get-Location
$PSLoggingModule = Join-Path -Path $currentDirectory -ChildPath "\Module\PSLogging\PSLogging.psm1"
Import-Module $PSLoggingModule

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.7"

# End user information
$fullName = $firstName + " " + $lastName
$initials = $firstName[0] + $lastName[0]
if (!$username) {
    $userName = $firstName.ToLower() + "." + $lastName.ToLower()
}
$email = $userName + "@domain.com"

#Log File Info
$sLogPath = Get-Location
$sLogName = "Create-User-$($userName).log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

$adGroupsAdd = @()

# Role information 
switch ($role) {
    "sysadmin" { 
        $department = "Example"
        $manager = "Manger.Username" 
        $adGroupsAdd += ("", "")    
        $description = "User account"
        $ouPath = "OU=Example,OU=UserAccounts,DC=FABRIKAM,DC=COM"
        $passwordNeverExpires = $false
    }
    "servicesaccounts" { 
        $department = "Service Accounts"
        $description = "Service Account for "
        $ouPath = "OU=Example,OU=UserAccounts,DC=FABRIKAM,DC=COM"
        $passwordNeverExpires = $true
    }
    Default { Throw "Invalid role has been used" }
}

switch ($location) {
    "ExampleLocation" { 
        $userPrincipalName = $username + "@domain.com"
        $adGroupsAdd += ("", "")
        $office = ""
        $company = ""
        $officePhone = ""
        $fax = ""
        $streetAddress = ""
        $poBox = ""
        $city = ""
        $state = ""
        $country = ""
        $postalCode = ""
    }
    Default { Throw "Current site of $($location) is not supported. Please reach out to the DevOps team to add in $($location)." }
}

# New Password
Add-type -AssemblyName System.Web
$password = [system.web.security.membership]::GeneratePassword(14, 2)

#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function ADUserCreation {
    Param(
        [Parameter(Mandatory = $false)][string] $fullName,
        [Parameter(Mandatory = $false)][string] $firstName,
        [Parameter(Mandatory = $false)][string] $lastName,
        [Parameter(Mandatory = $true)][string] $userName,
        [Parameter(Mandatory = $true)][string] $userPrincipalName,
        [Parameter(Mandatory = $false)][string] $title,
        [Parameter(Mandatory = $true)][string] $ouPath,
        [Parameter(Mandatory = $false)][switch] $WhatIf
    )
  
    Begin {
        Write-LogInfo -LogPath $sLogFile -Message "Creating AD User $($userName)..."
        Write-Host "Creating AD User $($userName)..."
    }
  
    Process {
        Try {
            $password = ConvertTo-SecureString $password -AsPlainText -Force
            # https://docs.microsoft.com/en-us/powershell/module/addsadministration/new-aduser?view=win10-ps
            New-ADUser `
                -AccountPassword $password `
                -ChangePasswordAtLogon $true `
                -City $city `
                -Company $company `
                -Country $country `
                -Department $department `
                -Description $description `
                -DisplayName $fullName `
                -EmailAddress "$($firstName.ToLower()).$($lastName.ToLower())@domain.com" `
                -Enabled $true `
                -Fax $fax `
                -GivenName $firstName `
                -Initials $initials `
                -Manager $manager `
                -Name $fullName `
                -Office $office `
                -OfficePhone $officePhone `
                -PasswordNeverExpires $passwordNeverExpires `
                -Path $ouPath `
                -POBox $poBox `
                -PostalCode $postalCode `
                -SamAccountName $userName `
                -Server $adServer `
                -State $state `
                -StreetAddress $streetAddress `
                -Surname $lastName `
                -Title $title `
                -UserPrincipalName $userPrincipalName `
                -WhatIf:$whatif 
        }
    
        Catch {
            Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully $True
            Break
        }
    }
  
    End {
        If ($?) {
            Write-LogInfo -LogPath $sLogFile -Message "Completed Successfully.`n"
            Write-Host "Completed Successfully.`n"
        }
    }
}

Function ADGroups {
    Param(
        [Parameter(Mandatory = $true)][string] $userName,
        [Parameter(Mandatory = $true)][array] $groups,
        [Parameter(Mandatory = $false)][switch] $WhatIf     
    )
  
    Begin {
        Write-LogInfo -LogPath $sLogFile -Message "Starting to add user to groups..."
        Write-Host "Starting to add user to groups..."
    }
  
    Process {
        Try {
            foreach ($group in $groups) {
                Write-LogInfo -LogPath $sLogFile -Message "Adding $($userName) to $($group)..."
                Write-Host "Adding $($userName) to $($group)..."
                
                Add-ADGroupMember -Identity $group -Members $userName -WhatIf:$WhatIf
                
                Write-LogInfo -LogPath $sLogFile -Message "Complete..."
                Write-Host "Complete..."
            }
        }
    
        Catch {
            Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully $True
            Break
        }
    }
  
    End {
        If ($?) {
            Write-LogInfo -LogPath $sLogFile -Message "Completed Successfully.`n"
            Write-Host "Completed Successfully.`n"
        }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
#Script Execution goes here

Write-Host "Starting Execution of script"

$userExists = Get-ADUser -Filter { sAMAccountName -eq $userName }

if ( $null -eq $userExists ) {
    ADUserCreation -fullName $fullName -firstName $firstName -lastName $lastName -userName $userName -userPrincipalName $userPrincipalName -title $title -ouPath $ouPath -WhatIf:$WhatIf
    if ($adGroupsAdd -ge 1) {
        ADGroups -username $userName -groups $adGroupsAdd -WhatIf:$WhatIf
    } 
    Write-Host $("#" * 80)
    Write-Host "New User Complete Information"
    Write-Host "User created on: $(Get-Date)"
    Write-Host "User Created by: $($currentUser)"
    Write-Host "New User: $($fullName) - $($userName) has been created with the role $($role)"
    Write-Host "Temporary Password: $($password) has been set for $($userName)"
    Write-Host "User's manager set to $($manager)"
    Write-Host "User added to Jira Groups: $($jiragroups)"
    Write-Host $("#" * 80)
    #Write-Host ""
}
else {
    Write-Host $("#" * 80)
    Write-Host "New User not created"
    Write-Host "User $($userName) already exists within Active Directory"
    Write-Host $("#" * 80)
}

Write-Host "Script has completed"

Stop-Log -LogPath $sLogFile


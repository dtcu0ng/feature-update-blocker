#Requires -Version 5.1

function GetAdmin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "Administrators right not found, trying to restart the script with Administrators right. You may need to run this script as Administrators manually" -ForegroundColor Red
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        Exit
    }
}
$RootRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
function Header {
    $Global:OSBuildNumber = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "CurrentBuildNumber").CurrentBuildNumber
    $Global:OSVersionNumber = $(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
    Write-Output "-----------------------------------------------------------------"
    Write-Output "Feature Update Blocker - v22.8.3 (the enabler one)"
    Write-Output "https://github.com/dtcu0ng/feature-update-blocker"
    Write-Output "Made with <3 by dtcu0ng"
    Write-Output "-----------------------------------------------------------------"
    Write-Output "Windows Version: $OSVersionNumber"
    Write-Output "Windows Build: $OSBuildNumber"
    Write-Output "-----------------------------------------------------------------"
    Write-Output "`n"
}

function CheckBuild {

}


function CheckRequirements {
    If ($OSVersionNumber -lt 1607 -and $OSVersionNumber -lt 14393) {
        Write-Host "This script support Windows 10 version 1607 or later"
        Write-Host "You have: $OSBuildNumber (version: $OSVersionNumber)"
    } else {
        RemoveBlockFeatureUpdate
    } 
}

function Test-RegistryValue { # thanks: https://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html

    param (
    
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
    
    [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )
    
    try {
    
    Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
     return $true
     }
    
    catch {
    
    return $false
    
    }
    
    }
    

function RemoveBlockFeatureUpdate {

    function RemoveFUBlockRegs {
        If ($(Test-RegistryValue -Path "$RootRegPath" -Value "TargetReleaseVersion") -eq "True") {
            Remove-ItemProperty -Path "$RootRegPath" -Name "TargetReleaseVersion"
        }

        If ($(Test-RegistryValue -Path "$RootRegPath" -Value "TargetReleaseVersionInfo") -eq "True") {
            Remove-ItemProperty -Path "$RootRegPath" -Name "TargetReleaseVersionInfo"
        }
    }
    Write-Output "Starting patching the registry..."
    If (Test-Path -Path "$RootRegPath") {
        RemoveFUBlockRegs
    } Else {
        Write-Host "$RootRegPath not exist. This mean the blocker was not run before"
        Read-Host -Prompt "`nPress Enter to exit"
        Exit
    }

    Write-Host "`nFeature Update enabled."
    Read-Host -Prompt "`nPress Enter to exit"
}

function Main {
    GetAdmin
    Header
    CheckBuild
    CheckRequirements
}

Main
#Requires -Version 5.1

function GetAdmin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Output "Administrators right not found, trying to restart the script with Administrators right. You may need to run this script as Administrators manually"
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        Exit
    }
}

$RootRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$OSBuildNumber = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "CurrentBuildNumber").CurrentBuildNumber
$OSVersionNumber = $(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId

function Header {
    Write-Output "-----------------------------------------------------------------"
    Write-Output "Feature Update Blocker - v22.8.3 (the blocker one)"
    Write-Output "https://github.com/dtcu0ng/feature-update-blocker"
    Write-Output "Made with <3 by dtcu0ng"
    Write-Output "-----------------------------------------------------------------"
    Write-Output "Windows Version: $OSVersionNumber"
    Write-Output "Windows Build: $OSBuildNumber"
    Write-Output "-----------------------------------------------------------------"
    Write-Output "`n"
}

function CheckRequirements {
    If ($OSVersionNumber -lt 1803 -and $OSVersionNumber -lt 17134) {
        Write-Output "This script support Windows 10 version 1803 or newer"
        Write-Output "You have: $OSBuildNumber (version: $OSVersionNumber)"
        Read-Host -Prompt "`nPress Enter to exit"
    } else {
        BlockFeatureUpdate
    }
}

function Test-RegistryValue { # thanks: https://stackoverflow.com/questions/5648931/test-if-registry-value-exists
    Param([String]$Path, [String]$Value)
    return [bool]((Get-itemproperty -Path $Path).$Value)
}

function BlockFeatureUpdate {

    function AddFUBlock {
        If ($(Test-RegistryValue -Path "$RootRegPath" -Value "TargetReleaseVersion") -eq "True") {
            Set-ItemProperty -Path "$RootRegPath" -Name "TargetReleaseVersion" -Value 1
        } Else {
            New-ItemProperty -Path "$RootRegPath" -Name "TargetReleaseVersion" -Value 1 -PropertyType "DWORD"
            Write-Output "`n"
        }
        If ($(Test-RegistryValue -Path "$RootRegPath" -Value "TargetReleaseVersionInfo") -eq "True") {
            Set-ItemProperty -Path "$RootRegPath" -Name "TargetReleaseVersionInfo" -Value "$OSVersionNumber"
        } Else {
            New-ItemProperty -Path "$RootRegPath" -Name "TargetReleaseVersionInfo" -Value "$OSVersionNumber" -PropertyType "String"
            Write-Output "`n"
        }
    }
    Write-Output "Starting patching the registry..."
    If (Test-Path -Path "$RootRegPath") {
        AddFUBlock
    } Else {
        Write-Output "$RootRegPath not exist, creating..."
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "WindowsUpdate"
        AddFUBlock
    }
    Write-Output "`nFeature Update blocked."
    Read-Host -Prompt "`nPress Enter to exit"
}

function Main {
    GetAdmin
    Header
    CheckRequirements
}

Main
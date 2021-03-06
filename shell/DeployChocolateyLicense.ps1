[CmdletBinding()]
Param (
    [ValidateSet("Pro", "Bus", "Arch", "MSP")]
    [string]
    $LicenseType = "Bus",

    [string]
    $LicenseRootPath = 'c:\licenses',

    # Allow prerelease versions of chocolatey.extension to be installed
    [switch]
    $AllowPrerelease
)

if (!(Test-Path -Path env:ChocolateyInstall)) {
    Write-Warning 'ChocolateyInstall environment variable not found. Chocolatey not installed?'
    exit
}

$licenseSourcePath = Join-Path -Path $LicenseRootPath -ChildPath "$LicenseType-chocolatey.license.xml"
$licenseDestinationPath = Join-Path -Path $env:ChocolateyInstall -ChildPath 'license\chocolatey.license.xml'

if (!(Test-Path $licenseSourcePath -ErrorAction SilentlyContinue)) {
    Write-Warning "License file '$licenseSourcePath' could not be found. Place manually now."
    exit
}

$path = Split-Path -Path $licenseDestinationPath -Parent
if (!(Test-Path -Path $path -ErrorAction SilentlyContinue)) {
    Write-Host 'License folder not found. Creating.'
    New-Item -ItemType Directory -Path $path | Out-Null
}

Write-Host "Copying license '$licenseSourcePath' to '$licenseDestinationPath'."
Copy-Item -Path $licenseSourcePath -Destination $licenseDestinationPath -Force | Out-Null

# if the -prerelease switch is provided that allow prerelease version of Chocolatey
$chocoCmd = 'choco upgrade chocolatey.extension -y'
if ($AllowPrerelease.IsPresent) {
    $chocoCmd += ' --pre'
}

Invoke-Expression -Command $chocoCmd

#choco feature enable --name="'virusCheck'"
choco feature enable --name="'allowPreviewFeatures'"
choco feature enable --name="'internalizeAppendUseOriginalLocation'"
choco feature enable --name="'reduceInstalledPackageSpaceUsage'"
choco feature disable --name="'showNonElevatedWarnings'"
Param (
    [Parameter(Mandatory=$True)][ValidateNotNull()][string]$wslName,
    [Parameter(Mandatory=$True)][ValidateNotNull()][string]$username,
    [Parameter(Mandatory=$True)][ValidateNotNull()][string]$reinstallWSL,
    [Parameter(Mandatory=$True)][ValidateNotNull()][string]$installAllSoftware
)

Write-Output "Clean up installed $wslName distro"
wsl.exe --terminate $wslName
wsl.exe --unregister $wslName

if ($reinstallWSL -ieq "true") {
    # Preparing WSL
    Write-Output "Uninstalling WSL2"
    wsl.exe --uninstall

    Write-Output "Installing WSL2"
    wsl.exe --install --inbox
    wsl.exe --install
    wsl.exe --update

    Write-Output "Setting WSL2 as default"
    wsl.exe --set-default-version 2
}

# create staging directory if it does not exists
if (-Not (Test-Path -Path .\staging)) { 
    mkdir .\staging 
}

write-output "Downloading Debian"
curl.exe -L -o .\staging\Debian.appx https://aka.ms/wsl-debian-gnulinux

Write-Output "Installing Debian"
Move-Item .\staging\Debian.appx .\staging\$wslName.zip
Expand-Archive .\staging\$wslName.zip .\staging\$wslName
Move-Item .\staging\$wslName\DistroLauncher-*_x64.appx .\staging\$wslName\x64.zip
Expand-Archive .\staging\$wslName\x64.zip .\staging\$wslName\x64


if (-Not (Test-Path -Path C:\dev\WSL)) {
    mkdir C:\dev\WSL
}
if (-Not (Test-Path -Path C:\dev\WSL\$wslName)) {
    mkdir C:\dev\WSL\$wslName
}

wsl.exe --import $wslName C:\dev\WSL\$wslName .\staging\$wslName\x64\install.tar.gz
wsl.exe --set-default $wslName

Remove-Item .\staging\$wslName.zip
Remove-Item -r .\staging\$wslName\

Write-Output "Updating Debian"
wsl -d $wslName -u root bash -ic "apt update"

$wslCurrentPath = wsl wslpath ($PSScriptRoot -replace "\\","/")

Write-Output "Installing ansible"
wsl -d $wslName -u root bash -ic 'apt install ansible -y'

wsl -d $wslName -u root bash -ic "ansible-playbook $wslCurrentPath/ansible/playbook1.yml"

wsl -t $wslName

wsl -d $wslName -u root bash -ic "ansible-playbook $wslCurrentPath/ansible/playbook2.yml"


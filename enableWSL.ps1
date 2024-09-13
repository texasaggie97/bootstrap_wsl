# This will require a reboot to take effect
# https://github.com/kaisalmen/wsltooling/blob/main/enableWSL.ps1
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

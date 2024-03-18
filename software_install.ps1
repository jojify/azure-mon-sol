# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install software using Chocolatey
choco install -y git
choco install -y azure-cli
choco install -y putty
choco install -y vscode
choco install -y googlechrome
choco install -y kubernetes-helm
choco install -y kubernetes-cli
choco install -y tortoisegit
choco install -y lens

Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0

# create .ssh folder and copy teh keys (these are already added in github)
New-Item -ItemType Directory -Force -Path $env:userprofile\.ssh

$pubKeyPath = "id_rsa.pub"
$pvtKeyPath = "id_rsa"

# Check if the .ssh folder exists, and create it if it doesn't
$sshFolderPath = "$env:userprofile\.ssh"
if (!(Test-Path $sshFolderPath)) {
    New-Item -ItemType Directory -Force -Path $sshFolderPath
}

# Copy the public and private key files to the .ssh folder
Copy-Item $pubKeyPath "$sshFolderPath\id_rsa.pub"
Copy-Item $pvtKeyPath "$sshFolderPath\id_rsa"


# Clone the repository to the specified directory
$repoUrl = "git@github.com:jojify/aks-ingress-keycloak.git"
$repoName = "aks-ingress-keycloak"
$repoPath = Join-Path $PSScriptRoot $repoName
git clone $repoUrl $repoPath


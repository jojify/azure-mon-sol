param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [string]$WorkspaceName
)

# Create Log Analytics workspace
$workspace = New-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -Location $Location -Sku "PerGB2018"

# Enable Azure Monitor for the workspace
Set-AzOperationalInsightsIntelligencePack -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -IntelligencePackName "LogManagement" -Enabled $true

# Output the workspace details
Write-Output "Log Analytics Workspace created:"
Write-Output $workspace
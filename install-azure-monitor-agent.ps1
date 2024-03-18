param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceName
)

# Retrieve the Log Analytics workspace
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName

# Retrieve the workspace ID and key
$workspaceId = $workspace.CustomerId
$workspaceKey = (Get-AzOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $ResourceGroupName -Name $WorkspaceName).PrimarySharedKey

# Install the Azure Monitor agent on the VM
$vmExtensionName = "AzureMonitorWindowsAgent"
$vmExtensionPublisher = "Microsoft.Azure.Monitor"
$vmExtensionType = "AzureMonitorWindowsAgent"
$vmExtensionTypeHandlerVersion = "1.0"

Set-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Location $vm.Location `
    -Name $vmExtensionName -Publisher $vmExtensionPublisher -ExtensionType $vmExtensionType `
    -TypeHandlerVersion $vmExtensionTypeHandlerVersion -Settings @{"workspaceId" = $workspaceId} `
    -ProtectedSettings @{"workspaceKey" = $workspaceKey}
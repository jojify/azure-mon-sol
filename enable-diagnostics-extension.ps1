param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceName
)

# Get the VM
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName

# Get the storage account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

# Get the Log Analytics workspace
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName

# Enable Azure Diagnostics extension and send data to Log Analytics workspace
$vmDiagnosticsExtension = Get-AzVMDiagnosticsExtension -ResourceGroupName $ResourceGroupName -VMName $VMName
if ($vmDiagnosticsExtension -eq $null) {
    $vmDiagnosticsExtension = Set-AzVMDiagnosticsExtension -ResourceGroupName $ResourceGroupName -VMName $VMName `
        -DiagnosticsConfigurationPath ".\diagnostics.wadcfgx" `
        -StorageAccountName $storageAccount.StorageAccountName `
        -StorageAccountKey (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName)[0].Value `
        -WorkspaceId $workspace.CustomerId
}

Write-Output "Azure Diagnostics extension enabled for VM: $VMName"
Write-Output "Diagnostics data sent to Log Analytics workspace: $WorkspaceName"
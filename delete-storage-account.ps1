param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName
)

# Remove the storage account
Remove-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Force

Write-Output "Storage account deleted: $StorageAccountName"
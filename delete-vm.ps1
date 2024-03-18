param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$VMName
)

# Get the VM
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName

if ($vm) {
    # Get the associated resources
    $disk = Get-AzDisk -ResourceGroupName $ResourceGroupName | Where-Object {$_.Id -eq $vm.StorageProfile.OsDisk.ManagedDisk.Id}
    $nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName | Where-Object {$_.Id -eq $vm.NetworkProfile.NetworkInterfaces.Id}
    $nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName | Where-Object {$_.Id -eq $nic.NetworkSecurityGroup.Id}
    $publicIp = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName | Where-Object {$_.Id -eq $nic.IpConfigurations.PublicIpAddress.Id}

    # Delete the VM
    Write-Output "Deleting VM: $VMName"
    Remove-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force

    # Delete the associated resources
    if ($disk) {
        Write-Output "Deleting Disk: $($disk.Name)"
        Remove-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $disk.Name -Force
    }

    if ($nic) {
        Write-Output "Deleting Network Interface: $($nic.Name)"
        Remove-AzNetworkInterface -Name $nic.Name -ResourceGroupName $ResourceGroupName -Force
    }

    if ($nsg) {
        Write-Output "Deleting Network Security Group: $($nsg.Name)"
        Remove-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $ResourceGroupName -Force
    }

    if ($publicIp) {
        Write-Output "Deleting Public IP Address: $($publicIp.Name)"
        Remove-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $publicIp.Name -Force
    }

    Write-Output "VM and associated resources deleted successfully."
}
else {
    Write-Output "VM not found: $VMName"
}
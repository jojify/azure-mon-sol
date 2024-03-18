param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$true)]
    [string]$VNetName,
    
    [Parameter(Mandatory=$true)]
    [string]$SubnetName,
    
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    
    [Parameter(Mandatory=$true)]
    [string]$VMSize,
    
    [Parameter(Mandatory=$true)]
    [string]$AdminUsername,
    
    [Parameter(Mandatory=$true)]
    [string]$AdminPassword
)

# Get the virtual network and subnet
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet

# Create a public IP address for the VM
$publicIpName = "$VMName-PublicIP"
$publicIp = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic

# Create a network interface for the VM
$nicName = "$VMName-NIC"
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id

# Create the Linux VM configuration
$vmConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $VMName -Credential (Get-Credential -UserName $AdminUsername -Password $AdminPassword) -DisablePasswordAuthentication
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName 'Canonical' -Offer 'UbuntuServer' -Skus '18.04-LTS' -Version 'latest'

# Create the Linux VM
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmConfig

Write-Host "Linux VM '$VMName' has been created successfully."
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$VMName,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [string]$AdminUsername,

    [Parameter(Mandatory=$true)]
    [string]$AdminPassword,

    [Parameter(Mandatory=$true)]
    [string]$VNetName,
    
    [Parameter(Mandatory=$true)]
    [string]$SubnetName
)

# Set Azure Context
$context = Get-AzContext
if (-not $context) {
    Connect-AzAccount
}

# Define administrative credentials for the VM
$password = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential ($AdminUsername, $password)

$vmPublicIpName = "$VMName-PublicIP"

# Create a public IP address with Static allocation method and Standard SKU
$publicIp = New-AzPublicIpAddress -Name $vmPublicIpName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Static -Sku "Standard" -DomainNameLabel $VmName.ToLower()

# Get the existing virtual network and subnet
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet

Write-Output "Creating VM with name: $VMName"

# Create Windows VM using the existing virtual network and subnet
New-AzVm -ResourceGroupName $resourceGroupName -Location $Location -Name $VmName -Image "Win2019Datacenter" -Credential $adminCredential -OpenPorts 3389 -PublicIpAddressName $publicIp.Name -VirtualNetworkName $vnet.Name -SubnetName $subnet.Name

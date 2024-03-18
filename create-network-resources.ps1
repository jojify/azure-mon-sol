param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$true)]
    [string]$VNetName,
    
    [Parameter(Mandatory=$true)]
    [string]$SubnetName
)

# Check if the Virtual Network already exists
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if ($vnet) {
    Write-Host "Virtual Network '$VNetName' already exists in Resource Group '$ResourceGroupName'."
} else {
    # Create a new Virtual Network
    $vnet = New-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix "10.0.0.0/16"
    Write-Host "Virtual Network '$VNetName' has been created successfully in Resource Group '$ResourceGroupName'."
}

# Check if the Subnet already exists
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet -ErrorAction SilentlyContinue

if ($subnet) {
    Write-Host "Subnet '$SubnetName' already exists in Virtual Network '$VNetName'."
} else {
    # Create a new Subnet within the Virtual Network
    $subnet = Add-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet -AddressPrefix "10.0.0.0/24"
    $vnet | Set-AzVirtualNetwork
    Write-Host "Subnet '$SubnetName' has been created successfully in Virtual Network '$VNetName'."
}

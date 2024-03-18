param(
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$VMName
)

# Get the Log Analytics workspace
$workspace = Get-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $ResourceGroupName

# Get the workspace ID and key
$workspaceId = $workspace.CustomerId
$workspaceKey = (Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $ResourceGroupName -Name $WorkspaceName).PrimarySharedKey

# Set the time range for the query
$startTime = (Get-Date).AddHours(-1) | Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
$endTime = (Get-Date) | Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"

# Construct the API query
$query = "Perf 
| where TimeGenerated >= datetime('$startTime') and TimeGenerated <= datetime('$endTime')
| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space'
| where InstanceName == 'C:'
| summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"

# Construct the API request
$requestBody = @{
    "query" = $query
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $workspaceKey"
    "Content-Type" = "application/json"
}

$apiUrl = "https://api.loganalytics.io/v1/workspaces/$workspaceId/query"

# Invoke the API request
$response = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $requestBody

# Process the response and extract the metrics
$vmMetrics = $response.tables.rows | Where-Object { $_[1] -eq $VMName }

if ($vmMetrics) {
    $diskFreeSpace = $vmMetrics[0][2]
    Write-Output "Disk C: Free Space: $diskFreeSpace%"
} else {
    Write-Output "No metrics found for VM: $VMName"
}
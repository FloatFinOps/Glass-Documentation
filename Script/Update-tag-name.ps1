<#
.SYNOPSIS
    Renames a specific tag key across Azure resources using Azure CLI, preserving tag values and all other existing tags.

.DESCRIPTION
    This PowerShell script:
    - Accepts a source tag key (SourceTag) and a target tag key (TargetTag)
    - Optionally scopes the operation to a specific subscription or resource group
    - Finds all Azure resources that have the SourceTag
    - Renames the tag key from SourceTag to TargetTag while preserving the original value
    - Retains all other existing tags on the resource
    - Outputs a list of all updated resources

.PARAMETER SourceTag
    The original tag key to be renamed.

.PARAMETER TargetTag
    The new tag key name to replace the SourceTag.

.PARAMETER SubscriptionId
    (Optional) Azure Subscription ID to scope the operation.

.PARAMETER ResourceGroup
    (Optional) Azure Resource Group name to scope the operation.

.EXAMPLE
    .\update-tag.ps1 -SourceTag "OldTag" -TargetTag "NewTag"

.EXAMPLE
    .\update-tag.ps1 -SourceTag "BillingGroup" -TargetTag "billing_group" -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -ResourceGroup "rg-prod"

.NOTES
    Requires Azure CLI and appropriate permissions to read and tag Azure resources.
#>


param (
    [Parameter(Mandatory = $true)]
    [string]$SourceTag,

    [Parameter(Mandatory = $true)]
    [string]$TargetTag,

    [string]$SubscriptionId,
    [string]$ResourceGroup
)

Write-Host "Renaming tag key '$SourceTag' to '$TargetTag'..."

$UpdatedResources = @()

# Build base command with optional filters
$baseCommand = "az resource list --query `[?tags.$SourceTag!=null].[id]` -o tsv"

if ($SubscriptionId) {
    $baseCommand += " --subscription $SubscriptionId"
}

if ($ResourceGroup) {
    $baseCommand += " --resource-group $ResourceGroup"
}

# Get filtered resource list
$resources = Invoke-Expression $baseCommand

if (-not $resources) {
    Write-Host "No resources found with tag '$SourceTag'. Exiting."
    exit 0
}

foreach ($resourceId in $resources) {
    if (-not $resourceId) { continue }

    $allTagsJson = az resource show --ids $resourceId --query "tags" -o json
    $tagDict = @{}
    ($allTagsJson | ConvertFrom-Json).psobject.Properties | ForEach-Object {
        $tagDict[$_.Name] = $_.Value
    }

    if (-not $tagDict.ContainsKey($SourceTag)) {
        Write-Host "Skipping $resourceId (source tag not found)"
        continue
    }

    $value = $tagDict[$SourceTag]
    $tagDict.Remove($SourceTag)
    $tagDict[$TargetTag] = $value

    $tagPairs = @()
    foreach ($key in $tagDict.Keys) {
        if ([string]::IsNullOrWhiteSpace($key)) {
            Write-Host "Skipping empty tag key on $resourceId"
            continue
        }

        $safeKey = $key -replace '"', '\"'
        $safeVal = ($tagDict[$key] -replace '"', '\"')
        $tagPairs += "$safeKey=$safeVal"
    }

    $tagString = $tagPairs -join ' '

    Write-Host "Updating $resourceId - renaming '$SourceTag' to '$TargetTag' (value: '$value')"
    $command = "az resource tag --ids `"$resourceId`" --tags $tagString"
    Invoke-Expression $command | Out-Null

    $UpdatedResources += $resourceId
}

Write-Host ""
Write-Host "Tag renaming completed."

if (-not $UpdatedResources -or $UpdatedResources.Count -eq 0) {
    Write-Host "No resources were updated."
} else {
    Write-Host "The following resources were updated:"
    $UpdatedResources | ForEach-Object { Write-Host " - $_" }
}


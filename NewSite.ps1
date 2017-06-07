## Create New SharePoint site at $rootURL/sites/ with dedicated content database##

Param(
    [Parameter(Mandatory=$true)] [string]$rootURL,
    [Parameter(Mandatory=$true)] [string]$siteName,
    [Parameter(Mandatory=$true)] [string]$urlSuffix,
    [Parameter(Mandatory=$true)] [string]$adminEmail
)

Add-PSSnapin Microsoft.SharePoint.PowerShell
Write-Output "Initializing..."
$webApp = Get-SPWebApplication $rootURL # Get root web application
Write-Output "Creating new content database"
$dbName = 'WSS_Content_'+$urlSuffix.ToUpper()
$contentDB = New-SPContentDatabase -Name $dbName -WebApplication $webApp # Create new content database
Write-Output "New content database created"
Write-Output "Creating new site collection"
$siteUrl = $rootURL+'/sites/'+$urlSuffix
$rootWeb = Get-SPWeb $rootURL
$admin = Get-SPUser -Limit ALL -web $rootWeb  | where Email -match $adminEmail
$newSite = New-SPSite -Name $siteName -Url $siteUrl -ContentDatabase $contentDB -Template STS#0 -OwnerAlias $admin # Create new site collection
Write-Output "Congratulations! Your new site has been created"

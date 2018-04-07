Param(
    [Parameter(Mandatory=$true)]
    [string]$rootURL,
    [string]$greaterThan
)

Add-PSSnapin Microsoft.SharePoint.PowerShell

$spAssignment = Start-SPAssignment

$webApp = Get-SPWebApplication $rootURL

if (! $greaterThan) {
    $greaterThan = 30
}

foreach ($site in $webApp.Sites) {
    $SizeInKB = $Site.Usage.Storage
    $SizeInGB = [math]::Round($SizeInKB/1024/1024/1024,2)
    if ($SizeInGB -gt $greaterThan) {
        Write-Output $site.RootWeb.Title, $SizeInGB
    }
    $site.Dispose()
}


Stop-SPAssignment $spAssignment

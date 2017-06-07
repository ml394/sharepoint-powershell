## Check all list item counts to ensure limit hasn't been reached ##

Param(
    [Parameter(Mandatory=$true)]
    [string]$rootURL,
    [string]$greaterThan
)

Add-PSSnapin Microsoft.SharePoint.PowerShell

$spAssignment = Start-SPAssignment

$webApp = Get-SPWebApplication $rootURL

if (! $greaterThan) {
    $greaterThan = 2000
}

foreach ($site in $webApp.Sites) {
    foreach ($web in $site.AllWebs) {
        Write-Output $web.Lists | where ItemCount -gt $greaterThan | select ParentWebUrl, Title, ItemCount
        $web.dispose()
    }
}

Stop-SPAssignment $spAssignment


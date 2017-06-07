## Add a user to all site owners groups and check if site admin ##

Param(
    [Parameter(Mandatory=$true)] [string]$rootURL,
    [Parameter(Mandatory=$true)] [string]$userName,
)

Add-PSSnapin Microsoft.SharePoint.PowerShell
$rootWeb = Get-SPWeb $rootURL
$user = $rootWeb | Get-SPUser | where email -match $userName

$sites = Get-SPWebApplication $rootURL | Get-SPSite -Limit ALL
foreach ( $site in $sites ) {
    foreach ( $web in $site.AllWebs ) {
        Write-Output $web.Url
        $owners = $web.SiteGroups | where name -match "owners"
        $owners.AddUser($user)
        Write-Output "User added to owners group"
        if ($user.IsSiteAdmin) {
            Write-Output "Already site admin"
        } else {
            Write-Output "Not site admin"
        }
        $web.dispose()
    }
}

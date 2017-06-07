## Enable a site feature on every site in web application ##

Param(
    [Parameter(Mandatory=$true)]
    [string]$featureName
)

Add-PSSnapin Microsoft.SharePoint.PowerShell

$feature = Get-SPFeature | where DisplayName -match $featureName

foreach ($site in $(Get-SPSite -Limit ALL)) {
    foreach ($web in $site.AllWebs){
        Write-Output $web.url
        $active = Get-SPFeature -web $web | where DisplayName -match $featureName
        if ($active) {
            Write-Output "Enabled already"
        } else {
            Enable-SPFeature -url $web.url -Identity $feature
            Write-Output "Now enabled"
        }
        $web.Dispose()
    }
}

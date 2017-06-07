## Send email to admin with links to all pending site access requests ###

Param(
    [Parameter(Mandatory=$true)] [string]$rootURL,
    [string]$adminEmail,
)

Add-PSSnapin Microsoft.SharePoint.PowerShell
$sites = Get-SPWebApplication $rootURL | Get-SPSite -Limit ALL
$rootWeb = Get-SPWeb $rootURL
$email = $adminEmail
$subject = "Pending Access Requests - $(Get-Date -Format u)"
$body = ""

foreach ( $site in $sites ) { 
    $webs = $site.AllWebs
    foreach ( $web in $webs ) {
        $accessRequests = $web.Lists["Access Requests"]
        $arURL = $web.Url + "/Access Requests/pendingreq.aspx"
        if ($accessRequests.ItemCount -gt 0) {
            $pendingRequests = $accessRequests.Items | where {$_['Status'] -eq 0}
            if ($pendingRequests.Length -gt 0) {
                Write-Output `n$web
                $count=0
                foreach ($request in $pendingRequests) {
                    $count++
                    Write-Output $request.Name
                }
                $countString = $count.ToString()
                $body+="* $web - $countString pending requests - <a href='$arURL'>Access Requests Page</a>. "
            }
        }
        $web.dispose()
    }
}

if ($body.Length -gt 0) {
    Write-Output "`nSending email to $email"
    #Write-Output $body
    [Microsoft.SharePoint.Utilities.SPUtility]::SendEmail($rootWeb,0,0,$email,$subject,$body)
}

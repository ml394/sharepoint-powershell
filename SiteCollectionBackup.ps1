## Maintain 1 week of full site collection backups in server F: drive ##

## WARNING - THIS WILL CONSUME A LOT OF STORAGE SPACE ##

Param(
    [Parameter(Mandatory=$true)] [string]$rootURL,
)

Add-PSSnapin Microsoft.SharePoint.PowerShell

Write-Host "`n $(Get-Date -Format u)"

## Add folder for today in F:\Backups
$todaypath = "F:\Backups\$((Get-Date).ToString('yyyy-MM-dd'))"
New-Item -ItemType Directory -Path $todaypath

## Delete folder from one week ago if exists
$weekagopath = "F:\Backups\$((Get-Date).AddDays(-7).ToString('yyyy-MM-dd'))"
if (Test-Path $weekagopath) {Remove-Item $weekagopath -recurse}

$SPAssignment = Start-SPAssignment

## Get all site collections in root web application
$sites = Get-SPWebApplication $rootURL | Get-SPSite -Limit ALL

## Loop through site collections
foreach ($site in $sites) {
    ## Get name of root site as string
    $name = $site.RootWeb.ToString() 
    ## Create name of backup file and full path
    if ($name.Length -gt 0) {
        $backupname = $name + '.bak'
        $backuppath = $todaypath + '\' + $backupname 
    } else {
        $backuppath = $todaypath + '\untitled.bak'
    }
    ## Backup site collection to backup path
    Write-Host $site.RootWeb.Url : $backuppath
    Backup-SPSite $site -Path $backuppath
}

Stop-SPAssignment $SPAssignment

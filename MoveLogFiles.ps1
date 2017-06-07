## Archive SharePoint log files ##

cd  C:\inetpub\logs\LogFiles # move into inetpub log files directory
$logdirs = Get-ChildItem . # get sub-folders
foreach ($logdir in $logdirs) {
    $logfiles = Get-ChildItem $logdir; # get log files in each folder
    foreach ($logfile in $logfiles) {
        if ($logfile.LastAccessTime -lt $(Get-Date).AddDays(-7)) { # check if log file has been accessed in past week 
            Move-Item $logfile.FullName F:\Logs # if not, move to F:\Logs
            Write-Output "Moving file " $logfile.Name
        }
    }
}
cd E:\bin # return to E:\bin

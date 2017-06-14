## Email users with overdue SharePoint workflow tasks ##

Param(
    [Parameter(Mandatory=$true)] [string]$rootURL,
    [int]$notifyDays=3,
    [int]$autocompleteDays=7
)

Add-PSSnapin Microsoft.SharePoint.PowerShell
Write-Output "`n$(Get-Date -Format u)"
$today = Get-Date
$spAssignment = Start-SPAssignment

$sites = Get-SPWebApplication $rootURL | Get-SPSite Limit ALL
foreach ( $site in $sites ) { 
    $webs = $site.AllWebs
    foreach ( $web in $webs ) {
        $incompleteTasks = $web.Lists["Workflow Tasks"].Items | Where { $_['Status'] -eq "Not Started" }
        foreach ($incompleteTask in $incompleteTasks) {
            $created = Get-Date $incompleteTask['Created']
            $timeSpan = $today - $created
            $daySpan = $timeSpan.TotalDays
            if ($daySpan -gt $notifyDays) {
                $assignedTo = $incompleteTask['Assigned To']
                $assignedToUserObj = New-Object Microsoft.SharePoint.SPFieldUserValue($web, $assignedTo)
                $assignedToDisplayName = $AssignedToUserObj.User.DisplayName;
                $assignedToEmail = $assignedToUserObj.User.Email;
                $bodyEnd = "Please head to the <a href='$rootURL'>SharePoint Portal</a> to monitor your pending tasks. Please contact IT Support for any assistance. (This email is auto-generated - do not reply directly to this address)"
                if ($daySpan -gt $autocompleteDays) {
                    $incompleteTask['Status'] = 'Completed'
                    $incompleteTask['Task Outcome'] = 'Approved'
                    $incompleteTask['Remarks'] = 'auto'
                    $incompleteTask.Update()
                    Write-Output "Auto-Approved: $AssignedToEmail"
                    $subject = "SharePoint Task auto-approved"
                    $bodyStart = "Hi $AssignedToDisplayName, you have a task on SharePoint more than 7 days old. Due to the delay, they have been auto-approved. "
                } else {
                    $subject = "SharePoint Task Overdue"
                    $bodyStart = "Hi $AssignedToDisplayName, you have a task on SharePoint more than 3 days old. "
                }
                $body = $bodyStart + $bodyEnd
                Write-Output "Sending email to $AssignedToDisplayName"
                [Microsoft.SharePoint.Utilities.SPUtility]::SendEmail($web,0,0,$assignedToEmail,$subject,$body)
            }
        }
    
    }
}

Stop-SPAssignment $spAssignment

## Identify workflow failures and restart workflow instances ##

Param(
    [Parameter(Mandatory=$true)] [string]$rootURL,
)

Add-PSSnapin Microsoft.SharePoint.PowerShell
Write-Output "`n$(Get-Date -Format u)"

$sites = Get-SPWebApplication $rootURL | Get-SPSite -Limit ALL
foreach ($site in $sites) {
    foreach ($web in $site.AllWebs) {
        $wfm = New-Object Microsoft.SharePoint.WorkflowServices.WorkflowServicesManager($web)
        $wfis = $wfm.GetWorkflowInstanceService()
        foreach ($list in $web.Lists) {
            foreach ($item in $list.Items) {
                $instances = $wfis.EnumerateInstancesForListItem($list.ID, $item.ID) # Get workflow instances for list item
                if ($instances[0].Status -eq "Canceled") {
                    Write-Output "Workflow failure found. Restarting..."
                    $wfName = $instances[0].Name
                    $sub = $wfm.GetWorkflowSubscriptionService()
                    $wf = $sub.EnumerateSubscriptionsByList($list.ID) | Where-Object {$_.Name -eq $wfName}
                    $object = New-Object 'System.Collections.Generic.Dictionary[string,object]'
                    $object.Add("WorkflowStart", "StartWorkflow");
                    $wfis.StartWorkflowOnListItem($wf, $item.ID, $object)
                    start-sleep 30
                    $newInstances = $wfis.EnumerateInstancesForListItem($list.ID, $item.ID)
                    if ($newInstances[0].Status -ne 'Canceled') {
                        Write-Output "Workflow succesfully restarted"
                    } else {
                        Write-Output "Workflow failed again"
                    }
                }
            }
        }
        $web.dispose()
    }
}

# turn into functions Check, Restart

## HELPDESK SITE GROUP CREATOR ##

## Functions to create or remove HelpDesk site group on all SP Webs in Farm, then add or remove selected users from group ##

# Must run with paramaters 
# .\HelpDesk.ps1 -function CreateGroups -rootSiteURL $url -adminEmail $email --> Create HelpDesk group on all webs, and give full control to this group
# .\HelpDesk.ps1 -function RemoveGroups -rootSiteURL $url -adminEmail $email --> Remove HelpDesk group from all webs
# .\HelpDesk.ps1 -function AddTech -rootSiteURL $url -adminEmail $email -tech $username --> Add tech to all HelpDesk groups
# .\HelpDesk.ps1 -function RemoveTech -rootSiteURL $url -adminEmail $email -tech $username --> Remove tech from all HelpDesk groups 

Param(
    [Parameter(Position=0,Mandatory=$true)] [string]$function,
    [Parameter(Position=1,Mandatory=$true)] [string]$rootSiteURL,
    [Parameter(Position=2,Mandatory=$true)] [string]$adminEmail,
    [string]$tech = $( if($function -eq "AddUser" -or $function -eq "RemoveUser"){$(throw "Tech login name required for add/remove user function")} )
)

Add-PSSnapin Microsoft.SharePoint.PowerShell
$rootSite = Get-SPSite $rootSiteURL
$rootWeb = $rootSite.rootWeb
$admin = $rootWeb.SiteUsers | where email -match $adminEmail

function CheckForHelpDeskGroupinAllWebs() {
    # Check if HelpDesk group exists in all sites
    foreach ($site in $(Get-SPSite -Limit ALL)) {
        foreach ($web in $site.AllWebs) {
            if ($web.SiteGroups["HelpDesk"]) {
                continue
            } else {
                return $false
            }
            $web.dispose()
        }
    }
    return $true
}

function RemoveGroups() {
    # Remove all helpdesk groups - for admin/cleaning"
    foreach ($site in $(Get-SPSite -Limit ALL)) {
        foreach ($web in $site.AllWebs) {
            Write-Output $web.url
            if ($web.SiteGroups['HelpDesk']) {
                $helpdesk = $web.SiteGroups['HelpDesk']
                Write-Output "HelpDesk group exists. Removing"
                $web.SiteGroups.Remove($helpdesk)
                Write-Output "Done!"
            } else {
                Write-Output "No helpdesk group to remove"
            }
            $web.dispose()
        }
    }
}

function CreateGroups() {
    # Create HelpDesk group in each SP web and assign full control to the group
    foreach ($site in $(Get-SPSite -Limit ALL)) {
        foreach ($web in $site.AllWebs) {
            Write-Output $web.url
            if ($web.SiteGroups['HelpDesk']) {
                Write-Output "HelpDesk group already exists"
            } else {
                Write-Output "Creating HelpDesk group"
                $web.SiteGroups.Add("HelpDesk", $admin, $admin, "IT HelpDesk site group")
                Write-Output "Assigning full control to helpdesk group"
                sleep -Seconds 3
                $helpdesk = $web.SiteGroups['Helpdesk']
                $assignment = New-Object Microsoft.SharePoint.SPRoleAssignment($helpdesk)
                $role = $web.RoleDefinitions["Full Control"]
                $assignment.RoleDefinitionBindings.Add($role)
                $web.RoleAssignments.Add($assignment)
                Write-Output "Done!"
            }
            $web.dispose()
        }
    }
}

function AddHelpDeskTech($userName) {
    # Add tech user to all HelpDesk groups
    $userIDs = $rootWeb.SiteUsers | where LoginName -match $userName
    Write-Output $userIDs
    $check = CheckForHelpDeskGroupinAllWebs
    if ($check) {
        foreach ($user in $userIDs) {
            foreach ($site in $(Get-SPSite -Limit ALL)) {
                foreach ($web in $site.AllWebs) {
                    Write-Output $web.url
                    $helpdesk = $web.SiteGroups["HelpDesk"]
                    Write-Output "Adding user to helpdesk group"
                    $helpdesk.AddUser($user)
                    Write-Output "Done!"
                    $web.dispose()
                }
            }
        }
    } else {
        Write-Output "HelpDesk group does not exist in all webs. Please run '.\HelpDesk.ps1 -function CreateGroups' before continuing"
    }
}

If ($function -eq "CreateGroups") {
    CreateGroups
} ElseIf ($function -eq "AddUser") {
    AddHelpDeskTech($tech)
} ElseIf ($function -eq "RemoveGroups") {
    RemoveGroups
} Else {
    Write-Output "Incorrect function supplied as parameter"
}

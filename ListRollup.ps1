## PowerShell script to rollup list data from child sites
## Required input paramaters - parentURL, contentTypeName

# Required to have lists on parent and subsites with association to contentTypeName

Param(
  [Parameter(Mandatory=$TRUE)] [string]$parentURL,
  [Parameter(Mandatory=$TRUE)] [string]$contentTypeName,
)

Add-PSSnapin Microsoft.SharePoint.PowerShell
$SPAssignment = Start-SPAssignment
$parentSite = Get-SPSite $parentURL
$parentWeb = $parentSite.rootWeb
$childWebs = $parentSite.AllWebs | where Name -NE $parentWeb.Name
$fieldNames = @()
$siteContentType = $parentWeb.ContentTypes | where Name -match $contentTypeName
foreach ($field in $siteContentType.Fields) {
  $fieldNames+=$field.Name
}

foreach ($list in $parentWeb.Lists) {
  foreach ($listContentType in $list.ContentTypes) {
    if ($contentType.Name -eq $contentTypeName) {
      $parentList = $list
      foreach ($childWeb in $childWebs) {
        foreach ($list in $childWeb.Lists) {
          foreach ($listContentType in $list.ContentTypes) {
            if ($listContentType.Name -eq $contentTypeName) {
              $childList = $list
              if ($childList.ItemCount -gt 0) {
                foreach ($childItem in $childList.Items) {
                  $childItemObject = New-Object System.Object
                  foreach ($fieldName in $fieldNames) {
                    $childItemObject | Add-Member -type NoteProperty -name $fieldName -value $childItem[$fieldName]
                  }
                  $exists = $FALSE
                  foreach ($parentItem in $parentList.Items) {
                    if ($parentItem['Title'] -eq $childItem['Title']) {
                      $exists = $TRUE
                    }
                  }
                  if ($exists) {
                    $parentItem = $parentList.Items | where {$_['Title'] -eq $childItem['Title']}
                  } else {
                    $parentItem = $parentList.AddItem()
                  }
                  foreach ($fieldName in $fieldNames) {
                    $parentItem[$fieldName] = $childItem[$fieldName]
                    $parentItem.Update()
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

Stop-SPAssignment $SPAssignment

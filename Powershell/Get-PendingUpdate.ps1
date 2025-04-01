Function Get-PendingUpdate {
<#
  .SYNOPSIS
    Retrieves the updates waiting to be installed from WSUS
  .DESCRIPTION
    Retrieves the updates waiting to be installed from WSUS
  .EXAMPLE
    Get-PendingUpdates
  .NOTES
    Forked from https://github.com/proxb/PowerShell_Scripts
#>

#Requires -version 3.0
  Try {
  #Create Session COM object
      Write-Verbose "Creating COM object for WSUS Session"
      $updatesession = (New-Object -ComObject Microsoft.Update.Session)
      }
  Catch {
      Write-Warning "$($Error[0])"
      Break
      }

  #Configure Session COM Object 
  Write-Verbose "Creating COM object for WSUS update Search" 
  $updatesearcher = $updatesession.CreateUpdateSearcher() 

  #Configure Searcher object to look for Updates awaiting installation 
  Write-Verbose "Searching for WSUS updates on client" 
  $searchresult = $updatesearcher.Search("IsHidden=0 and IsInstalled=0")     

  #Verify if Updates need installed 
  Write-Verbose "Verifing that updates are available to install" 
  If ($searchresult.Updates.Count -gt 0) { 
      #Updates are waiting to be installed 
      Write-Verbose "Found $($searchresult.Updates.Count) update\s!" 
      #Cache the count to make the For loop run faster 
      $count = $searchresult.Updates.Count 

      #Begin iterating through Updates available for installation 
      Write-Verbose "Iterating through list of updates" 
      For ($i=0; $i -lt $Count; $i++) { 
          #Create object holding update 
          $Update = $searchresult.Updates.Item($i)
          [pscustomobject]@{
              KB = $($Update.KBArticleIDs)
              Title = $Update.Title
              Categories = ($Update.Categories | Select-Object -ExpandProperty Name)
              SecurityBulletin = $($Update.SecurityBulletinIDs)
              MsrcSeverity = $Update.MsrcSeverity
              IsDownloaded = $Update.IsDownloaded
              Url = $($Update.MoreInfoUrls)
              BundledUpdates = @($Update.BundledUpdates)|ForEach{
                  [pscustomobject]@{
                      Title = $_.Title
                      DownloadUrl = @($_.DownloadContents).DownloadUrl
                  }
              }
          } 
      }
  } 
  Else { 
      #Nothing to install at this time 
      Write-Verbose "No updates to install." 
  }
}

# Current date
$date = Get-Date
# First day of the month
$fdom = ([datetime]::new($date.Year, $date.Month, 1))
# Day of the week of the first day of the month
$fdomDw = $fdom.DayOfWeek
# Calculate the date of the first Tuesday
if ($fdomDw -le [System.DayOfWeek]::Tuesday) {
    $firstTuesday = $fdom.AddDays(([System.DayOfWeek]::Tuesday - $fdomDw + 7) % 7)
} else {
    $firstTuesday = $fdom.AddDays((7 - $fdomDw + [System.DayOfWeek]::Tuesday) % 7)
}
# Calculate the third Tuesday
$thirdTuesday = $firstTuesday.AddDays(14) # 14 days after the first Tuesday
# Format the date to display the month name in French (Canadian)
$culture = [System.Globalization.CultureInfo]::GetCultureInfo("fr-CA")
$formattedDate = $thirdTuesday.ToString("dd MMMM yyyy", $culture)

$Header = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black; vertical-align:top;}
</style>
</head>
"@

$TableWUpdates = Get-PendingUpdate | ConvertTo-Html -Property KB,Title,Url -Fragment

$Body = @"
<body>
<table>
<tr>
  <td>Details</td>
  <td>Étendue des travaux</td>
</tr>
<tr>
  <td>
  <table>
    <tr><td>Environnement</td><td>Production</td></tr>
    <tr><td>Nom des serveurs</td><td>SRV01
    <br>SRV44</td></tr>
    <tr><td>Début de la fenêtre de maintenance</td><td>$formattedDate 02:00 Heure Avancée de l’Est
    <tr><td>Fin de la fenêtre de maintenance</td><td>$formattedDate 04:59 Heure Avancée de l’Est
    <tr><td>Systèmes affectés</td><td>AI (Dev / Test)
    <br>Shipping (Dev / Test)
    <br>Manager (Test)
    <br>Gateway (Dev / Test)
    <br>Rl (Dev / Test)</td></tr>
    <tr><td>Imt</td><td>Aucune coupure de service pour tous les systèmes, à l’exception du système
    « Rl » qui sera inaccessible à deux (2) reprises, pour une durée d’à peu près deux (2) minutes chacune.</td></tr>
  </table>
  </td>
  <td>
    $TableWUpdates
  </td>
</tr>
</table>
</body>
</html>
"@

$html = $Header + $Body | Out-File -FilePath PendingUpdates.html

#Get-PendingUpdate | ConvertTo-Html -Property KB,Title,Url -Head $Header | Out-File -FilePath PendingUpdates.html
#Get-PendingUpdate
#(New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search(“IsHidden=0 and IsInstalled=0”).Updates | Select-Object Title

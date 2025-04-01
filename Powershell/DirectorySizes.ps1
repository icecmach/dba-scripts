Get-ChildItem -Path C:\Temp -Directory -Recurse -Depth 1 | ForEach-Object { $_.FullName + ": " + ((Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB) + " MB" }

Get-ChildItem -Path C:\Temp -Directory -Recurse -Depth 1 | ForEach-Object { $_.FullName + "," + ((Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB)}

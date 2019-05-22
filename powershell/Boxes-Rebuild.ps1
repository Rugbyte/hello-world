$childDirectories = Get-ChildItem | Where-Object {$_.PSisContainer}

foreach ($directory in $childDirectories){
    Write-Host "Starting rebuild of $($directory)"
    Push-Location $directory
    vagrant.exe destroy -f
    vagrant.exe up
    Pop-Location
    Write-Host "Rebuild of $($directory) complete"
}
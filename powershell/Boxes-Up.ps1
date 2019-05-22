$childDirectories = Get-ChildItem | Where-Object {$_.PSisContainer}

foreach ($directory in $childDirectories){
    Write-Host "Starting build of $($directory)"
    Push-Location $directory
    vagrant.exe up
    Pop-Location
    Write-Host "Build of $($directory) complete"
}
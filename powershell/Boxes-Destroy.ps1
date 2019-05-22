$childDirectories = Get-ChildItem | Where-Object {$_.PSisContainer}

foreach ($directory in $childDirectories){
    Write-Host "Starting destruction of $($directory)"
    Push-Location $directory
    vagrant.exe destroy -f
    Pop-Location
    Write-Host "Destruction of $($directory) Complete"
}
Write-Host -ForegroundColor Green -BackgroundColor Black "Building Project A"
Set-Location ${PSScriptRoot}\'Project A'
docker build . -t project-a
Write-Host "...done!"

Write-Host -ForegroundColor Green -BackgroundColor Black "Building Project B"
Set-Location ${PSScriptRoot}\'Project B'
docker build . -t project-b
Write-Host "...done!"

Write-Host -ForegroundColor Green -BackgroundColor Black "Bringing up Stack..."
Set-Location ${PSScriptRoot}
docker-compose up

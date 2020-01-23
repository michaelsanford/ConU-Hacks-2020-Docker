Set-Location '${PSScriptRoot}\Project A'
docker build -t . project-a

Set-Location '${PSScriptRoot}\Project B'
docker build -t . project-b

Set-Location ${PSScriptRoot}
docker-compose up

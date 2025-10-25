param(
  [string]$Host = 'localhost',
  [string]$User = 'postgres',
  [string]$Db = 'postgres'
)

$script = Join-Path $PSScriptRoot '001_procedure_tests.sql'
Write-Host "Running tests script: $script"
psql -h $Host -U $User -d $Db -f $script

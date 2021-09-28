[CmdletBinding()]
param ()

$Task = ($MyInvocation.MyCommand.Name).split('.')[0]
New-GitHubLogGroup -Title "$Task - Gather Azure environment info"

Write-Output "$Task - Looging for subscription prefix (Sxxx):"
$EnvironmentID = ($env:SubscriptionName -split '-')[0]
Set-GitHubEnv -Name "EnvironmentID" -Value $EnvironmentID -Verbose

Write-Output "$Task - Looking for monitoring Resource Group (RG):"
$RGs = az group list -o json | ConvertFrom-JSON
$RG = $RGs | Where-Object Name -match "$env:EnvironmentID-log"
if($RG){
    Set-GitHubEnv -Name "Monitoring_RGName" -Value $RG[0].name -Verbose
    Set-GitHubEnv -Name "Monitoring_RGID" -Value $RG[0].id -Verbose
}else{
    Write-Output "$Task - No Resource Group (RG) found named $env:EnvironmentID-log in subscription $env:SubscriptionName"
}

Write-Output "$Task - Looking for monitoring Log Analytics workspace (LAW):"
$LAWs = az monitor log-analytics workspace list -o json | ConvertFrom-JSON
$LAW = $LAWs | Where-Object Name -match "$env:EnvironmentID-log"
if($LAW){
    Set-GitHubEnv -Name "Monitoring_LAWName" -Value $LAW[0].name -Verbose
    Set-GitHubEnv -Name "Monitoring_LAWID" -Value $LAW[0].id -Verbose
}else{
    Write-Output "$Task - No Log Analytics Workspace (LAW) found in subscription $env:SubscriptionName"
}

Write-Output "$Task - Looking for monitoring Automation Account(AA):"
az config set extension.use_dynamic_install=yes_without_prompt
$AAs = az automation account list -o json | ConvertFrom-JSON
$AA = $AAs | Where-Object Name -match "$env:EnvironmentID-log-AA"
if($AA){
    Set-GitHubEnv -Name "Monitoring_AAName" -Value $AA[0].name -Verbose
    Set-GitHubEnv -Name "Monitoring_AAID" -Value $AA[0].id -Verbose
}else{
    Write-Output "$Task - No Automation Account (AA) found in subscription $env:SubscriptionName"
}

Write-Output '::endgroup::'

param (
$Server = $null,
$ServerList = ".\Deploy-Server-List.txt",
$PathAgent = "C:\zabbix_agent2-6.2.4",
$PathAgentConf = "$PathAgent\conf\zabbix_agent2.d\plugins.d\User-Sessions.conf",
$PathAgentScriptFolder = "$PathAgent\conf\zabbix_agent2.d\scripts\User-Sessions",
$PathAgentScript = "$PathAgentScriptFolder\Get-Query-Param.ps1",
$UrlConf = "https://raw.githubusercontent.com/Lifailon/Windows-User-Sessions/rsa/Scripts/User-Sessions.conf",
$UrlSctipt = "https://raw.githubusercontent.com/Lifailon/Windows-User-Sessions/rsa/Scripts/User-Sessions/Get-Query-Param.ps1"
)

if ($Server -ne $null) {
$srvl = $Server
} else {
$srvl = cat $ServerList
}

### Test ping
$srv_ping_available = @()
foreach ($srv in $srvl) {
$ping_out = (ping -n 1 $srv)[2]
if ($ping_out -match "TTL") {
Write-Host "$srv - ping available" -ForegroundColor Green
$srv_ping_available += $srv
} else {
Write-Host "$srv - ping not available" -ForegroundColor Red
}
}

### Test WinRM
Write-Host
$srv_winrm_available = @()
foreach ($srv in $srv_ping_available) {
$winrm_out = Test-WsMan $srv -ErrorAction Ignore
if ($winrm_out -ne $null) {
Write-Host "$srv - WinRM available" -ForegroundColor Green
$srv_winrm_available += $srv
} else {
Write-Host "$srv - WinRM not available" -ForegroundColor Red
}
}

### Test Zabbix Agent path
Write-Host
$srv_agent_available = @()
foreach ($srv in $srv_winrm_available) {
$session = New-PSSession $srv
icm -Session $session {$PathAgent = $using:PathAgent}
$TestPath = icm -Session $session {Test-Path $PathAgent}
if ($TestPath -eq $True) {
Write-Host $srv - Zabbix Agent path available -ForegroundColor Green
$srv_agent_available += $srv
} else {
Write-Host $srv - Zabbix Agent path not available -ForegroundColor Red
}
Remove-PSSession $session
}

Write-Host
foreach ($srv in $srv_agent_available) {
$session = New-PSSession $srv
icm -Session $session {
$PathAgent = $using:PathAgent;
$PathAgentConf = $using:PathAgentConf;
$PathAgentScriptFolder = $using:PathAgentScriptFolder;
$PathAgentScript = $using:PathAgentScript;
$UrlConf = $using:UrlConf;
$UrlSctipt = $using:UrlSctipt
}

### Zabbix Agent Stop
icm -Session $session {Get-Service | where name -match "Zabbix Agent 2" | Stop-Service}
$ServiceStatus = icm -Session $session {
(Get-Service | where name -match "Zabbix Agent 2").Status
}
Write-Host $srv - Zabbix Agent : $ServiceStatus -ForegroundColor Cyan

### Deploy
$TestPathAgentScript = icm -Session $session {Test-Path $PathAgentScriptFolder}
if($TestPathAgentScript -eq $false) {
$pathCreat = icm -Session $session {New-Item -Path $PathAgentScriptFolder -ItemType "Directory" -Force}
Write-Host $srv - Created Path $pathCreat.Name -ForegroundColor Cyan
}

icm -Session $session {
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
iwr $UrlConf -OutFile $PathAgentConf;
iwr $UrlSctipt -OutFile $PathAgentScript;
Set-ExecutionPolicy Unrestricted -Force
}

$StatusConfFile = icm -Session $session {ls $PathAgentConf -ErrorAction Ignore}
if ($StatusConfFile -ne $Null) {
Write-Host $srv - Created File $StatusConfFile.Name: True -ForegroundColor Cyan
} else {
Write-Host $srv - Created File $StatusConfFile.Name: False -ForegroundColor Cyan
}
$StatusScriptFile = icm -Session $session {ls $PathAgentScript -ErrorAction Ignore}
if ($StatusScriptFile -ne $Null) {
Write-Host $srv - Created File $StatusScriptFile.Name: True -ForegroundColor Cyan
} else {
Write-Host $srv - Created File $StatusScriptFile.Name: False -ForegroundColor Cyan
}

### Zabbix Agent Start
icm -Session $session {Get-Service | where name -match "Zabbix Agent 2" | Start-Service}
$ServiceStatus = icm -Session $session {
(Get-Service | where name -match "Zabbix Agent 2").Status
}
Write-Host $srv - Zabbix Agent : $ServiceStatus -ForegroundColor Cyan

Write-Host
Remove-PSSession $session
}
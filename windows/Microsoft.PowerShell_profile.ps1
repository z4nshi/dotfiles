# Import Modules
# Import-Module activedirectory

function ls {
  $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)

  $fore = $Host.UI.RawUI.ForegroundColor
  $compressed = New-Object System.Text.RegularExpressions.Regex('\.(zip|tar|gz|rar)$', $regex_opts)
  $executable = New-Object System.Text.RegularExpressions.Regex('\.(exe|bat|cmd|ps1|psm1|vbs|rb|reg|dll|o|lib)$', $regex_opts)
  $executable = New-Object System.Text.RegularExpressions.Regex('\.(exe|bat|cmd|ps1|psm1|vbs|rb|reg|dll|o|lib)$', $regex_opts)
  $source = New-Object System.Text.RegularExpressions.Regex('\.(py|pl|cs|rb|h|cpp)$', $regex_opts)
  $text = New-Object System.Text.RegularExpressions.Regex('\.(txt|cfg|conf|ini|csv|log|xml)$', $regex_opts)

  Invoke-Expression ("Get-ChildItem $args") |
    %{
      if ($_.GetType().Name -eq 'DirectoryInfo') {
        $Host.UI.RawUI.ForegroundColor = 'DarkCyan'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($compressed.IsMatch($_.Name)) {
        $Host.UI.RawUI.ForegroundColor = 'Yellow'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($executable.IsMatch($_.Name)) {
        $Host.UI.RawUI.ForegroundColor = 'Red'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($text.IsMatch($_.Name)) {
        $Host.UI.RawUI.ForegroundColor = 'Green'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($source.IsMatch($_.Name)) {
        $Host.UI.RawUI.ForegroundColor = 'Cyan'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } else {
        $_
      }
    }
}

function ll
{
    param ($dir = ".", $all = $false) 

    $origFg = $host.ui.rawui.foregroundColor 
    if ( $all ) { $toList = ls -force $dir }
    else { $toList = ls $dir }

    foreach ($Item in $toList)  
    { 
        Switch ($Item.Extension)  
        { 
            ".Exe" {$host.ui.rawui.foregroundColor = "Yellow"} 
            ".cmd" {$host.ui.rawui.foregroundColor = "Red"} 
            ".doc" {$host.ui.rawui.foregroundColor = "Blue"} 
            ".docx" {$host.ui.rawui.foregroundColor = "Blue"} 
            ".xls" {$host.ui.rawui.foregroundColor = "Green"} 
            ".xlsx" {$host.ui.rawui.foregroundColor = "Green"} 
            ".vbs" {$host.ui.rawui.foregroundColor = "Red"} 
            Default {$host.ui.rawui.foregroundColor = $origFg} 
        } 
        if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "White"}
        $item 
    }  
    $host.ui.rawui.foregroundColor = $origFg 
}

function lla
{
    param ( $dir=".")
    ll $dir $true
}

function la { ls -force }

function Get-Uptime {
    Param([Parameter(Mandatory = $True,
        ValueFromPipeLine = $False,
        Position = 0)]
        [Alias('')]
        [String]$ComputerName = "localhost"
    )#END: Param
    $LastBoot = (Get-WmiObject -Class Win32_OperatingSystem -computername $ComputerName).LastBootUpTime
        $sysuptime = (Get-Date) – [System.Management.ManagementDateTimeconverter]::ToDateTime($LastBoot)
        Write-Host -foregroundcolor cyan "($ComputerName) System uptime is:" $sysuptime.days"days"$sysuptime.hours"hours"$sysuptime.minutes 
"minutes"$sysuptime.seconds"seconds"
    }#End Function Get-Uptime
	
function help {
$help="#Activer le profile :
new-item -path $profile -itemtype file -force
notepad $profile

function pwgen {
param(
    $length = 8,
    $characters = 'abcdefghkmnprstuvwxyzABCDEFGHKLMNPRSTUVWXYZ',
    $nonchar = '23456789!"§$%&/()=?*+#_'
)
$length = $length - 2
$random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
$random2 = 1..2 | ForEach-Object { Get-Random -Maximum $nonchar.length }

$private:ofs= ""
$password = [String]$characters[$random] + [String]$nonchar[$random2]
return $password
}

# Report USB Device installed :
gwmi Win32_USBControllerDevice -computername SERVER1 |fl Antecedent,Dependent

Lister les processus commencant par fire* : 
get-process fire*

Et le tuer : 
stop-process -id 2792"

Write-Host($help)

return " "
}

function fdisk {
(Get-PSProvider FileSystem).Drives
}
	
# save last 100 history items on exit
$historyPath = Join-Path (split-path $profile) history.clixml

# hook powershell's exiting event & hide the registration with -supportevent.
Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
    Get-History -Count 100 | Export-Clixml (Join-Path (split-path $profile) history.clixml) }

# load previous history, if it exists
if ((Test-Path $historyPath)) {
    Import-Clixml $historyPath | ? {$count++;$true} | Add-History
    Write-Host -Fore Green "`nLoaded $count history item(s).`n"
}

# Edition fichier hosts
function hosts { 
	notepad c:\windows\system32\drivers\etc\hosts
}


# Verification du WMI
function checkWMI ([string]$srv){
   $checkwmi = $null
   $timeout = new-timespan -seconds 15
   $Scope = new-object System.Management.ManagementScope "\\$srv\root\cimv2", $options
   $Scope.Connect()
   $query = new-object System.Management.ObjectQuery "SELECT * FROM Win32_OperatingSystem"
   $searcher = new-object System.Management.ManagementObjectSearcher $scope,$query
   $SearchOption = $searcher.get_options()
   $SearchOption.set_timeout($timeout)
   $searcher.set_options($SearchOption)
   $checkwmi = $searcher.get()
   $lastBoot = $checkwmi | %{$_.lastbootuptime}

   if($lastBoot){
      return $true
   }
   else{
      return $false
   }
}

# Taille du répertoire
function dirsize([string]$rootdir) {
$rootdir

trap { # this installs an error handler for the function
    Write-Host "Error in Function dirsize:" $_.Exception.GetType().FullName + $_.Exception.Message
	continue; # exiting a trap with "continue" says to continue on the next line of the script
	}
if (!$rootdir) {
	Write-Host "Error in dirsize function. You must specify a root directory to search in `n" `
	"Usage example: dirsize C:\Windows`n "`
	"Answer: Top10 Foldes`n"`
	"Answer: Top10 Files in current Folder"-ForegroundColor red
	break
	}



	dir $args | where-Object { $_.PSisContainer } | `
	foreach-Object { Write-Progress 'Examining Folder' ($_.FullName); $_ } | `
	foreach-Object { 
		$result = '' | Select-Object Path, FileCount, SizeMB; $result.path = $_.FullName; $temp = Dir $_.FullName -recurse -ea SilentlyContinue |`
		Measure-Object length -sum -ea SilentlyContinue ; $result.filecount = $temp.Count; [double] $result.SizeMB = ('{0:0.0}' -f ($temp.Sum/1MB)); $result 
		} | `
	Sort-Object SizeMB -descending | Select-Object –first 10 | Format-Table -AutoSize
	
	###################################################
	
	
	dir $args |where-Object {!$_.PSisContainer } | `
	foreach-Object {$result = '' |`
	Select-Object Path, SizeMB, LastFileAccess;`
	$result.path = $_.FullName;`
	$result.SizeMB = ('{0:0.0}' -f ($_.Length/1MB));`
	$result.LastFileAccess = $_.LastWriteTime; $result } |`
	Sort-Object SizeMB -descending | Select-Object –first 10 | Format-Table -AutoSize
}
 
# Fonction VMWare
function VMInfo {
    param(
    [parameter(Mandatory = $true)]
        [string[]]$VMName)
    Get-VM $VMName
}

Function Get-VMWAREToolsStatus
{
   Param ( [String]$ComputerName, [Switch]$Quiet )

   $VM = Get-View -ViewType VirtualMachine -Property Guest,Name -filter @{"Name"=$ComputerName}
   if ( $VM.Guest.GuestState -ne 'running' )
   {
      Write-Warning "Impossible de continuer car la VM n'est pas démarrée !"
   }
   else
   {
      if ($Quiet -eq $true)
      {
         if ($VM.Guest.ToolsStatus -eq 'toolsOk')
         {
            Write-Output $true
         }
         else
         {
            Write-Output $false
         }
      }
      else
      {
         Write-Output $VM | Select-object -property @{Name='ToolsStatus'; Expression={$_.Guest.ToolsStatus}},
       @{Name='ToolsVersion'; Expression={$_.Guest.ToolsVersion}}
      }
   }
}

function Connect-ESX
{
	Connect-VIServer -Server 10.192.16.28 -User username -Password "password" -Protocol https
}

function Add-NFS-DataStore01([string]$NFSName)
{
	New-DataStore -VMHost $NFSName -Name "NFS-DataStore01" -Nfs -NfsHost mon-ip -Path /mnt/zPool/NFS-DataStore01
}

function Activate_Syslog
{
	Set-VMHostSysLogServer -SysLogServer 'mon-ip' -SysLogServerPort '514'
	Get-VMHostFirewallException -Name "syslog"  | set-VMHostFirewallException -Enabled:$true

	$esxcli = Get-EsxCli -VMHost $myHost
	$esxcli.system.syslog.reload()
}

function Activate_Snmp
{
	$hostSNMP = Get-VMHostSNMP
	$hostSNMP = Set-VMHostSNMP $hostSNMP -Enabled:$true -ReadOnlyCommunity 'esx_snmp'
}

# Ajout de quelques alias utiles
New-Item alias:np -value C:\windows\system32\notepad.exe
New-Item alias:ff -Value "c:\program files (x86)\Mozilla Firefox\firefox.exe"

Get-Uptime localhost

# Fonction de prompt
function prompt 
{
	$path = ""
	$pathbits = ([string]$pwd).split("\", [System.StringSplitOptions]::RemoveEmptyEntries)

	if($pathbits.length -eq 1) 
	{
		$path = $pathbits[0] + "\"
	} 
	else 
	{
		$path = $pathbits[$pathbits.length - 1]
	}

	$userLocation = $env:username + '@' + [System.Environment]::MachineName + ' ' + $path + ' ~> '
	$host.UI.RawUi.WindowTitle = $userLocation

	Write-Host($userLocation) -nonewline -foregroundcolor White
	
	return " "
}





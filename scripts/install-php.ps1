# Specify PHP install location (version specific subdirectory will be created)
$phpInstall = "c:\php"
# Specify PHP log location
$phpLog = "c:\phplog"
# Specify PHP temp location
$phpTemp = "c:\phptemp"
# Path for downloaded files
$downloads = "c:\downloads"
# Specify desired Webroot location
$webRoot = "c:\Sites"
# Specify desired weblogs location
$webLog = "c:\SitesLogs"

# Specify PHP files and paths
$phpVersion = "7.1.13"
# Name of file to download
$phpInstallZip = "php-$phpVersion-nts-Win32-VC14-x64.zip"
# Download path for php
$phpDownloadURL = "http://windows.php.net/downloads/releases/$phpInstallZip";
$phpDownloadFile = "$downloads\$phpInstallZip"

#Download PHP manager from http://phpmanager.codeplex.com/
#$phpmgrInstallMedia = "phpmanagerforiis-1.2.0-x64.msi /q"

# download WinCache from http://www.iis.net/downloads/microsoft/wincache-extension
#$wincacheVersion = "2.0.0.8";
#$wincacheZip = "WINCACHE-$wincacheVersion.tgz";
#$wincacheDownloadURL = "http://pecl.php.net/get/$wincacheZip"
#$wincacheDownloadFile = "$downloads\$wincacheZip";
#
##and place it in the folder php_version
#$wincacheDLL = "$phpVersion\php_wincache.dll"

# Begin all downloads
if ((Test-Path $phpDownloadFile) -ne $True)
{
    $startTime = Get-Date
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($phpDownloadURL, $phpDownloadFile)
    #$webClient.DownloadFile($wincacheDownloadURL, $wincacheDownloadFile)
    Write-Output "Downloaded resources in $( (Get-Date).Subtract($startTime).Seconds ) second(s)"
}

#Install IIS Components for PHP over FastCGI
start-process "c:\windows\system32\pkgmgr.exe" -ArgumentList "/iu:IIS-WebServerRole;IIS-WebServer;IIS-CommonHttpFeatures;IIS-StaticContent;IIS-DefaultDocument;IIS-DirectoryBrowsing;IIS-HttpErrors;IIS-HealthAndDiagnostics;IIS-HttpLogging;IIS-LoggingLibraries;IIS-RequestMonitor;IIS-Security;IIS-RequestFiltering;IIS-HttpCompressionStatic;IIS-WebServerManagementTools;IIS-ManagementConsole;WAS-WindowsActivationService;WAS-ProcessModel;WAS-NetFxEnvironment;WAS-ConfigurationAPI;IIS-CGI" -Wait
#Set ACLs for PHP for IIS to process it appropriately
if ((Test-Path -path $phpInstall) -ne $True)
{
    new-item -type directory -path $phpInstall
    $acl = get-acl $phpInstall
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("IIS AppPool\DefaultAppPool", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.setaccessrule($ar)
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.setaccessrule($ar)
    set-acl $phpInstall $acl
}

# Install zip to destination folder in c:\php\7.1.13\
$shell = new-object -com shell.application
$zip = $shell.NameSpace($phpDownloadFile)
foreach ($item in $zip.items())
{
    $shell.Namespace("$phpInstall\$phpVersion").copyhere($item)
}

# Set ACL for c:\phplog
if ((Test-Path -path $phpLog) -ne $True)
{
    new-item -type directory -path $phpLog
    $acl = get-acl $phpLog
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "Modify", "Allow")
    $acl.setaccessrule($ar)
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("IIS AppPool\DefaultAppPool", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.setaccessrule($ar)
    set-acl $phpLog $acl
}
if ((Test-Path -path $phpTemp) -ne $True)
{
    new-item -type directory -path $phpTemp
    $acl = get-acl $phpTemp
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "Modify", "Allow")
    $acl.setaccessrule($ar)
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("IIS AppPool\DefaultAppPool", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.setaccessrule($ar)
    set-acl $phpTemp $acl
}
# Install PHP Manager for IIS
#start-process "c:\windows\system32\msiexec.exe" -ArgumentList "/i $phpmgrInstallMedia /q" -Wait
#if ( (Get-PSSnapin -Name PHPManagerSnapin -ErrorAction SilentlyContinue) -eq $null )
#{
#    Add-PsSnapin PHPManagerSnapin
#}

## Copy Wincache over to extensions directory
## copy-item $wincacheDLL "$phpInstall\$phpVersion\ext"
#New-PHPVersion -ScriptProcessor "$phpInstall\$phpVersion\php-cgi.exe"
## Configure Home Office Settings
#Set-PHPSetting -name date.timezone -value "America/Chicago"
#Set-PHPSetting -name upload_max_filesize -value "10M"
## Move logging and temp space to e:
#Set-PHPSetting -name upload_tmp_dir -value $phpTemp
#Set-PHPSetting -name session.save_path -value $phpTemp
#Set-PHPSetting -name error_log -value "$phpLog\php-errors.log"
##set-phpextension -name php_wincache.dll -status enabled

# Set web root permissions
if ((Test-Path -path $webRoot) -ne $True)
{
    new-item -type directory -path $webRoot
    $acl = get-acl $webRoot
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.setaccessrule($ar)
    set-acl $webRoot $acl
}

# Set web log dir permissions
if ((Test-Path -path $webLog) -ne $True)
{
    new-item -type directory -path $webLog
    $acl = get-acl $webLog
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.setaccessrule($ar)
    set-acl $webLog $acl
}
import-module WebAdministration
set-ItemProperty 'IIS:\Sites\Default Web Site\' -name physicalPath -value $webRoot
set-ItemProperty 'IIS:\Sites\Default Web Site\' -name logFile.directory -value $webLog
stop-website 'Default Web Site'
start-website 'Default Web Site'

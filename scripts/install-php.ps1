# Specify PHP install location (version specific subdirectory will be created)
$phpInstall = "c:\php"
# Specify PHP log location
$phpLog = "c:\phplog"
# Specify PHP temp location
$phpTemp = "c:\phptemp"
# Path for downloaded files
$downloads = "c:\downloads"
# Specify desired Webroot location
$webRoot = "c:\inetpub\wwwroot"
# Specify desired weblogs location
$webLog = "c:\SitesLogs"

# Specify PHP files and paths
$phpVersion = "7.1.13"
# Name of file to download
$phpInstallZip = "php-$phpVersion-nts-Win32-VC14-x64.zip"
# Download path for php
$phpDownloadURL = "http://windows.php.net/downloads/releases/$phpInstallZip"
$phpDownloadFile = "$downloads\$phpInstallZip"
$phpVersionInstall = "$phpInstall\$phpVersion"
$phpCGIPath = "$phpVersionInstall\php-cgi.exe"
$phpINIPath = "$phpVersionInstall\php.ini"
$phpINITemplate = "$phpVersionInstall\php.ini-development"

# Setup download folder
if ((Test-Path -path $downloads) -ne $True)
{
    new-item -type directory -path $downloads
}

# Download PHP archive
if ((Test-Path $phpDownloadFile) -ne $True)
{
    $startTime = Get-Date
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($phpDownloadURL, $phpDownloadFile)
    Write-Output "Downloaded resources in $( (Get-Date).Subtract($startTime).Seconds ) second(s)"
}

# Install zip to destination folder in c:\php\7.1.13\
if ((Test-Path -path $phpVersionInstall) -ne $True)
{
    Expand-Archive $phpDownloadFile -DestinationPath $phpVersionInstall
}

# ensure php.ini exists and is configured
if ((Test-Path -path $phpINIPath) -ne $True)
{
    Copy-Item $phpINITemplate $phpINIPath
}

# Replace PHP ini vars
(Get-Content $phpINIPath) | ForEach-Object {
    $_ -replace ';?date.timezone.*', 'date.timezone = "Pacific/Auckland"' `
        -replace ';?upload_max_filesize.*', 'upload_max_filesize = 10M' `
        -replace ';?display_errors.*', 'display_errors = On' `
        -replace ';?upload_tmp_dir.*', "upload_tmp_dir = `"$phpTemp`"" `
        -replace ';?session.save_path.*', "session.save_path = `"$phpTemp`"" `
        -replace ';?error_log.*', "error_log = `"$phpLog\php-errors.log`""
} | Set-Content $phpINIPath

#Install IIS Components for PHP over FastCGI
start-process "c:\windows\system32\pkgmgr.exe" -ArgumentList "/iu:IIS-WebServerRole;IIS-WebServer;IIS-CommonHttpFeatures;IIS-StaticContent;IIS-DefaultDocument;IIS-DirectoryBrowsing;IIS-HttpErrors;IIS-HealthAndDiagnostics;IIS-HttpLogging;IIS-LoggingLibraries;IIS-RequestMonitor;IIS-Security;IIS-RequestFiltering;IIS-HttpCompressionStatic;IIS-WebServerManagementTools;IIS-ManagementConsole;WAS-WindowsActivationService;WAS-ProcessModel;WAS-NetFxEnvironment;WAS-ConfigurationAPI;IIS-CGI" -Wait

#Set ACLs for PHP for IIS to process it appropriately
if ((Test-Path -path $phpInstall) -ne $True)
{
    new-item -type directory -path $phpInstall
}
$acl = get-acl $phpInstall
$ar = new-object system.security.accesscontrol.filesystemaccessrule("IIS AppPool\DefaultAppPool", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.setaccessrule($ar)
$ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.setaccessrule($ar)
set-acl $phpInstall $acl

# Set ACL for c:\phplog
if ((Test-Path -path $phpLog) -ne $True)
{
    new-item -type directory -path $phpLog
}
$acl = get-acl $phpLog
$ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "Modify", "Allow")
$acl.setaccessrule($ar)
$ar = new-object system.security.accesscontrol.filesystemaccessrule("IIS AppPool\DefaultAppPool", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.setaccessrule($ar)
set-acl $phpLog $acl

# Set ACL for c:\phptemp
if ((Test-Path -path $phpTemp) -ne $True)
{
    new-item -type directory -path $phpTemp
}
$acl = get-acl $phpTemp
$ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "Modify", "Allow")
$acl.setaccessrule($ar)
$ar = new-object system.security.accesscontrol.filesystemaccessrule("IIS AppPool\DefaultAppPool", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.setaccessrule($ar)
set-acl $phpTemp $acl

# Set web root permissions
if ((Test-Path -path $webRoot) -ne $True)
{
    new-item -type directory -path $webRoot
}
$acl = get-acl $webRoot
$ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.setaccessrule($ar)
set-acl $webRoot $acl

# Set web log dir permissions
if ((Test-Path -path $webLog) -ne $True)
{
    new-item -type directory -path $webLog
}
$acl = get-acl $webLog
$ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.setaccessrule($ar)
set-acl $webLog $acl

# Set user PHP PATH
if (!$Env:PATH.Contains($phpVersionInstall))
{
    $Env:PATH = $Env:PATH + ';' + $phpVersionInstall
}

# Set system PHP exe
$environmentKey = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
$oldPath = (Get-ItemProperty -Path $environmentKey -Name PATH).Path
if (!$oldPath.contains($phpVersionInstall))
{
    $newPath = $oldPath + ';' + $phpVersionInstalvagrant
    Set-ItemProperty -Path $environmentKey -Name PATH -Value $newPath
}

# Set ini path
Set-ItemProperty -Path $environmentKey -name PHPRC -Value $phpVersionInstall
$Env:PHPRC = $phpVersionInstall

# Add PHP module mapping
if (!(Get-Webhandler -Name "PHP-FastCGI"))
{
    New-WebHandler -Name "PHP-FastCGI" -Path "*.php" -Verb "*" -Modules "FastCgiModule" -ScriptProcessor $phpCGIPath -ResourceType File
}

# Set web root path
import-module WebAdministration
set-ItemProperty 'IIS:\Sites\Default Web Site\' -name physicalPath -value $webRoot
set-ItemProperty 'IIS:\Sites\Default Web Site\' -name logFile.directory -value $webLog
stop-website 'Default Web Site'
start-website 'Default Web Site'

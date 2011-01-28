# Set up our colors.
$myHost = Get-Host
$bColor = 'Cyan'
$gColor = 'White'
if ($myHost) {
	$ui = $myHost.UI.RawUI
	$ui.WindowTitle = 'BukkitMod Plugin Generator'
	switch($ui.BackgroundColor) {
		White {
			$gColor = 'Black'
			$bColor = 'DarkCyan'
		}
		default {
			$gColor = 'White'
			$bColor = 'Cyan'
		}
	}
} else {
	$gColor = 'White'
	$bColor = 'Cyan'
}

# Aliases
Set-Alias wh Write-Host
Set-Alias rh Read-Host
Set-Alias bp Bullet-Point

# Get the directory of the current running script.
function Get-ScriptDirectory {
	if (Test-Path variable:\hostinvocation) {
		$fullPath=$hostinvocation.MyCommand.Path
	} else {
		$fullPath=(get-variable myinvocation -scope script).value.Mycommand.Definition }   
		if (Test-Path $fullPath) {
		return (Split-Path $fullPath)
	} else {
		$fullPath=(Get-Location).path
		Write-Warning ("Get-ScriptDirectory: Powershell Host <" + $Host.name + "> may not be compatible with this function, the current directory <" + $fullPath + "> will be used.")
		return $fullPath
	}
}

# For quick bullet-point type things.
function Bullet-Point() {
	wh "+ " -ForegroundColor $gColor -NoNewline
}

# Check if config files exists. If it does, load it.
function Get-Config($root) {
	wh "Checking for configuration file.." -ForegroundColor Green
	$configFile = Join-Path $root "settings.cfg"
	$Configuration = @{}
	if (Test-Path $configFile) {
		bp
		wh "Configuration exists." -ForegroundColor DarkGreen
		bp
		wh "Loading configuration.." -ForegroundColor DarkGreen
		$configData = Get-Content $configFile
		foreach ($line in $configData) {
			if ($line -cmatch '(?mx)^(?<key>[^#=]+)=(?<value>.*?)$') {
				$Configuration[$matches['key']] = $matches['value']
			}
		}
		bp
		wh "Configuration successfully loaded." -ForegroundColor DarkGreen
	} else {
		bp
		wh "Configuration does not exist. Creating it.." -ForegroundColor DarkGreen
		$configData = "# General Settings`noutput_folder='.'`n`n# Project File Generation`ngen_intellij=0`ngen_eclipse=0`ngen_netbeans=0`ngen_ant=0"
		Set-Content -Path $configFile -Value $configData
		bp
		wh "Done" -ForegroundColor DarkGreen
	}
	
	# Now go through and give a value to any that don't have one.
	if (!$Configuration['output_folder']) {
		$Configuration['output_folder'] = '.'
	} else {
		$Configuration['output_folder'] = $Configuration['output_folder'].Replace('"."', '.')
	}
	if (!$Configuration['gen_intellij']) {
		$Configuration['gen_intellij'] = 0
	}
	if (!$Configuration['gen_eclipse']) {
		$Configuration['gen_eclipse'] = 0
	}
	if (!$Configuration['gen_netbeans']) {
		$Configuration['gen_netbeans'] = 0
	}
	if (!$Configuration['gen_ant']) {
		$Configuration['gen_ant'] = 0
	}
	
	# And we're done.
	return $Configuration
}

# Our banner
wh " ___   _     _     _     _  _____`n| |_) | | | | |_/ | |_/ | |  | |`n|_|_) \_\_/ |_| \ |_| \ |_|  |_|" -ForegroundColor $bColor
wh " __    ____  _      ____  ___    __   _____  ___   ___`n/ /``_ | |_  | |\ | | |_  | |_)  / /\   | |  / / \ | |_)`n\_\_/ |_|__ |_| \| |_|__ |_| \ /_/--\  |_|  \_\_/ |_| \`n" -ForegroundColor $gColor


# Configuration
$PSScriptRoot = Get-ScriptDirectory
$config = Get-Config($PSScriptRoot)

# Now for the questions..
## Author's Name
wh "`nWe now need information on your plugin." -ForegroundColor $gColor
bp
wh "Author's Name" -NoNewline -ForegroundColor $bColor
$authorName = rh ":"
while($authorName.length -eq 0) {
	bp
	wh "Error: " -ForegroundColor Red -NoNewline
	wh "Value cannot be empty." -ForegroundColor $gColor
	bp
	wh "Author's Name" -NoNewline -ForegroundColor $bColor
	$authorName = rh ":"
}
## Plugin's Name
bp
wh "Plugin's Name" -NoNewline -ForegroundColor $bColor
$pluginName = rh ":"
while($pluginName.length -eq 0) {
	bp
	wh "Error: " -ForegroundColor Red -NoNewline
	wh "Value cannot be empty." -ForegroundColor $gColor
	bp
	wh "Plugin's Name" -NoNewline -ForegroundColor $bColor
	$pluginName = rh ":"
}
## Plugin's Version (Can be empty)
bp
wh "Plugin's Version" -NoNewline -ForegroundColor $bColor
wh "(Default: 0.1)" -NoNewline -ForegroundColor Magenta
$pluginVersion = rh ":"
if(!$pluginVersion) {
	$pluginVersion = '0.1'
}

## Let the code generation begin.
wh "`nStarting Code Generation.." -ForegroundColor Green

## First, we need to set up the eventual paths.
bp
wh "Building Plugin Folder Structure.." -ForegroundColor DarkGreen
$BLOCKLISTENER = "BlockListener.java"
$YBLOCKLISTENER = $pluginName + $BLOCKLISTENER
$PLAYERLISTENER = "PlayerListener.java"
$YPLAYERLISTENER = $pluginName + $PLAYERLISTENER
$PLUGIN = "YPlugin.java"
$YPLUGIN =  $pluginName + ".java"
if ($config["output_folder"] -ceq '.') { $config["output_folder"] = Get-Location }
$ENDPATH = Join-Path -Path $config["output_folder"] -ChildPath ($pluginName + "\src\com\bukkit\" + $authorName + "\" + $pluginName)
$BINPATH = Join-Path -Path $config["output_folder"] -ChildPath ($pluginName + "\bin")
$ROOTPATH = Join-Path -Path $config["output_folder"] -ChildPath $pluginName
$buffer = mkdir -Force $ENDPATH
$buffer = mkdir -Force $BINPATH
$buffer = $null

## Generate manifest.
bp
wh "Generating Plugin Manifest" -ForegroundColor DarkGreen
Set-Location -Path $ROOTPATH
$content = "name: " + $pluginName + "`n`nmain: com.bukkit." + $authorName + "." + $pluginName + "`n`nversion: " + $pluginVersion
$buffer = Set-Content -Path (Join-Path -Path $ROOTPATH -ChildPath "plugin.yml") -Value $content -Force
$content = $null
$buffer = $null

## Generate sources
bp
wh "Generating Plugin Source" -ForegroundColor DarkGreen
Set-Location -Path $PSScriptRoot
$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath ("files\" + $BLOCKLISTENER)
				)))).Replace("<yourname>", $authorName).Replace("<pluginname>", $pluginName)
			) -Path (Join-Path -Path $ENDPATH -ChildPath $YBLOCKLISTENER) -Force
$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath ("files\" + $PLAYERLISTENER)
				)))).Replace("<yourname>", $authorName).Replace("<pluginname>", $pluginName)
			) -Path (Join-Path -Path $ENDPATH -ChildPath $YPLAYERLISTENER) -Force
$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath ("files\" + $PLUGIN)
				)))).Replace("<yourname>", $authorName).Replace("<pluginname>", $pluginName)
			) -Path (Join-Path -Path $ENDPATH -ChildPath $YPLUGIN) -Force

## Generate project files.
### Eclipse
if ($config["gen_eclipse"] -eq 1) {
	bp
	wh "Generating Eclipse Project.." -ForegroundColor DarkGreen
	$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath "projects\eclipse\.project"
				)))).Replace("{{PLUGINNAME}}", $pluginName)
			) -Path (Join-Path -Path $ROOTPATH -ChildPath ".project") -Force
	$buffer = cp (Join-Path -Path $PSScriptRoot -ChildPath "projects\eclipse\.classpath") (Join-Path -Path $ROOTPATH -ChildPath ".classpath")
}
### IntelliJ
if ($config["gen_intellij"] -eq 1) {
	bp
	wh "Generating IntelliJ Project.." -ForegroundColor DarkGreen
	$buffer = mkdir -Force (Join-Path -Path $ROOTPATH -ChildPath ".idea")
	$buffer = cp (Join-Path -Path $PSScriptRoot -ChildPath "projects\intellij\compiler.xml") (Join-Path -Path $ROOTPATH -ChildPath ".idea\compiler.xml")
	$buffer = cp (Join-Path -Path $PSScriptRoot -ChildPath "projects\intellij\encodings.xml") (Join-Path -Path $ROOTPATH -ChildPath ".idea\encodings.xml")
	$buffer = cp (Join-Path -Path $PSScriptRoot -ChildPath "projects\intellij\vcs.xml") (Join-Path -Path $ROOTPATH -ChildPath ".idea\vcs.xml")
	$buffer = cp (Join-Path -Path $PSScriptRoot -ChildPath "projects\intellij\project.iml") (Join-Path -Path $ROOTPATH -ChildPath ($pluginName + ".iml"))
	$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath "projects\intellij\modules.xml"
				)))).Replace("{{PLUGINNAME}}", $pluginName)
			) -Path (Join-Path -Path $ROOTPATH -ChildPath ".idea\modules.xml") -Force
	$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath "projects\intellij\workspace.xml"
				)))).Replace("{{PLUGINNAME}}", $pluginName)
			) -Path (Join-Path -Path $ROOTPATH -ChildPath ".idea\workspace.xml") -Force
}
### Netbeans
if ($config["gen_netbeans"] -eq 1) {
	bp
	wh "Generating Netbeans Project.." -ForegroundColor DarkGreen
	$buffer = mkdir -Force (Join-Path -Path $ROOTPATH -ChildPath "nbproject\private")
	$buffer = cp (Join-Path -Path $PSScriptRoot -ChildPath "projects\netbeans\genfiles.properties") (Join-Path -Path $ROOTPATH -ChildPath "nbproject\genfiles.properties")
	$buffer = cp (Join-Path -Path $PSScriptRoot -ChildPath "projects\netbeans\private\private.properties") (Join-Path -Path $ROOTPATH -ChildPath "nbproject\private\private.properties")
	$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath "projects\netbeans\project.properties"
				)))).Replace("{{PLUGINNAME}}", $pluginName)
			) -Path (Join-Path -Path $ROOTPATH -ChildPath "nbproject\project.properties") -Force
	$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath "projects\netbeans\build-impl.xml"
				)))).Replace("{{PLUGINNAME}}", $pluginName)
			) -Path (Join-Path -Path $ROOTPATH -ChildPath "nbproject\build-impl.xml") -Force
	$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath "projects\netbeans\project.xml"
				)))).Replace("{{PLUGINNAME}}", $pluginName)
			) -Path (Join-Path -Path $ROOTPATH -ChildPath "nbproject\project.xml") -Force
}
### Ant
if ($config["gen_ant"] -eq 1) {
	bp
	wh "Generating Ant Build Files.." -ForegroundColor DarkGreen
	$buffer =	Set-Content -Value (
				([string]::join([environment]::newline,(Get-Content -Path (
					Join-Path -Path $PSScriptRoot -ChildPath "projects\ant\build.xml"
				)))).Replace("{{PLUGINNAME}}", $pluginName)
			) -Path (Join-Path -Path $ROOTPATH -ChildPath "build.xml") -Force
}

bp
wh "Plugin generation finished! Now exitting.." -ForegroundColor DarkGreen
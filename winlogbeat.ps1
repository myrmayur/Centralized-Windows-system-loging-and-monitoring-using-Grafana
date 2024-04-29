
# Define the path to the MSI file
$msiFilePath = "\\srv1\soft_share\winlogbeat-8.13.1-windows-x86_64.msi"
$installScriptPath = "C:\Program Files\Elastic\Beats\8.13.1\winlogbeat\install-service-winlogbeat.ps1"
$documentFilePath = "\\srv1\soft_share\winlogbeat.yml"
$targetFilePath = "C:\Program Files\Elastic\Beats\8.13.1\winlogbeat\winlogbeat.example.yml"

Function Log-Message([String]$Message)
{
	$logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$env:COMPUTERNAME] $Message"
    Add-Content -Path "\\srv1\soft_install_logs\installation_log.txt" -Value $logMessage
}
if (Test-Path $installScriptPath) {
    Log-Message "Winlogbeat configuration file already exists. Skipping installation."
} else {
 if (Test-Path $msiFilePath) {
    try {
        # Install MSI package
        Start-Process msiexec -Wait -ArgumentList "/i `"$msiFilePath`" /quiet /qn /norestart" -NoNewWindow -PassThru
		Log-Message "Installation completed.:"
		
		# Change working directory to the location where the install.ps1 script is located
        Set-Location -Path (Split-Path -Parent $installScriptPath)
        
        # Execute script
        .\install-service-winlogbeat.ps1
        Log-Message "install-service-winlogbeat.ps1 script executed."
		
		# Navigate to the desired location after installation
        $desiredLocation = "C:\Program Files\Elastic\Beats\8.13.1\winlogbeat\"
        Set-Location -Path $desiredLocation

        Copy-Item -Path $documentFilePath -Destination $targetFilePath -Force
		Remove-Item -Path $targetFilePath -Force
		
		
		# Start the Winlogbeat service
        Start-Service -Name "winlogbeat"
        Log-Message "Winlogbeat service started."
       
	
    } catch {
        Write-Host "An error occurred while installing the MSI package: $_"
		Log-Message "An error occurred while installing the MSI package:"
    }
	
} else {
    Write-Host "The specified MSI file does not exist."
	Log-Message "The specified MSI file does not exist."
}
}

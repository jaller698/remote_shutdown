param (
    [string]$serviceName = "RemoteShutdownService3",
    [string]$displayName = "Remote Shutdown Service",
    [string]$description = "Service for remote shutdown functionality"
)

# Get the current directory
$currentDir = Get-Location

# Define the path to the executable
$exePath = Join-Path $currentDir "remote_shutdown.exe"

# Validate the executable path
if (-not (Test-Path $exePath)) {
    Write-output "The executable remote_shutdown.exe was not found in the current directory: $currentDir"
    $currentDir = Get-Location
    $ExePath = Join-Path $currentDir "target/release/remote_shutdown.exe"
    if (-not (Test-Path $exePath)) {
        Write-Error "The executable remote_shutdown.exe was not found in the target directory: $ExePath"
        exit 1
    }
    Copy-Item "config.ini" "target/release"
}

# Check if NSSM is available
if (-not (Get-Command nssm -ErrorAction SilentlyContinue)) {
    Write-Error "NSSM (Non-Sucking Service Manager) is not found in the system PATH. Please install NSSM and add it to the PATH."
    exit 1
}

# stop the service if it is already running
& nssm stop $serviceName

# Install the service using NSSM
& nssm install $serviceName $exePath

# Set the service display name and description
& nssm set $serviceName DisplayName $displayName
& nssm set $serviceName Description $description
& nssm set $serviceName Start SERVICE_AUTO_START

# Start the service
& nssm start $serviceName

Write-Output "Service '$serviceName' created and started successfully using NSSM."
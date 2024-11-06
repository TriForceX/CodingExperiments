# PowerShell settings
$psHost = Get-Host
$psWindow = $psHost.UI.RawUI
$psWindow.WindowTitle = "Dynamic DNS Update"

# DDNS WebCall URL
$ddns_url = "https://yourdomain.com/cpanelwebcall/xxxxxxxxxx"

# Log file location
$log_file = "update_ddns.log"

# Get Public IP URL
$ip_url = "https://checkip.amazonaws.com"
# $ip_url = "https://ipecho.net/plain"
# $ip_url = "https://ifconfig.me/ip"
# $ip_url = "https://api.ipify.org"

# Command Line
try {
    # Attempt to make the web request to the DDNS URL
    $response = Invoke-WebRequest -Uri $ddns_url -UseBasicParsing
    
    if ($response.StatusCode -eq 200) {
        # If successful, get public IP and display success message
        $publicIP = (Invoke-WebRequest -Uri $ip_url -UseBasicParsing).Content.Trim()
        $message = "DDNS Update Done! IP: $publicIP"
        Write-Host $message
        
        # Remove log file if update is successful
        Remove-Item -Path $log_file -ErrorAction SilentlyContinue
    } else {
        # If the status code is not 200, log the error
        $message = "DDNS Update Failed! Status Code: $($response.StatusCode)"
        Write-Host $message
        
        # Log the failure with timestamp
        $dateTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        "[${dateTime}] $message" | Out-File -Append $log_file
    }
} catch {
    # If an error occurs, log the error message
    $message = "DDNS Update Failed! $($_.Exception.Message)"
    Write-Host $message
    
    # Log the error with timestamp
    $dateTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "[${dateTime}] $message" | Out-File -Append $log_file
}

# Countdown with user-interrupt option
$timeRemaining = 10

Write-Host "`nWaiting for $timeRemaining seconds. press a key to continue ..."
for ($i = $timeRemaining; $i -gt 0; $i--) {
    Start-Sleep -Seconds 1
    
    # Check if a key is pressed to interrupt the countdown
    if ($host.UI.RawUI.KeyAvailable) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        break
    }
}
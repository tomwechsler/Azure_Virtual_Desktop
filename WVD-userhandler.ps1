## Check if exists disconnected sessions
if($quser = quser | Where-Object {$_ -match 'Disc'}){
    echo "there are disconnected user"
    ## Find all sessions matching state disconnected
    $sessions = quser | Where-Object {$_ -match 'Disc'}
    ## Parse the session IDs from the output
    $sessionIds = ($sessions -split ' +')[2]
    Write-Host "Found $(@($sessionIds).Count) disconnected users on WVD host."
    ## Loop through each session ID and pass each to the logoff command
    $sessionIds | ForEach-Object {
        Write-Host "Logging off session id [$($_)]..."
        logoff $_
    }
}
else {
    echo "there are no disconnected user"
     ## Check for active session. If not, shutdown
    $sessioncount = quser | Where-Object {$_ -match 'rdp-sxs'}
    if($sessioncount.count -eq 0) {
        echo "no more active users -> shutdown"
        Stop-AzVM -Name ssb-vm-wvd-1 -ResourceGroupName ssb-rg04-wvd-session-hosts -Force
    }
    else {
        echo "keep alive. there are active users"
    }
}


<#
.SYNOPSIS
    Create a higher priority listener for a service where the service has socket reuse
.EXAMPLE
 param 1  = -my local IP address to listen on
 param 2 = -port

=list all 0.0.0.0 TCP listeners in an array
for each one see if can create a local IP listener
create a listener on local IP at each port
then anything recevied is printed to screen (preceed with the port
is also sent to associated server at 0.0.0.0 at that port

#>
param([string]$IP)

try {            
    $TCPProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()            
    $KeepAlive=5
    $ListenTimeOutt = New-TimeSpan -Seconds 3; $LT = $ListenTimeOutt.Seconds
    $TIME = [diagnostics.stopwatch]::StartNew()
    $Connections = $TCPProperties.GetActiveTcpListeners()            
	[Array]$servers= $null
    foreach($Connection in $Connections) {            
        if($Connection.address.AddressFamily -eq "InterNetwork" ) { $IPType = "IPv4" } else { $IPType = "IPv6" }            
	<# ignore ipv6 and look only for wildcard listeners #>
	if (  $connection.Address -eq "0.0.0.0" )
	{
		$EP = new-object System.Net.IPEndPoint ([system.net.IPAddress]::Parse($IP), $Connection.Port)
		$LSTN = new-object System.Net.Sockets.TcpListener $EP
		$LSTN.Server.SetSocketOption("Socket", "ReuseAddress", 0)
		$LSTN.server.ReceiveTimeout = 300
		try
		{
		    $LSTN.start()
		    $start = get-date

		    While ($TIME.elapsed -lt $ListenTimeOutt)
		    {
			if (!$LSTN.Pending()) {Start-Sleep -Seconds 1;continue;}
			$CONNECT = $LSTN.AcceptTcpClient()
			$CONNECT.client.RemoteEndPoint | Add-Member -NotePropertyName Date -NotePropertyValue (get-date) -PassThru | Add-Member -NotePropertyName Status -NotePropertyValue Connected -PassThru | select Status,Date,Address,Port
			Start-Sleep -Seconds $KeepAlive;
			$CONNECT.client.RemoteEndPoint | Add-Member -NotePropertyName Date -NotePropertyValue (get-date) -PassThru -Force | Add-Member -NotePropertyName Status -NotePropertyValue Disconnected -PassThru -Force | select Status,Date,Address,Port
			$CONNECT.close()
		    }
		}

		catch {continue}
		finally {$LSTN.stop(); $end = get-date; Write-host "$end - Listen attempted on port $connection"}


		$OutputObj = New-Object -TypeName PSobject            
		$OutputObj | Add-Member -MemberType NoteProperty -Name "LocalAddress" -Value $connection.Address            
		$OutputObj | Add-Member -MemberType NoteProperty -Name "ListeningPort" -Value $Connection.Port            
		$OutputObj | Add-Member -MemberType NoteProperty -Name "IPV4Or6" -Value $IPType            
		$servers += $OutputObj           
	}
    }            
            
} catch {            
    Write-Error "Failed to get listening connections. $_"            
}           
Foreach ($server in $servers)
{
	"`nVulnerable: port: {0}" -f $server.ListeningPort
}
exit

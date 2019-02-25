Param([string]$IP, [string]$port)
Try { 
            # Set up endpoint and start listening
	$endpoint = new-object System.Net.IPEndPoint([system.net.IPAddress]::Parse($IP),$port) 
	$listener = new-object System.Net.Sockets.TcpListener $EndPoint
	$listener.Server.SetSocketOption("Socket", "ReuseAddress", 1)
 
	while ( $true)
	{
		# Wait for an incoming connection 
		$listener.start() 
		$data = $listener.AcceptTcpClient() 
		
		    # Stream setup
		$stream = $data.GetStream() 
		$bytes = New-Object System.Byte[] 1024

		    # Read data from stream and write it to host
		while (($i = $stream.Read($bytes,0,$bytes.Length)) -ne 0)
		{
			$EncodedText = New-Object System.Text.ASCIIEncoding
			$data = $EncodedText.GetString($bytes,0, $i)
			Write-Output "$i $data"
		}
		    # Close TCP connection and stop listening
		$stream.close();
		$listener.stop();
		$socket = New-Object System.Net.Sockets.TcpClient( [system.net.IPAddress]::Parse($IP), $port )
		if ( $socket )
		{
			$stream2 = $socket.GetStream( )
			$writer = New-Object System.IO.StreamWriter( $stream2 )
			Write-Host "Sending $data ... " -NoNewLine
			$writer.WriteLine( $data )
			$writer.Flush( )
			$writer.close()
			$stream2.close()
			$socket.close()
		}
		if ( $data -match 'break' )
		{
			$stream.close();
			$listener.stop();
			break
		}
	}

}
Catch 
{
	"Receive Message failed with: `n" + $Error[0]
}


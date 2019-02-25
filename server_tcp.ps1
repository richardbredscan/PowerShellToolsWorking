        Try { 
            # Set up endpoint and start listening
            $endpoint = new-object System.Net.IPEndPoint([ipaddress]::any,"5041") 
            $listener = new-object System.Net.Sockets.TcpListener $EndPoint
            $listener.start() 
 
while ( $true)
{
            # Wait for an incoming connection 
            $data = $listener.AcceptTcpClient() 
        
            # Stream setup
            $stream = $data.GetStream() 
            $bytes = New-Object System.Byte[] 1024

            # Read data from stream and write it to host
            while (($i = $stream.Read($bytes,0,$bytes.Length)) -ne 0){
                $EncodedText = New-Object System.Text.ASCIIEncoding
                $data = $EncodedText.GetString($bytes,0, $i)
                Write-Output $data
            }
            if ( $data -match 'break' )
	    {
		break
	    }
}

            # Close TCP connection and stop listening
            $stream.close()
            $listener.stop()
        }
        Catch {
            "Receive Message failed with: `n" + $Error[0]
        }

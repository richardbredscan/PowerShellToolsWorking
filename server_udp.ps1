$port=2020
$endpoint = new-object System.Net.IPEndPoint ([IPAddress]::Any,$port)
$udpclient=new-Object System.Net.Sockets.UdpClient $port
$content=$udpclient.Receive([ref]$endpoint)
[Text.Encoding]::ASCII.GetString($content)


$b=[Text.Encoding]::ASCII.GetBytes('Is anyone there?')
$bytesSent=$udpclient.Send($b,$b.length,$endpoint)
$udpclient.Close()

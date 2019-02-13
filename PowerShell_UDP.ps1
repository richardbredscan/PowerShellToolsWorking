<#  
.SYNOPSIS 
    Sends a UDP datagram to a port 
.EXAMPLE 
 param 1  = -IP
 param 2 = -port
 param 3 = -msg hexstring

#> 

### 
#  Start of Script 
## 

# Define port and target IP address 
# Random here! 
param([string]$IP,[int]$Port,[string]$Message) 
$Message = for($i=0; $i -lt $Message.length; $i+=2)
    {
       [char][int]::Parse($Message.substring($i,2),'HexNumber')
    }
#[int] $Port = 20000 
#$IP = "10.10.1.100" 
$Address = [system.net.IPAddress]::Parse($IP) 

# Create IP Endpoint 
$End = New-Object System.Net.IPEndPoint $address, $port 

# Create Socket 
$Saddrf   = [System.Net.Sockets.AddressFamily]::InterNetwork 
$Stype    = [System.Net.Sockets.SocketType]::Dgram 
$Ptype    = [System.Net.Sockets.ProtocolType]::UDP 
$Sock     = New-Object System.Net.Sockets.Socket $saddrf, $stype, $ptype 
$Sock.TTL = 26 

# Connect to socket 
$sock.Connect($end) 

# dont wait for response
$sock.Client.Blocking = $False

# Create encoded buffer 
$Enc     = [System.Text.Encoding]::ASCII 
$Buffer  = $Enc.GetBytes($Message) 

# set up the reciever
$remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0)


# Send the buffer 
$Sent   = $Sock.Send($Buffer) 
"{0} characters sent to: {1} " -f $Sent,$IP 
"Message was:" 
$Message 
If ($receivebytes) {
    [string]$returndata = $Sock.GetString($receivebytes)
    $returndata
} Else {
    "No data received from {0} on port {1}" -f $IP,$Port
}
$sock.Close()
# End of Script 

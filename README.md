# PowerShellTools
A repo of powershell versions of tools that may be of use on a redteam

UDP Client - send hex string to a UDP port on a remote server - e,g, to perform a MSSQLPing: remote_IP 1433 02

UDP Server - will ask user for permission to create a listener - so not quiet. Will listen on a port u specify and send a hardcoded message - change as you see fit

service_perms - will review all services for permissions issues - first on the executables and then on the registry keys
(needs work to also review perms on folders where exe is to see if dll hijack possible)

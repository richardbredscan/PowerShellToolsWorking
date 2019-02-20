Clear-Host
$Keys = Get-ChildItem HKLM:\System\CurrentControlSet\services
$Items = $Keys | Foreach-Object {Get-ItemProperty $_.PsPath }
$num_services=0;
ForEach ($Item in $Items){
     
        $prt=$Null        
        $num_services+=1
        $exe_perm=Try{((($Item.ImagePath -replace '\\SystemRoot(.*)','C:\Windows$1') -replace '^([Ss]ystem32.*)','C:\windows\$1').split("-")[0]|Get-ACL -ErrorAction Stop|format-List|Out-String)} Catch { Try{($item.ImagePath|Get-ACL -ErrorAction Stop |Format-List)} Catch{ $item.ImagePath} }
        $exe_perm= $exe_perm -replace "NT AUTHORITY\\SYSTEM\s+Allow(\s+(\S+),)*?\s+(\S+)"," "
        $exe_perm= $exe_perm -replace "BUILTIN\\Administrators\s+Allow(\s+(\S+),)*?\s+(\S+)"," "
        $exe_perm= $exe_perm -replace "\s+Synchronize"," "
        ($exe_perm = ($exe_perm | Select-String "(?smi)(Path\s+:.*?(BUILTIN|AUTHENTICATED)\\\S+\s+Allow\s+(FullControl|268435456|1073741824))" -AllMatches| %{$_.Matches} | %{$_.Value})) | Out-Null

        if (-not ([string]::IsNullOrEmpty($exe_perm)))
        {
                $Item.PSChildName
                $Item.ImagePath
                $exe_perm
                $prt=1
        }

<# check registry perms #>
        $reg_perm = (($item.PSPath )|Get-ACL|Format-List|Out-String)
        $reg_perm= $reg_perm -replace "NT AUTHORITY\\SYSTEM\s+Allow(\s+(\S+),)*?\s+(\S+)"," "
        $reg_perm= $reg_perm -replace "BUILTIN\\Administrators\s+Allow(\s+(\S+),)*?\s+(\S+)"," "
        $reg_perm= $reg_perm -replace "\s+Synchronize"," "
        ($reg_perm = ($reg_perm | Select-String "(?smi)(Path\s+:.*?\\\S+\s+Allow\s+(FullControl|268435456|1073741824))" -AllMatches| %{$_.Matches} | %{$_.Value})) | Out-Null
        if (-not ([string]::IsNullOrEmpty($reg_perm)))
        {
                if ( $prt -eq $null )
                {
                        $Item.PSChildName
                }
                $Item.PSPath
                $reg_perm
                $prt+=1
        }
        if ( $prt )
        {
                "--------"
        }

}
"{0} services reviewed for permission weaknesses on registry and executables, folder permissions not checked" -f $num_services


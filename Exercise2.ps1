<#
  .SYNOPSIS
  The file books a Ip in a scope

  .DESCRIPTION
  The Exercise 2.ps1 book an IP in the scope based in a range, a MAC Address and a recommended IP Address.

#>


# Getting the list of every DHCP Servers

Get-DhcpServerv4Scope



$ArrayList = New-Object System.Collections.ArrayList

$ipnum = Read-Host "Introduce the number of free Ips expected"

# Creating and fullfilling the array created with the dhcps that success the requirements

$dhcpservers = Get-DhcpServerv4ScopeStatistics
foreach($server in $dhcpservers){
 if($server.Free -ge [int]($ipnum)){

   $IP =  $server.ScopeId.IPAddressToString
   $free = $server.Free
   Write-Host "The server with IP: $IP has $free ips available"

   $element1 = @{
    "IP" = "$IP"
    "Free" = [int]$free
    }

    $c=$ArrayList.Add($elemento1)


 }

}

# Make reservation and validating the IPS

$confirm = Read-Host "Do you want to make a reservation?(y/n)"
if($confirm -eq "y"){
  $check = $false
  while($check -ne "true"){
  $ipchoosed = Read-Host "Now we are going to choose the scope. Which one do you want to use?: "
  $macdir = Read-Host "Introduce the MAC Address that you want to use: "
  try{
  $iprecom = Get-DhcpServerv4FreeIPAddress -ScopeId $ipchoosed 
  $check = $true
  }catch{
    Write-Host "An error has occur with the recommendation. Check if the choosen scope has free IPs" -ForegroundColor Red
    $ch = Read-Host "Do you want to input new information? (y/n)"
    if($ch -eq "n"){
        exit
    }
    
  }
  }
  $confirm2 = Read-Host "Please confirm the data: IP- $ipchoosed MAC- $macdir with a y/n"
  if($confirm2 -eq "y"){
  Add-DhcpServerv4Reservation -ScopeId $ipchoosed -IPAddress $iprecom -ClientId $macdir
  Write-Host "Reservation succeed!!" -ForegroundColor Green
  }



}
Write-Host "--------------------------------------------------------------------------------"

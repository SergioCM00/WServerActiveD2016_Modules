<#
  .SYNOPSIS
  Obtain the success and fails logins for each user

  .DESCRIPTION
  Th script collect the data from the rows with ID 4768 and 4771 and print it.

#>


$array = @()

# Successful Logins,fullfilling the array with the correct logins
$loginFilterSuccess = @{
    LogName = 'Security'
    Id=4768
}

$successlogins = Get-WinEvent -FilterHashtable $loginFilterSuccess
$success = 0
foreach($count1 in $successlogins){
   $user = $count1.Properties[0].value
   $userstring = [string]($user)
   if($userstring[-1] -ne "$"){

    if($array.Count -eq 0){
        $base = [PSCustomObject]@{
            User = $user
            Success = 1
            Fail = 0
        }
     $array += $base
    }else{
        $already = $false
        foreach ($line in $array){
            if($line.User -eq $user){
             $line.Success = $line.Success + 1
             $already = $true
            }
         }
  
         if($already -ne "True"){
            $base2 = [PSCustomObject]@{
                User = $user
                Success = 1
                Fail = 0
            }
            $array += $base2 
          }    
    }
   $success++
   }
   
}


# Failed Logins, fullfilling the array with the error logins
$loginFilterFail = @{
    LogName = 'Security'
    Id=4771
}

$faillogins = Get-WinEvent -FilterHashtable $loginFilterFail
$fail = 0
foreach($count2 in $faillogins){
  $user = $count2.Properties[0].value
  $userstring = [string]($user)
  if($userstring[-1] -ne "$"){
        $already2 = $false
        foreach ($line in $array){
            if($line.User -eq $user){
             $line.Fail = $line.Fail + 1
             $already2 = $true
            }
         }
  
         if($already2 -ne "True"){
            $base2 = [PSCustomObject]@{
                User = $user
                Success = 0
                Fail = 1
            }
            $array += $base2 
          }

     $fail++
     }
   
}

# Printing the results

Write-Host "There are $success successful logins in the file"
Write-Host "There are $fail failed logins in the file"

"-------------------------------------------------------"

Write-Host "Here is the list of failed percentages: "

foreach ($row in $array){
    if($row.Fail -ne 0){
    $userio = $row.User
    $percentage = ($row.Fail / ($row.Fail + $row.Success)) * 100
    Write-Host "$userio with $percentage %"
    }
}

"-----------------------------------------------------------"

$arraysorted = $array | Sort-Object -Property Fail -Descending
$arraysorted








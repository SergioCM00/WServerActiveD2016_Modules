<#
  .SYNOPSIS
  The file create users in Active Directory based in a csv file

  .DESCRIPTION
  The Exercise 1.ps1 script obtain the users from the users.csv file, after that he create
  the user avoiding the duplicate users, and assign him/her a specific role in the system

  .EXAMPLE
    PS> .\Exercise 1.ps1 -Path "C:\SHARES\IT\users.csv"

#>



#Assigning the mandatory parameter

Param (
    [Parameter(Mandatory=$false)]
    [string]$Path
)

while (-not $Path) {
    Write-Host "Please enter the path to a CSV file:"
    $Path = Read-Host
}

cls

Import-Module -Name ActiveDirectory

# The following method changes the characters from the swedish alphabet to the international one

function Change-Characters {
    param (
        [string]$text
    )

    $swedish = @("å", "ä", "ö", "Å", "Ä", "Ö")
    $internationals = @("a", "a", "o", "A", "A", "O")
    
    for ($i = 0; $i -lt $swedish.Length; $i++) {
        $text = $text.Replace($swedish[$i], $internationals[$i])
    }
    
    return $text
}


#Import the data and going thought it with the foreach

$users = Import-Csv -Path $Path -Delimiter ";" -Encoding UTF7
foreach ($user in $users){

    $namesur = $user.Name.Split(" ")
    $nameuser = $namesur[0].Substring(0,2).ToLower() + $namesur[1].Substring(0,2).ToLower()
    $password =  $user.Department.Substring(0,2) + [string](Get-Random -Maximum 50000 -Minimum 10000) + "///?" + [string](Get-Random -Maximum 50000 -Minimum 10000) + $user.Email.Substring(0,5).ToUpper()
    $passwordS = ConvertTo-SecureString($password) -AsPlainText -Force
    $depart = $user.Department

    # With this method I check that there wont be repeated users in the system

    $valid = $false
    $nameori = Change-Characters -text $nameuser
    do{
    $found = $false
    $alreadyin = Get-ADUser -Filter *
    foreach ($searched in $alreadyin){
      if($searched.SamAccountName -eq $nameori){
        $nameori = $searched.SamAccountName + "1"
        $found = $true
      }
    
    }
       if($found -eq $false){
         $valid = $true
       }

   
    
    }while ($valid -ne $true)
    
    if($user.Department.Equals("IT")){
        
        New-ADUser -Path "OU=IT,DC=script,DC=local" -Name $nameori -Department $user.Department -Description $user.Description -AccountPassword $passwordS -EmailAddress $user.Email -GivenName $namesur[0] -Surname $namesur[1] -ChangePasswordAtLogon $true -Enabled $true -UserPrincipalName $nameori
        Add-ADGroupMember "IT" -Members $nameori
    
        }elseif($user.Department.Equals("RND")){

        New-ADUser -Path "OU=RnD,DC=script,DC=local" -Name $nameori -Department $user.Department -Description $user.Description -AccountPassword $passwordS -EmailAddress $user.Email -GivenName $namesur[0] -Surname $namesur[1] -ChangePasswordAtLogon $true -Enabled $true -UserPrincipalName $nameori
        Add-ADGroupMember "RnD" -Members $nameori

    
            }elseif($user.Department.Equals("Sales")){

            New-ADUser -Path "OU=Sales,DC=script,DC=local" -Name $nameori -Department $user.Department -Description $user.Description -AccountPassword $passwordS -EmailAddress $user.Email -GivenName $namesur[0] -Surname $namesur[1] -ChangePasswordAtLogon $true -Enabled $true -UserPrincipalName $nameori
            Add-ADGroupMember "SALES" -Members $nameori
            
                }elseif($user.Department.Equals("Finance")){

                New-ADUser -Path "OU=Finance,DC=script,DC=local" -Name $nameori -Department $user.Department -Description $user.Description -AccountPassword $passwordS -EmailAddress $user.Email -GivenName $namesur[0] -Surname $namesur[1] -ChangePasswordAtLogon $true -Enabled $true -UserPrincipalName $nameori
                Add-ADGroupMember "Finance" -Members $nameori
                }else{
                    
                New-ADUser -Name $nameori -Department $user.Department -Description $user.Description -AccountPassword $passwordS -EmailAddress $user.Email -GivenName $namesur[0] -Surname $namesur[1] -ChangePasswordAtLogon $true -Enabled $true -UserPrincipalName $nameori
                Add-ADGroupMember "Executives" -Members $nameori
                    }

    # After adding the users, with the following command we create the password files.

    New-Item "C:\Users\Administrator\Desktop\Assigment\LoginFiles\$nameori.txt"
    Set-Content "C:\Users\Administrator\Desktop\Assigment\LoginFiles\$nameori.txt" "User: $nameori  Password: $password"

    $exit = $true





}



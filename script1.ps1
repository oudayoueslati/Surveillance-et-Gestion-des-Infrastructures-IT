 $pcNames = @("D951059","D951166","D951107","DMS04515","D951178","DMS04577","D976090","D951598","D951602","D951216","D951023","D976097","D951599","D951601","D951588","D951600","D976092","DMS04629","DMS04584","D951596","DMS04633","D976091","DMS04702","D951218","DMS04698","D951587","D976034","D951201","DMS04679","DMS04403","DMS04688","D976093","D951097","DMS04581","D951028","D951102","D976098","D976099","DMS04579","DMS04693","D951238","DMS04626","D951185","D951101","D951111","D951207","D951105","D951172")

 function Check-RAMStatus {
     param ( [string]$pcName )
     try {
         Write-Host "Checking RAM for PC: $pcName" -ForegroundColor Yellow
         $ram = Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $pcName -ErrorAction Stop

         if ($ram) {
             $totalRAM = ($ram.Capacity | Measure-Object -Sum).Sum / 1GB
             Write-Host "Total RAM detected: $totalRAM GB" -ForegroundColor Green
             return [pscustomobject]@{
                 PCName = $pcName
                 RAMStatus = "Detected"
                 TotalRAM = "$totalRAM GB"
             }
         } else {
             Write-Host "No RAM detected for PC: $pcName" -ForegroundColor Red
             return [pscustomobject]@{
                 PCName = $pcName
                 RAMStatus = "Not Detected"
                 TotalRAM = "N/A"
             }
         }
     } catch {
         Write-Host("Error checking RAM for PC {0}: {1}" -f $pcName, $_.Exception.Message) -ForegroundColor Red
         return [pscustomobject]@{
             PCName = $pcName
             RAMStatus = "Error"
             ErrorMessage = $_.Exception.Message
         }
     }
 }

 function Check-Disks {
     param ( [string]$pcName )
     try {
         Write-Host "Checking Disks for PC: $pcName" -ForegroundColor Yellow
         $disks = Get-WmiObject -Class Win32_DiskDrive -ComputerName $pcName -ErrorAction Stop

         if ($disks) {
             return $disks | ForEach-Object {
                 [pscustomobject]@{
                     DiskModel = $_.Model
                     DiskStatus = $_.Status
                 }
             }
         } else {
             Write-Host "No Disks detected for PC: $pcName" -ForegroundColor Red
             return @()
         }
     } catch {
         Write-Host("Error checking Disks for PC {0}: {1}" -f $pcName, $_.Exception.Message) -ForegroundColor Red
         return @()
     }
 }

 function Check-PowerSupply {
     param ( [string]$pcName )
     try {
         Write-Host "Checking Power Supply for PC: $pcName" -ForegroundColor Yellow
         $powerSupply = Get-WmiObject -Class Win32_Battery -ComputerName $pcName -ErrorAction Stop

         if ($powerSupply) {
             return [pscustomobject]@{
                 PowerSupplyStatus = $powerSupply.Status

             }
         } else {
             Write-Host "No Power Supply detected for PC: $pcName" -ForegroundColor Red
             return [pscustomobject]@{
                 PowerSupplyStatus = "Not Detected"

             }
         }
     } catch {
         Write-Host("Error checking Power Supply for PC {0}: {1}" -f $pcName, $_.Exception.Message) -ForegroundColor Red
         return [pscustomobject]@{
             PowerSupplyStatus = "Error"

         }
     }
 }

 function Check-Monitors {
     param ( [string]$pcName )
     try {
         Write-Host "Checking Monitors for PC: $pcName" -ForegroundColor Yellow
         $monitors = Get-WmiObject -Class Win32_DesktopMonitor -ComputerName $pcName -ErrorAction Stop

         if ($monitors) {
             return $monitors | ForEach-Object {
                 [pscustomobject]@{
                     MonitorDescription = $_.Description
                     MonitorStatus = $_.Status
                 }
             }
         } else {
             Write-Host "No Monitors detected for PC: $pcName" -ForegroundColor Red
             return @()
         }
     } catch {
         Write-Host("Error checking Monitors for PC {0}: {1}" -f $pcName, $_.Exception.Message) -ForegroundColor Red
         return @()
     }
 }

 function Check-TemperatureSensors {
     param ( [string]$pcName )
     try {
         Write-Host "Checking Temperature Sensors for PC: $pcName" -ForegroundColor Yellow
         $sensors = Get-WmiObject -Class MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -ComputerName $pcName -ErrorAction Stop

         if ($sensors) {
             return $sensors | ForEach-Object {
                 [pscustomobject]@{
                     SensorName = $_.InstanceName
                     CurrentTemperature = ($_.CurrentTemperature / 10) - 273.15
                 }
             }
         } else {
             Write-Host "No Temperature Sensors detected for PC: $pcName" -ForegroundColor Red
             return @()
         }
     } catch {
         Write-Host("Error checking Temperature Sensors for PC {0}: {1}" -f $pcName, $_.Exception.Message) -ForegroundColor Red
         return @()
     }
 }

 function Check-PCState {
     param ( [string]$pcName )
     try {
         Write-Host "Checking PC: $pcName" -ForegroundColor Yellow

         
         $ramStatus = Check-RAMStatus -pcName $pcName
         $disks = Check-Disks -pcName $pcName
         $powerSupply = Check-PowerSupply -pcName $pcName
         $monitors = Check-Monitors -pcName $pcName
         $sensors = Check-TemperatureSensors -pcName $pcName

         $ip = Resolve-DnsName -Name $pcName -ErrorAction Stop | Where-Object { $_.QueryType -eq 'A' } | Select-Object -ExpandProperty IPAddress
         if ($ip ) {
             Write-Host "Resolved IP: $ip" -ForegroundColor Cyan
             if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
                 Write-Host "PC $pcName ($ip) is online. Fetching WMI information..." -ForegroundColor Green
                 $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ip -ErrorAction Stop
                 $cs = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ip -ErrorAction Stop
                 $bios = Get-WmiObject -Class Win32_BIOS -ComputerName $ip -ErrorAction Stop
                 $network = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled ='True'" -ComputerName $ip -ErrorAction Stop

                 return [pscustomobject]@{
                     PCName = $pcName
                     IP = $ip
                     Status = "Online"
                     OS = $os.Caption
                     LastBootUpTime = $os.LastBootUpTime
                     Model = $cs.Model
                     BIOSVersion = $bios.SMBIOSBIOSVersion
                     MACAddress = $network.MACAddress
                     WorkstationUserName = $cs.UserName
                     RAMStatus = $ramStatus.RAMStatus
                     TotalRAM = $ramStatus.TotalRAM
                     Disks = $disks
                     PowerSupply = $powerSupply.PowerSupplyStatus

                     Monitors = $monitors
                     TemperatureSensors = $sensors
                 }
             } else {
                 Write-Host "PC $pcName ($ip) is offline." -ForegroundColor Red
                 return [pscustomobject]@{
                     PCName = $pcName
                     IP = $ip
                     Status = "Offline"
                     WorkstationUserName = "Non disponible"
                     Reason = "No ping response"
                     DownTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                     RAMStatus = $ramStatus.RAMStatus
                     TotalRAM = $ramStatus.TotalRAM
                     Disks = $disks
                     PowerSupply = $powerSupply.PowerSupplyStatus

                     Monitors = $monitors
                     TemperatureSensors = $sensors
                 }
             }
         } else {
             Write-Host "Unable to resolve IP address for $pcName" -ForegroundColor Red
             return [pscustomobject]@{
                 PCName = $pcName
                 IP = "Unresolved"
                 Status = "Offline"
                 WorkstationUserName = "Non disponible"
                 Reason = "Unable to resolve IP address"
                 DownTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                 RAMStatus = $ramStatus.RAMStatus
                 TotalRAM = $ramStatus.TotalRAM
                 Disks = $disks
                 PowerSupply = $powerSupply.PowerSupplyStatus

                 Monitors = $monitors
                 TemperatureSensors = $sensors
             }
         }
     } catch {
         Write-Host("Error checking PC {0}: {1}" -f $pcName, $_.Exception.Message) -ForegroundColor Red
         return [pscustomobject]@{
             PCName = $pcName
             IP = "Error"
             Status = "Offline"
             WorkstationUserName = "Non disponible"
             Reason = "Error: $($_.Exception.Message)"
             DownTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
             RAMStatus = $ramStatus.RAMStatus
             TotalRAM = $ramStatus.TotalRAM
             Disks = $disks
             PowerSupply = $powerSupply.PowerSupplyStatus
             Monitors = $monitors
             TemperatureSensors = $sensors
         }
     }
 }

 $goodStatePCs = @()
 $badStatePCs = @()

 foreach ($pcName in $pcNames) {
     Write-Host "Starting check for $pcName" -ForegroundColor Blue
     $pcState = Check-PCState -pcName $pcName
     if ($pcState.Status -eq "Online") {
         $goodStatePCs += $pcState
     } else {
         $badStatePCs += $pcState
     }
 }

 Write-Host "PCs in good condition:" -ForegroundColor Green
 $goodStatePCs | Out-GridView -Title "PCs en Bon Etat"
 Write-Host "Crashed PCs: " -ForegroundColor Red
 $badStatePCs | Out-GridView -Title "PCs en Panne"

 if ($badStatePCs.Count -gt 0) {
     Add-Type -AssemblyName System.Windows.Forms
     $message = "Il y a des PCs en panne: n"
     foreach ($pc in $badStatePCs) {
         $message += "nPC: $($pc.PCName)nIP: $($pc.IP)nRaison: $($pc.Reason)nDownTime: $($pc.DownTime)n"
     }
     [System.Windows.Forms.MessageBox]::Show($message, "Alerte de panne", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
 }

 $desktopPath = [Environment]::GetFolderPath("Desktop")
 $goodStateCsvFileName = "good_pc_status.csv"
 $badStateCsvFileName = "bad_pc_status.csv"

 $goodStateCsvFilePath = Join-Path -Path $desktopPath -ChildPath $goodStateCsvFileName
 $badStateCsvFilePath = Join-Path -Path $desktopPath -ChildPath $badStateCsvFileName

 Write-Host "Good State CSV File Path: $goodStateCsvFilePath" -ForegroundColor Cyan
 Write-Host "Bad State CSV File Path: $badStateCsvFilePath" -ForegroundColor Cyan

 if ($badStatePCs.Count -gt 0) {
     try {
         Write-Host "Exporting bad PCs data to CSV..." -ForegroundColor Green
         $badStatePCs | Export-Csv -Path $badStateCsvFilePath -NoTypeInformation -Encoding UTF8
         Write-Host "Bad PCs data exported to $badStateCsvFilePath" -ForegroundColor Green
     } catch {
         Write-host ("Error exporting bad PCs data to CSV: {0}" -f $_.Exception.Message) -ForegroundColor Red
     }
 } else {
     Write-Host "No bad state PCs found. No data to export." -ForegroundColor Red
 }

 $goodStateJsonPath = "C:\Xampp\htdocs\pc_status\goodStatePCs.json"
 $badStateJsonPath = "C:\Xampp\htdocs\pc_status\badStatePCs.json"

 $goodStatePCs | ConvertTo-Json | Out-File -FilePath $goodStateJsonPath -Encoding utf8
 $badStatePCs | ConvertTo-Json | Out-File -FilePath $badStateJsonPath -Encoding utf8

 if (Test-Path $goodStateJsonPath) {
     Write-Output "Le fichier goodStatePCs.json a été créé avec succès."
 } else {
     Write-Output "Erreur: le fichier goodStatePCs.json n'a pas été créé."
 }


 if (Test-Path $badStateJsonPath) {
     Write-Output "Le fichier badStatePCs.json a été créé avec succès."
 } else {
     Write-Output "Erreur: le fichier badStatePCs.json n'a pas été créé."
 }
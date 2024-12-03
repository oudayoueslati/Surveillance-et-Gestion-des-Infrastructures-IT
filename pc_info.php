<?php

header('Content-Type: text/html; charset=utf-8');

$jsonFiles = ["goodStatePCs.json", "badStatePCs.json"];
$pcFound = false;

foreach ($jsonFiles as $jsonFilePath) {
    if (!file_exists($jsonFilePath)) {
        continue; 
    }

    $data = file_get_contents($jsonFilePath);
    if ($data === false) {
        continue; 
    }

    if (substr($data, 0, 3) === "\xEF\xBB\xBF") {
        $data = substr($data, 3);
    }

    if (!mb_check_encoding($data, 'UTF-8')) {
        $data = mb_convert_encoding($data, 'UTF-8', 'auto');
    }

    $pcs = json_decode($data, true);

    if (json_last_error() !== JSON_ERROR_NONE) {
        continue; 
    }

    if (!isset($_GET['name']) || empty(trim($_GET['name']))) {
        echo "<p>Nom du PC non spécifié.</p>";
        exit;
    }

    $pcName = trim($_GET['name']);

    foreach ($pcs as $pc) {
        if (isset($pc['PCName']) && strtolower($pc['PCName']) == strtolower($pcName)) {
            $pcFound = true;

            echo "<style>
                .table-container {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 50%;
                }
                table {
                    width: 80%;
                    border-collapse: collapse;
                    margin: 0 auto;
                    border: 1px solid #ddd;
                    background-color: #f9f9f9;
                    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                    height: 50%;
                }
                th, td {
                    padding: 12px;
                    text-align: left;
                    border-bottom: 1px solid #ddd;
                }
                th {
                    background-color: #f2f2f2;
                }
                tr:hover {
                    background-color: #f1f1f1;
                }
                .pc-container {
                    width: 100%;
                }
            </style>";

            echo "<div class='table-container'>";
            echo "<table>";
            echo "<tr>";

            if (basename($jsonFilePath) == "goodStatePCs.json") {
                echo "<th>PC Name</th>";
                echo "<th>IP Address</th>";
                echo "<th>Status</th>";
                echo "<th>Operating System</th>";
                echo "<th>Last Boot Up Time</th>";
                echo "<th>Model</th>";
                echo "<th>BIOS Version</th>";
                echo "<th>MAC Address</th>";
                echo "<th>WorkstationUserName</th>";
                echo "<th>RAMStatus</th>";
                echo "<th>TotalRAM</th>";
                echo "<th>Disks</th>";
                echo "<th>PowerSupply</th>";
                echo "<th>Monitors</th>";
                echo "<th>TemperatureSensors</th>";
            } else if (basename($jsonFilePath) == "badStatePCs.json") {
                echo "<th>PC Name</th>";
                echo "<th>IP Address</th>";
                echo "<th>Status</th>";
                echo "<th>WorkstationUserName</th>";
                echo "<th>Reason</th>";
                echo "<th>Down Time</th>";
                echo "<th>RAMStatus</th>";
                echo "<th>TotalRAM</th>";
                echo "<th>Disks</th>";
                echo "<th>PowerSupply</th>";
                echo "<th>Monitors</th>";
                echo "<th>TemperatureSensors</th>";
            }
            echo "</tr>";

            echo "<tr>";
            echo "<td>" . htmlspecialchars($pc['PCName']) . "</td>";
            echo "<td>" . htmlspecialchars($pc['IP']) . "</td>";
            echo "<td>" . htmlspecialchars($pc['Status']) . "</td>";

            if (basename($jsonFilePath) == "goodStatePCs.json") {
                echo "<td>" . htmlspecialchars($pc['OS']) . "</td>";
                echo "<td>" . htmlspecialchars($pc['LastBootUpTime']) . "</td>";
                echo "<td>" . htmlspecialchars($pc['Model']) . "</td>";
                echo "<td>" . htmlspecialchars($pc['BIOSVersion']) . "</td>";
                echo "<td>";
                if (is_array($pc['MACAddress'])) {
                    foreach ($pc['MACAddress'] as $mac) {
                        echo htmlspecialchars($mac) . "<br>";
                    }
                } else {
                    echo htmlspecialchars($pc['MACAddress']);
                }
                echo "</td>";
                echo "<td>" . htmlspecialchars($pc['WorkstationUserName']) . "</td>";
                echo "<td>" . htmlspecialchars($pc['RAMStatus']) . "</td>";
                echo "<td>" . htmlspecialchars($pc['TotalRAM']) . "</td>";
                if (is_array($pc['Disks'])) {
                    echo "<td>";
                    echo "Model: " . htmlspecialchars($pc['Disks']['DiskModel']) . "<br>";
                    echo "Status: " . htmlspecialchars($pc['Disks']['DiskStatus']);
                    echo "</td>";
                } else {
                    echo "<td>" . htmlspecialchars($pc['Disks']) . "</td>";
                }
            
                echo "<td>" . htmlspecialchars($pc['PowerSupply']) . "</td>";
                if (is_array($pc['Monitors'])) {
                    echo "<td>";
                    echo "Description: " . htmlspecialchars($pc['Monitors']['MonitorDescription']) . "<br>";
                    echo "Status: " . htmlspecialchars($pc['Monitors']['MonitorStatus']);
                    echo "</td>";
                } else {
                    echo "<td>" . htmlspecialchars($pc['Monitors']) . "</td>";
                }
                echo "<td>";
if (is_array($pc['TemperatureSensors'])) {
    if (isset($pc['TemperatureSensors'][0]) && is_string($pc['TemperatureSensors'][0])) {
        
        foreach ($pc['TemperatureSensors'] as $sensor) {
            echo htmlspecialchars($sensor) . "<br>";
        }
    } else {
        
        foreach ($pc['TemperatureSensors'] as $sensor) {
            if (is_array($sensor)) {
                echo "Sensor: " . htmlspecialchars($sensor['SensorName']) . "<br>";
                echo "Temperature: " . htmlspecialchars($sensor['CurrentTemperature']) . "°C<br>";
            } else {
                
                echo "Sensor: " . htmlspecialchars($pc['TemperatureSensors']['SensorName']) . "<br>";
                echo "Temperature: " . htmlspecialchars($pc['TemperatureSensors']['CurrentTemperature']) . "°C<br>";
            }
        }
    }
} elseif (is_string($pc['TemperatureSensors'])) {
    
    echo htmlspecialchars($pc['TemperatureSensors']);
} else {
    echo "No data";
}
echo "</td>";

            } else if (basename($jsonFilePath) == "badStatePCs.json") {
                echo "<td>" . htmlspecialchars($pc['WorkstationUserName']) . "</td>";
                echo "<td>" . htmlspecialchars($pc['Reason']) . "</td>";
                echo "<td>" . htmlspecialchars($pc['DownTime']) . "</td>";
                echo "<td>" . htmlspecialchars($pc['RAMStatus']) . "</td>";
                echo "<td>" . htmlspecialchars($pc['TotalRAM']) . "</td>";
                if (is_array($pc['Disks'])) {
                    echo "<td>";
                    echo "Model: " . htmlspecialchars($pc['Disks']['DiskModel']) . "<br>";
                    echo "Status: " . htmlspecialchars($pc['Disks']['DiskStatus']);
                    echo "</td>";
                } else {
                    echo "<td>" . htmlspecialchars($pc['Disks']) . "</td>";
                }
                echo "<td>" . htmlspecialchars($pc['PowerSupply']) . "</td>";
                if (is_array($pc['Monitors'])) {
                    echo "<td>";
                    echo "Description: " . htmlspecialchars($pc['Monitors']['MonitorDescription']) . "<br>";
                    echo "Status: " . htmlspecialchars($pc['Monitors']['MonitorStatus']);
                    echo "</td>";
                } else {
                    echo "<td>" . htmlspecialchars($pc['Monitors']) . "</td>";
                }
                echo "<td>";
if (is_array($pc['TemperatureSensors'])) {
    if (isset($pc['TemperatureSensors'][0]) && is_string($pc['TemperatureSensors'][0])) {
        
        foreach ($pc['TemperatureSensors'] as $sensor) {
            echo htmlspecialchars($sensor) . "<br>";
        }
    } else {
        
        foreach ($pc['TemperatureSensors'] as $sensor) {
            if (is_array($sensor)) {
                echo "Sensor: " . htmlspecialchars($sensor['SensorName']) . "<br>";
                echo "Temperature: " . htmlspecialchars($sensor['CurrentTemperature']) . "°C<br>";
            } else {
                
                echo "Sensor: " . htmlspecialchars($pc['TemperatureSensors']['SensorName']) . "<br>";
                echo "Temperature: " . htmlspecialchars($pc['TemperatureSensors']['CurrentTemperature']) . "°C<br>";
            }
        }
    }
} elseif (is_string($pc['TemperatureSensors'])) {
    
    echo htmlspecialchars($pc['TemperatureSensors']);
} else {
    echo "No data";
}
echo "</td>";

            }

            echo "</tr>";
            echo "</table>";
            echo "</div>";
            break 2; 
        }
    }
}

if (!$pcFound) {
    echo "<div class='table-container'>";
    echo "<table>";
    echo "<tr><td colspan='8'>Aucune information trouvée pour ce PC.</td></tr>";
    echo "</table>";
    echo "</div>";
}
?>

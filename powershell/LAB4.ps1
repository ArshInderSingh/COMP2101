function get-hardwareinfo {
Write-Host "System Hardware Description:"
get-CimInstance -ClassName win32_computersystem | fl
}

function get-osdetails {
Write-Host "operating system description:"
get-CimInstance -ClassName win32_operatingsystem | fl Name, Version
}

function get-processor {
Write-Host "Processor Info:"
get-wmiObject -class Win32_Processor | fl Description, MaxClockSpeed, NumberOfCores, @{n="L1CacheSize";e={switch($_.L1CacheSize){$null{$state="data unavailable"}};$state}}, L2CacheSize,
L3CacheSize
}

function get-memories {
Write-Host "RAM INFORMATION:"
$capacityINIT = 0
get-wmiObject -class Win32_Physicalmemory |
foreach {
new-object -TypeName psobject -Property @{
Manufacturer = $_.manufacturer
Description = $_.Description
"Size(GB)" = $_.capacity/1gb
Bank = $_.banklabel
Slot = $_.devicelocator
}
$capacityINIT += $_.capacity/1gb
} |
format-table -auto Manufacturer, Description, "Size(GB)", Bank, Slot
"Total RAM: ${capacityINIT}GB"
}

function get-mydisks {
Write-Host "Disks Info:"
Get-WmiObject -CLASS Win32_DiskDrive |
? DeviceID -ne $NULL |
foreach {
        $drive = $_
        $drive.GetRelated("Win32_DiskPartition") |
            foreach {$logicaldisk = $_.GetRelated("win32_LogicalDisk");
            if($logicaldisk.size) {
                new-object -TypeName PSobject -Property @{
                Manufacturer = $drive.Manufacturer
                DriveLetter = $logicaldisk.DeviceID
                Model = $drive.Model
                Size = [string]($logicaldisk.size/1gb -as [int])+"GB"
                Free =[String]((($logicaldisk.freespace / $logicaldisk.size) * 100) -as [int]) + "%"
                FreeSpace =[String]($logicaldisk.freespace / 1gb -as [int]) + "GB"
} |ft -Auto Manufacturer, model, size, Free, FreeSpace
}
}
}
}

function get-networkdetails {
Write-Host "Adapter Info:"
get-ciminstance win32_networkadapterconfiguration |Where-Object {$_.ipenabled -eq "True" } |
ft Description, Index, IPAddress, IPSubnet,
@{n="DNSDomain";
e={switch($_.DNSServerSearchOrder)
{$null
    {$state="data unavailable";$state}
};
if($null -ne $_.DNSDomain)
    {$_.DNSDomain}
  }
},
@{n="DNSServerSearchOrder";
e={switch($_.DNSServerSearchOrder)
{$null{
    $state="data unavailable";
    $state
    }
};
    if($null -ne $_.DNSServerSearchOrder)
    {$_.DNSServerSearchOrder}
    }
  }
}

function get-gpu {
Write-Host "Graphics info:"
$HorizontalDimm=(get-wmiobject -class win32_videocontroller).CurrentHorizontalResolution -as [string]
$VerticalDimm=(get-wmiobject Win32_Videocontroller).CurrentVerticalresolution -as [String]
$Bit=(get-wmiobject -class win32_videocontroller).CurrentBitsPerPixel -as [String]
$sum= $HorizontalDimm + " x " + $VerticalDimm + " and " + $Bit + " bit"
get-wmiobject win32_videocontroller|
fl @{n="Video Card Vendor"; e={$_.AdapterCompatibility}}, Description, @{n="Resolution"; e={$sum -as [string]}}
}

get-hardwareinfo
get-osdetails
get-processor
get-memories
get-mydisks
get-networkdetails
get-gpu

############################################################################################
##
## Get-DiskInfo
##
## by Steven Duong
##
############################################################################################

<#

.SYNOPSIS

Prints disk drive and volume information such as model name, serial number, and Bitlocker encryption status.

.EXAMPLE

PS > Get-DiskInfo

#>


# Return information about physical disks
echo "#############################################################"
echo "Physical Disks"
echo "#############################################################"

$physical = Get-CimInstance Win32_DiskDrive

if ($physical.Length -eq $NULL) {
    echo ("DeviceID=" + $physical.DeviceID)
    echo ("InterfaceType=" + $physical.InterfaceType)
    echo ("MediaType=" + $physical.MediaType)
    echo ("Model=" + $physical.Model)
    echo ("SerialNumber=" + $physical.SerialNumber)
    echo ("PNPDeviceID=" + $physical.PNPDeviceID)
    echo ""
} else {
    for ($i=0; $i -lt $physical.Length; $i++) {
        echo ("DeviceID=" + $physical.DeviceID[$i])
        echo ("InterfaceType=" + $physical.InterfaceType[$i])
        echo ("MediaType=" + $physical.MediaType[$i])
        echo ("Model=" + $physical.Model[$i])
        echo ("SerialNumber=" + $physical.SerialNumber[$i])
        echo ("PNPDeviceID=" + $physical.PNPDeviceID[$i])
        echo ""
    }
}

# Return information about partitions
echo "#############################################################"
echo "Partitions"
echo "#############################################################"

$partition = Get-Partition | where DriveLetter -Match [A-Z]

if ($partition.Length -eq $NULL) {
        echo ("PartitionNumber=" + $partition.PartitionNumber)
        echo ("DriveLetter=" + $partition.DriveLetter)
        echo ("Size=" + $partition.Size)
        echo ("UniqueId=" + $partition.UniqueId)
        echo ("AccessPaths=" + $partition.AccessPaths)
        echo ("DiskId=" + $partition.DiskId)
} else {
    for ($i=0; $i -lt $partition.Length; $i++) {
        echo ("PartitionNumber=" + $partition.PartitionNumber[$i])
        echo ("DriveLetter=" + $partition.DriveLetter[$i])
        echo ("Size=" + $partition.Size[$i])
        echo ("UniqueId=" + $partition.UniqueId[$i])
        echo ("AccessPaths=" + $partition.AccessPaths[$i])
        echo ("DiskId=" + $partition.DiskId[$i])
        echo ""
    }
}

# Return information about volumes
echo "#############################################################"
echo "Volumes"
echo "#############################################################"

$volume = Get-Volume | where DriveLetter -Match [A-Z]

if ($volume.Length -eq $NULL) {
    echo ("DriveLetter=" + $volume.DriveLetter)
    echo ("DriveType=" + $volume.DriveType)
    echo ("Size=" + $volume.Size)
    echo ("UniqueId=" + $volume.UniqueId) 
    echo ("Path=" + $volume.Path)
    echo ("ObjectId=" + $volume.ObjectId)
} else {
    for ($i=0; $i -lt $volume.Length; $i++) {
        echo ("DriveLetter=" + $volume.DriveLetter[$i])
        echo ("DriveType=" + $volume.DriveType[$i])
        echo ("Size=" + $volume.Size[$i])
        echo ("UniqueId=" + $volume.UniqueId[$i]) 
        echo ("Path=" + $volume.Path[$i])
        echo ("ObjectId=" + $volume.ObjectId[$i])
        echo ""
    }
}

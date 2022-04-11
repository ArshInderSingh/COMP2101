Param ( [switch]$System,[switch]$Disks,[switch]$Network)

import-module arshinder

if ($System -eq $false -and $Disks -eq $false -and $Network -eq $false) {
   write-host "Script starts here."
   write-host "Add an arguments to get specific results. Press ctrl+space to get the options"
   write-host "-----------------------------------------------------------------------------"
   arshinder-System; arshinder-Disks; arshinder-Network;
   write-host "Script finishes here."
} else{
   if ($System) {
       arshinder-System   }
   if ($Disks) {
       arshinder-Disks    }
   if ($Network) {
       arshinder-Network  }
}
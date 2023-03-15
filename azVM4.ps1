# Connect to Azure Account
Connect-AzAccount
 
# Create Report Array
$report = @()
 
# Record all the subscriptions in a Text file  
$SubscriptionIds = ""
Foreach ($SubscriptionId in $SubscriptionIds) 
{
$reportName = "VM-Details.csv"
 
# Select the subscription  
Select-AzSubscription $subscriptionId
  
# Get all the VMs from the selected subscription
$vms = Get-AzVM
  
# Get all the Public IP Address
$publicIps = Get-AzPublicIpAddress
  
# Get all the Network Interfaces
$nics = Get-AzNetworkInterface | ?{ $_.VirtualMachine -NE $null} 
foreach ($nic in $nics) { 
    # Creating the Report Header we have taken maxium 5 disks but you can extend it based on your need
    $ReportDetails = "" | Select VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, NicName, ApplicationSecurityGroup, OSDiskName,OSDiskTier, OSDiskCaching, OSDiskSize, DataDiskCount, DataDisk1Name, DataDisk1Tier, DataDisk1Size,DataDisk1Caching, DataDisk2Name,DataDisk2Tier, DataDisk2Size,DataDisk2Caching, DataDisk3Name, DataDisk3Tier, DataDisk3Size,DataDisk3Caching,  DataDisk4Name, DataDisk4Tier, DataDisk4Size,DataDisk4Caching, DataDisk5Name,DataDisk5Tier, DataDisk5Size,DataDisk5Caching
   #Get VM IDs
    $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id 
    foreach($publicIp in $publicIps) { 
        if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
            $ReportDetails.PublicIPAddress = $publicIp.ipaddress
            } 
        } 
        $ReportDetails.OsType = $vm.StorageProfile.OsDisk.OsType 
        $ReportDetails.VMName = $vm.Name 
        $ReportDetails.ResourceGroupName = $vm.ResourceGroupName 
        $ReportDetails.Region = $vm.Location 
        $ReportDetails.VmSize = $vm.HardwareProfile.VmSize
        $ReportDetails.VirtualNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
        $ReportDetails.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1] 
        $ReportDetails.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress 
        $ReportDetails.NicName = $nic.Name 
        $ReportDetails.ApplicationSecurityGroup = $nic.IpConfigurations.ApplicationSecurityGroups.Id 
        $ReportDetails.OSDiskName = $vm.StorageProfile.OsDisk.Name 
        $ReportDetails.OSDiskSize = $vm.StorageProfile.OsDisk.DiskSizeGB
        $ReportDetails.OSDiskCaching = $vm.StorageProfile.OsDisk.Caching
        $ReportDetails.DataDiskCount = $vm.StorageProfile.DataDisks.count
        $ReportDetails.OSDiskTier = ((Get-AzDisk -ResourceGroupName $vm.ResourceGroupName  -DiskName $vm.OsDisk.Name).Tier | Out-String).Trim()
 
        if ($vm.StorageProfile.DataDisks.count -gt 0)
        {
         $disks= $vm.StorageProfile.DataDisks
     foreach($disk in $disks)
        {
        If ($disk.Lun -eq 0)
        {
       $ReportDetails.DataDisk1Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
       $ReportDetails.DataDisk1Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
       $ReportDetails.DataDisk1Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
       $ReportDetails.DataDisk1Tier = ((Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Tier | Out-String).Trim()
        }
        elseif($disk.Lun -eq 1)
        {
        $ReportDetails.DataDisk2Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
        $ReportDetails.DataDisk2Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
        $ReportDetails.DataDisk2Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
        $ReportDetails.DataDisk2Tier = ((Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Tier | Out-String).Trim()
        }
        elseif($disk.Lun -eq 2)
        {
        $ReportDetails.DataDisk3Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
        $ReportDetails.DataDisk3Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
        $ReportDetails.DataDisk3Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
        $ReportDetails.DataDisk3Tier = ((Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Tier | Out-String).Trim()
        }
        elseif($disk.Lun -eq 3)
        {
        $ReportDetails.DataDisk4Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
        $ReportDetails.DataDisk4Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
        $ReportDetails.DataDisk4Caching =$vm.StorageProfile.DataDisks[$disk.Lun].Caching 
        $ReportDetails.DataDisk4Tier = ((Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Tier | Out-String).Trim()
        }
        elseif($disk.Lun -eq 4)
        {
        $ReportDetails.DataDisk5Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
        $ReportDetails.DataDisk5Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
        $ReportDetails.DataDisk5Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
        $ReportDetails.DataDisk5Tier = ((Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Tier | Out-String).Trim()
        }
       }
        }
        $report+=$ReportDetails 
    } }
      
$report | ft -AutoSize VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, NicName, ApplicationSecurityGroup, OSDiskName, OSDiskTier, OSDiskCaching, OSDiskSize, DataDiskCount, DataDisk1Name, DataDisk1Tier, DataDisk1Size,DataDisk1Caching, DataDisk2Name,DataDisk2Tier, DataDisk2Size,DataDisk2Caching, DataDisk3Name, DataDisk3Tier, DataDisk3Size,DataDisk3Caching,  DataDisk4Name, DataDisk4Tier, DataDisk4Size,DataDisk4Caching, DataDisk5Name,DataDisk5Tier, DataDisk5Size,DataDisk5Caching
 
#Change the path based on your convenience
$report | Export-CSV  "$reportName"

#########################################################################################################
#Explanation

#1. Get all the Public IP addresses:
# The first line of the script uses the Get-AzPublicIpAddress cmdlet to retrieve all of the public IP addresses in the Azure environment. The returned IP addresses are stored in the $publicIps variable.

#2. Get all the Network Interfaces:
# The second line of the script uses the Get-AzNetworkInterface cmdlet to retrieve all the network interfaces in the Azure environment. The cmdlet is piped with a filter that only retrieves network interfaces that are associated with a virtual machine (VirtualMachine -NE $null). The resulting network interfaces are stored in the $nics variable.

#3. Loop through each Network Interface:
# A foreach loop is used to loop through each network interface in the $nics variable. In each iteration of the loop, the $nic variable will represent a single network interface.

#4. Report Header:
# A custom object is created to hold the details of each virtual machine. The object is called $ReportDetails and it includes the following properties: VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, NicName, ApplicationSecurityGroup, OSDiskName, OSDiskTier, OSDiskCaching, OSDiskSize, DataDiskCount, DataDisk1Name, DataDisk1Tier, DataDisk1Size, DataDisk1Caching, DataDisk2Name, DataDisk2Tier, DataDisk2Size, DataDisk2Caching, DataDisk3Name, DataDisk3Tier, DataDisk3Size, DataDisk3Caching, DataDisk4Name, DataDisk4Tier, DataDisk4Size, DataDisk4Caching, DataDisk5Name, DataDisk5Tier, DataDisk5Size, DataDisk5Caching. This object will be used to store the details of each virtual machine.

#5. Get Virtual Machine Details:
# The script uses the $nic.VirtualMachine.id property to get the virtual machine associated with the current network interface. The retrieved virtual machine is stored in the $vm variable.

#6. Check for Public IP:
# A foreach loop is used to loop through each public IP address stored in the $publicIps variable. The loop checks if the current public IP address is associated with the current network interface. If it is, the public IP address is added to the $ReportDetails object.

#7. Add VM Details to the Report:
# The $ReportDetails object is populated with details about the virtual machine, including its name, resource group, region, size, network configuration, operating system type, and disk configuration.

#8. Add Disk Details to the Report:
# The script uses the Get-AzDisk cmdlet to retrieve information about the virtual machine's disks, including disk name, size, caching method, and disk tier. The disk information is then added to the $ReportDetails object.

#9. The loop continues until all network interfaces have been processed.

#10. The final result is a list of virtual machines, each with its associated details stored in a $ReportDetails object.

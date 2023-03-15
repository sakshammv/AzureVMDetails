from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient
import pandas as pd

credential = DefaultAzureCredential()
compute_client = ComputeManagementClient(credential, subscription_id='5126eacd-7599-4aaf-8799-3a5e824f094c')
network_client = NetworkManagementClient(credential, subscription_id='5126eacd-7599-4aaf-8799-3a5e824f094c')
subscription_ids = ['5126eacd-7599-4aaf-8799-3a5e824f094c']

#Total number of VMs
vm_list = compute_client.virtual_machines.list_all()
total_vms = len(list(vm_list))
print(f"Total number of VMs: {total_vms}")

#Total number of Running/Stopped VMs
vm_list = compute_client.virtual_machines.list_all()
for vm in vm_list:
    array = vm.id.split("/")
    resource_group = array[4]
    vm_name = array[-1]
    statuses = compute_client.virtual_machines.instance_view(resource_group, vm_name).statuses
    status = len(statuses) >= 2 and statuses[1]

    if status and (status.code == 'PowerState/running' or status.code == 'PowerState/deallocated' or status.code == 'PowerState/stopped'):
        print(f'{vm_name} is {status.display_status}.')

for subscription_id in subscription_ids:
    report_name = "VM-Details.csv"

    # Select the subscription  
    compute_client.subscription_id = subscription_id
    network_client.subscription_id = subscription_id

    # Get all the VMs from the selected subscription
    vms = compute_client.virtual_machines.list_all()
    # Get all the Public IP Address
    public_ips = network_client.public_ip_addresses.list_all()

    # Get all the Network Interfaces
    nics = network_client.network_interfaces.list_all()
    for nic in nics:
        # Creating the Report Header we have taken maxium 5 disks but you can extend it based on your need
        report_details = {'VmName': '', 'ResourceGroupName': '', 'Region': '', 'VmSize': '', 'VirtualNetwork': '', 
                          'Subnet': '', 'PrivateIpAddress': '', 'OsType': '', 'PublicIPAddress': '', 'NicName': '', 
                          'ApplicationSecurityGroup': '', 'OSDiskName': '', 'OSDiskTier': '', 'OSDiskCaching': '', 
                          'OSDiskSize': '', 'DataDiskCount': '', 'DataDisk1Name': '', 'DataDisk1Tier': '', 
                          'DataDisk1Size': '', 'DataDisk1Caching': '', 'DataDisk2Name': '', 'DataDisk2Tier': '', 
                          'DataDisk2Size': '', 'DataDisk2Caching': '', 'DataDisk3Name': '', 'DataDisk3Tier': '', 
                          'DataDisk3Size': '', 'DataDisk3Caching': '', 'DataDisk4Name': '', 'DataDisk4Tier': '', 
                          'DataDisk4Size': '', 'DataDisk4Caching': '', 'DataDisk5Name': '', 'DataDisk5Tier': '', 
                          'DataDisk5Size': '', 'DataDisk5Caching': ''}

        # Get VM IDs
        vm_id = nic.virtual_machine.id
        vm = next((x for x in vms if x.id.casefold() == vm_id.casefold()), None)
        
        print(f"nic: {nic}")
        print(f"vm_id: {vm_id}")
        print(f"vm: {vm}")

        if vm is None:
            print(f"VM {vm_id} not found in subscription {subscription_id}")
            continue

        if vm.storage_profile is None or vm.storage_profile.os_disk is None:
            print(f"VM {vm_id} does not have an OS disk")
            continue

        report_details['OsType'] = vm.storage_profile.os_disk.os_type
        report_details['VMName'] = vm.name
        report_details['Region'] = vm.location
        report_details['VmSize'] = vm.hardware_profile.vm_size
        report_details['NicName'] = nic.name

# Create Report DataFrame
report = pd.DataFrame(columns=['VmName', 'ResourceGroupName', 'Region', 'VmSize', 'VirtualNetwork', 'Subnet','PrivateIpAddress', 'OsType', 'PublicIPAddress', 'NicName', 'ApplicationSecurityGroup','OSDiskName', 'OSDiskTier', 'OSDiskCaching', 'OSDiskSize', 'DataDiskCount','DataDisk1Name', 'DataDisk1Tier', 'DataDisk1Size', 'DataDisk1Caching', 'DataDisk2Name','DataDisk2Tier', 'DataDisk2Size', 'DataDisk2Caching', 'DataDisk3Name', 'DataDisk3Tier', 'DataDisk3Size', 'DataDisk3Caching', 'DataDisk4Name', 'DataDisk4Tier', 'DataDisk4Size', 'DataDisk4Caching', 'DataDisk5Name', 'DataDisk5Tier', 'DataDisk5Size', 'DataDisk5Caching'])

# Add report_details to the report DataFrame
report = pd.concat([report, pd.DataFrame([report_details])], ignore_index=True)

# Write the report DataFrame to a CSV file
report.to_csv('VM-Details.csv', index=False)


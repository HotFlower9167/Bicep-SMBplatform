param dateTime string = utcNow()
param location string = 'italynorth'
param RG1 string = 'RG-network'
param RG2 string = 'RG-identity'
param vmusername string = 'hotflower9167'
@secure()
param vmpassword string
var vnetname = 'vnet-customer'
var subnetname = 'snet-identity'
targetScope = 'subscription'

@description('deploy platform RGs')
resource rg01 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: RG1
  location : location
}
resource rg02 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: RG2
  location: location
}

@description('deploy the vnet')
module network 'Networking/Vnet.bicep'= {
  name: 'vnetdeploy-${dateTime}'
  scope: rg01
  params: {
    location: location
    vnetAddressPrefix: '10.94.0.0/16'
    vnetName: vnetname
    subnetAddressPrefix: '10.94.10.0/24'
    subnetName: subnetname
  }
}

@description('deploy the NSG')
module NSG 'Networking/NSG.bicep'= {
  scope: rg02
  name: 'nsgDC'
  params:{
    location: location
  }
}
@description('deploy public IP for dc01')
module PIPdc01 'Networking/PublicIP.bicep' = {
  scope: rg02
  name: 'pipdc01'
  params: {
    location: location
    pipname: 'PIP-DC01'
  }
}

@description('deploy NIC1')
module NIC1 'Networking/NIC.bicep' = {
  scope: rg02
  name: 'NIC-DC01'
  dependsOn: [network]
  params: {
    location: location
    nicName: 'NIC-DC01'
    vnetname: vnetname
    rgidentityname: rg01.name
    pipid: PIPdc01.outputs.publicIP
    nsgid: NSG.outputs.nsgId
  }
}

@description('deploy DC01')
module DC01 'DomainController/DCs.bicep' = {
  scope: rg02
  name: 'dc01-azure'
  params: {
    adminPassword: vmpassword
    adminUsername: vmusername
    imageOffer: 'WindowsServer'
    imagePublisher: 'MicrosoftWindowsServer'
    imageSku: '2022-datacenter-azure-edition-hotpatch-smalldisk'
    location: location
    nicId: NIC1.outputs.nicId
    vmName: 'DC01-Azure'
    vmSize: 'Standard_B2s'
  }
}



@description('deploy public IP for dc01')
module PIPdc02 'Networking/PublicIP.bicep' = {
  scope: rg02
  name: 'pipdc02'
  params: {
    location: location
    pipname: 'PIP-DC02'
  }
}

@description('deploy NIC2')
module NIC2 'Networking/NIC.bicep' = {
  scope: rg02
  name: 'NIC-DC02'
  dependsOn: [network]
  params: {
    location: location
    nicName: 'NIC-DC02'
    vnetname: vnetname
    rgidentityname: rg01.name
    pipid: PIPdc02.outputs.publicIP
    nsgid: NSG.outputs.nsgId
  }
}

@description('deploy DC01')
module DC02 'DomainController/DCs.bicep' = {
  scope: rg02
  name: 'dc02-azure'
  params: {
    adminPassword: vmpassword
    adminUsername: vmusername
    imageOffer: 'WindowsServer'
    imagePublisher: 'MicrosoftWindowsServer'
    imageSku: '2022-datacenter-azure-edition-hotpatch-smalldisk'
    location: location
    nicId: NIC2.outputs.nicId
    vmName: 'DC02-Azure'
    vmSize: 'Standard_B2s'
  }
}

param location string
param nicName string
param vnetname string
param rgidentityname string
param pipid string
param nsgid string
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  scope: resourceGroup(rgidentityname)
  name: vnetname
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipid
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id:nsgid
    }
  }
}

output nicId string = nic.id

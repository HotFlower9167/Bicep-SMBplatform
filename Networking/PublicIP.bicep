param pipname string
param location string

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: pipname
  location: location
  sku:{
    name: 'Basic'
  }
}

output publicIP string = publicIP.id

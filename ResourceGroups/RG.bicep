targetScope = 'subscription'
param location string
param RG1 string
param RG2 string
resource rg01 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: RG1
  location : location
}
resource rg02 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: RG2
  location: location
}
output RGnetworkID string = rg01.id
output RGidentityID string = rg02.id


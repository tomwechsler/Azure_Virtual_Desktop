targetScope = 'subscription'

@description('The location to use for deployment')
param location string

@description('The naming prefix for all resources')
param prefix string

var baseName = '${prefix}-W10-Bicep'

resource avdResourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: baseName
  location: location
}

module avdHostPool './AVDBase/main.bicep' = {
  name: baseName
  scope: avdResourceGroup
  params: {
    location: location
    baseName: baseName
  }
}


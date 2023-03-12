@description('The location to use for deployment')
param location string

@description('The root name to use for all resources')
param baseName string

@description('When the token for the host pool expires. Defaults to one day from now.')
param expirationTime string = dateTimeAdd(utcNow(), 'P1D')

resource avdHostPool 'Microsoft.DesktopVirtualization/hostPools@2022-04-01-preview' = {
  name: baseName
  location: location
  properties: {
    friendlyName: baseName
    description: 'Host pool created using Bicep'
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    maxSessionLimit: 20
    registrationInfo: {
      expirationTime: expirationTime
    }
    validationEnvironment: false
    preferredAppGroupType: 'Desktop'
  }
}

resource avdApplicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' = {
  name: '${baseName}-DAG'
  location: location
  properties: {
    friendlyName: '${baseName}-DAG'
    description: 'Application group created using Bicep'
    applicationGroupType: 'Desktop'
    hostPoolArmPath: avdHostPool.id
  }
}

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2022-04-01-preview' = {
  name: baseName
  location: location
  properties: {
    friendlyName: baseName
    description: 'Workspace created using Bicep'
    applicationGroupReferences: [
      avdApplicationGroup.id
    ]
  }
}

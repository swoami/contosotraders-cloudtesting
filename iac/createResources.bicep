/// This is a corrected version of your Bicep role assignment section with duplicated roleDefinitions removed and a shared reference used instead.

// Shared Storage Account Contributor role (only defined once)
resource storageAccountContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
}

// User-assigned managed identity for first storage account deployment
resource uistgacc_mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'DeploymentScript'
  location: resourceLocation
  tags: resourceTags
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: uistgacc
  name: guid(resourceGroup().id, uistgacc_mi.id, storageAccountContributorRole.id)
  properties: {
    roleDefinitionId: storageAccountContributorRole.id
    principalId: uistgacc_mi.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'DeploymentScript'
  location: resourceLocation
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uistgacc_mi.id}': {}
    }
  }
  dependsOn: [
    roleAssignment
  ]
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: loadTextContent('./scripts/enable-static-website.ps1')
    retentionInterval: 'PT4H'
    environmentVariables: [
      {
        name: 'ResourceGroupName'
        value: resourceGroup().name
      },
      {
        name: 'StorageAccountName'
        value: uistgacc.name
      }
    ]
  }
}

// User-assigned managed identity for second storage account deployment
resource ui2stgacc_mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'DeploymentScript2'
  location: resourceLocation
  tags: resourceTags
}

resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: ui2stgacc
  name: guid(resourceGroup().id, ui2stgacc_mi.id, storageAccountContributorRole.id)
  properties: {
    roleDefinitionId: storageAccountContributorRole.id
    principalId: ui2stgacc_mi.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript2 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'DeploymentScript2'
  location: resourceLocation
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${ui2stgacc_mi.id}': {}
    }
  }
  dependsOn: [
    roleAssignment2
  ]
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: loadTextContent('./scripts/enable-static-website.ps1')
    retentionInterval: 'PT4H'
    environmentVariables: [
      {
        name: 'ResourceGroupName'
        value: resourceGroup().name
      },
      {
        name: 'StorageAccountName'
        value: ui2stgacc.name
      }
    ]
  }
}

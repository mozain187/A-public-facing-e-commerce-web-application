param location string = resourceGroup().location
param subnetName string = 'AzureBastionSubnet'
param appServiceFQDN string 

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-07-01' ={
  name:'BastionIP'
  location:location
  properties:{
    idleTimeoutInMinutes:4
    publicIPAddressVersion:'IPv4'
    publicIPAllocationMethod:'Static'
    
  }
sku:{
  name:'Standard'
  tier:'Regional'
}
}

resource Bastion 'Microsoft.Network/bastionHosts@2024-07-01' = {
  name:'adminsToAppService'
  location:location
  properties:{
    scaleUnits:2
    dnsName:appServiceFQDN
    virtualNetwork:{
      id:resourceId('Microsoft.Network/virtualNetworks/subnets','hub-vnet',subnetName)
    }

  }

  sku:{
    name:'Standard'
  }
}

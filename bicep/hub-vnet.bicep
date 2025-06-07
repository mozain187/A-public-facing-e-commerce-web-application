param location string = resourceGroup().location
param hubVnetName string = 'hub-vnet'


resource hubVnet 'Microsoft.Network/virtualNetworks@2020-06-01' ={
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:['10.0.0.0/16']
      
  }
  subnets:[
    {
      name: 'AppGatewaySubnet'
      properties: {
        addressPrefix:'10.0.1.0/24'
        networkSecurityGroup:{
          id:appGatewayNsg.id
        }
        
      }
    }
    {
      name: 'AzureBastionSubnet'
      properties: {
        

          addressPrefix:'10.0.2.0/24'
          networkSecurityGroup:{
            id:BastionNsg.id
          }
       
      }
    }
  ]
}
}
resource ip 'Microsoft.Network/publicIPAddresses@2024-07-01' existing ={
  name:'appGateWay-ip'

}
resource  bastionIp 'Microsoft.Network/publicIPAddresses@2024-07-01' existing ={
  name:'BastionIP'

}

resource appGatewayNsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'appGateway-nsg'
  location: location
  properties: {
    securityRules:[
      {
        name:'allowHttpsIn'
        properties:{
          access:'Allow'
          direction:'Inbound'
          protocol:'Tcp'
          priority:100
          sourceAddressPrefix:'*'
          destinationAddressPrefix: ip.properties.ipAddress
          destinationPortRange:'443'
          sourcePortRange:'*'
        }

      }
      {
        name:'allowHttpsOut'
        properties:{
          access:'Allow'
          direction:'Outbound'
          protocol:'Tcp'
          priority:200
          sourceAddressPrefix:'*'
          destinationAddressPrefix: ip.properties.ipAddress
          destinationPortRange:'443'
          sourcePortRange:'*'
        }

      }
    ]
  }
}
resource BastionNsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'Bastion-nsg'
  location: location
  properties: {
    securityRules:[
      {
        name:'allowAdminsIn'
        properties:{
          access:'Allow'
          direction:'Inbound'
          protocol:'Tcp'
          priority:100
          sourceAddressPrefix:'VirtualNetwork'
          destinationAddressPrefix: bastionIp.properties.ipAddress
          destinationPortRange:'443'
          sourcePortRange:'*'
        }

      }
    ]
  }
}

output hubVnetId string = hubVnet.id
output gatewaySubnetId string = hubVnet.properties.subnets[0].id
output bastionSubnetId string = hubVnet.properties.subnets[1].id

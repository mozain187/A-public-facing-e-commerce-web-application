param location string = resourceGroup().location
param repositoryUrl string = 'https://github.com/Azure-Samples/nodejs-docs-hello-world'



resource publicIp 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: 'appGateWay-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
   
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
    name:'appservicePlan'
    location:location
    properties:{
        reserved:true
    }
    sku:{
        name:'F1'
    }
    kind:'linux'
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: 'name-of-the-app'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'node|20-lts'
    }
  }
}

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2023-12-01' = {
  parent: appService
  name: 'web'
  properties: {
    repoUrl: repositoryUrl
    branch: 'main'
    isManualIntegration: false
  }
}

resource appGateway 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: 'appGateway'
  location: location
  properties: {
    firewallPolicy:{
        id:wafPolicy.id
    }
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
     

    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'hub-vnet', 'AzureAppGatewaySubnet')
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'appGatewayFrontendPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appGatewayBackendPool'
        properties:{
            backendAddresses:[
                {
                    fqdn: appService.properties.defaultHostName
                }
            ]
        }
       
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', 'appGateway', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', 'appGateway', 'appGatewayFrontendPort')
          }
          protocol: 'Http'
        }
      }
      {
        name:'https'
        properties:{
           frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', 'appGateway', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', 'appGateway', 'appGatewayFrontendPort')
          }
          protocol: 'Https'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', 'appGateway', 'appGatewayHttpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'appGateway', 'appGatewayBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'appGateway', 'appGatewayBackendHttpSettings')
          }
        }
      }
    ]
    webApplicationFirewallConfiguration:{
        enabled:true
        firewallMode:'Prevention'
        ruleSetType:'OWASP'
        ruleSetVersion:'3.2'
       
        
    }
    
    
    redirectConfigurations:[
        {
            name:'http-to-https'
            properties:{
             targetListener:{
                id:resourceId('Microsoft.Network/applicationGateways/httpListeners', 'appGateway', 'https')

             }
            }
        }
    ]
    
    
  }
}
resource wafPolicy 'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies@2024-05-01' = {
  name: 'my-waf-policy'
  location: location
  properties: {
    policySettings: {
      state: 'Enabled'
      mode: 'Prevention'
    }
    customRules: [
      {
        name: 'BlockBadUserAgents'
        priority: 1
        ruleType: 'MatchRule'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RequestHeaders'
                selector: 'User-Agent'
              }
            ]
            operator: 'Contains'
    matchValues: [ 'sqlmap', 'curl', 'python-requests', 'wget','ZAP' ]
          }
        ]
        action: 'Block'
      }
      {
  name: 'BlockMaliciousPaths'
  priority: 20
  ruleType: 'MatchRule'
  matchConditions: [
    {
      matchVariables: [
        {
          variableName: 'RequestUri'
        }
      ]
      operator: 'Contains'
      matchValues: [
        '/admin'
        '/.git'
        '/wp-admin'
      ]
    }
  ]
  action: 'Block'
}
      
    ]
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
      ]
    }
    
  }
}
output appServiceFQDN string = appService.properties.defaultHostName


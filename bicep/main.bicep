module vnet 'hub-vnet.bicep' = {
  name:'hub-vnet'
  params:{
    
  }
}
module app 'app.bicep' ={
  name:'appConfig'
  params:{

  }
}
module bastion 'bastion.bicep' = {
  name:'Bastion'
  params:{
    appServiceFQDN:app.outputs.appServiceFQDN
  }
}

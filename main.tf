provider "azurerm" {
    version = "~>1.37.0"
}


resource "azurerm_resource_group" "production" {
  name     = "myresourcegroup11"
  location = "East US"
}

resource "azurerm_sql_server" "sqlserver" {
  name="prademoss12"
  resource_group_name="${azurerm_resource_group.production.name}"
  location = "East US"
  version="12.0"
  administrator_login="testadmin"
  administrator_login_password="Passw0rd@123"
}

resource "azurerm_sql_database" "sqldatabase" {
  name="MyDatabase"
  resource_group_name="${azurerm_resource_group.production.name}"
  location = "East US"
  server_name="${azurerm_sql_server.sqlserver.name}"
}


resource "azurerm_log_analytics_workspace" "logs" {
  name                = "prademotfflogs1"
  location = "East US"
   resource_group_name="${azurerm_resource_group.production.name}"
  sku                 = "PerNode"
  retention_in_days   = 30

 
}



resource "azurerm_monitor_diagnostic_setting" "sqldb_diagnostics" {
  name                           = "resource-specific-diagnostics-table"
  target_resource_id             = azurerm_sql_database.sqldatabase.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.logs.id
  storage_account_id                         =azurerm_storage_account.storage.id


    eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.example.id
 

  log {
    category = "SQLInsights"
    
    retention_policy {
      enabled = true
      days    = 7
    }
  }

log {
    category = "Errors"
    
    retention_policy {
      enabled = true
      days    = 7
    }
  }


  log {
    category = "AutomaticTuning"
    
    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "QueryStoreRuntimeStatistics"
    
    retention_policy {
     enabled = true
      days    = 7
    }
  }


  log {
    category = "QueryStoreWaitStatistics"
    
    retention_policy {
     enabled = true
      days    = 7
    }
  }



  log {
    category = "DatabaseWaitStatistics"
    
    retention_policy {
      enabled = true
      days    = 7
    }
  }


  log {
    category = "Blocks"
    
    retention_policy {
     enabled = true
      days    = 7
    }
  }


  log {
    category = "Deadlocks"
    
    retention_policy {
      enabled = true
      days    = 7
    }
  }

 log {
    category = "Timeouts"
    
    retention_policy {
      enabled = true
      days    = 7
    }
  }

 
  


  metric {
    category = "Basic" 
   
    
    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "InstanceAndAppAdvanced" 
   
    
    retention_policy {
      enabled = false
    }
  }

    metric {
    category = "WorkloadManagement" 
   
    
    retention_policy {
      enabled = false
    }
  }
 

}



resource "azurerm_storage_account" "storage" {
  name = "prademotfflogs1"
  resource_group_name="${azurerm_resource_group.production.name}"

  location = "East US"
  account_tier = "Standard"
  account_replication_type = "LRS"


 network_rules {
        default_action             = "Deny"
        ip_rules = ["5.104.64.0/21", "46.22.64.0/20", "61.221.181.64/26", "68.232.32.0/20", "72.21.80.0/20", "88.194.45.128/26", "93.184.208.0/20", "101.226.203.0/24", "108.161.240.0/20", "110.232.176.0/22", "117.18.232.0/21"]
        virtual_network_subnet_ids = ["${azurerm_subnet.subnet.id}"]
        
    }
 

 
}



resource "azurerm_virtual_network" "vnet" {
  name                = "prademovnet13"
 location             = "East US"
 resource_group_name  ="${azurerm_resource_group.production.name}"
  address_space       = ["192.168.14.0/24"]
  

}



resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  virtual_network_name      = azurerm_virtual_network.vnet.name
  resource_group_name        ="${azurerm_resource_group.production.name}"
  address_prefix       = "192.168.14.0/28"
    service_endpoints    = ["Microsoft.Storage"]
    
 
}




resource "azurerm_mssql_elasticpool" "sql_mssql_elasticpool" {
 name                = "test"
   resource_group_name        ="${azurerm_resource_group.production.name}"
   location = "East US"
   server_name="${azurerm_sql_server.sqlserver.name}"
  max_size_gb         = 32

  sku {
    name     = "GP_Gen5"
    tier     = "GeneralPurpose"
    family   = "Gen5"
    capacity = 2
  }

  per_database_settings {
    min_capacity = 0.25
    max_capacity = 2
  }
}



resource "azurerm_monitor_diagnostic_setting" "sql_elasticpool_diagnostics" {
  name                           = "elasticpool_diagnostic"

 
   target_resource_id           = azurerm_mssql_elasticpool.sql_mssql_elasticpool.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.logs.id
  storage_account_id                         =azurerm_storage_account.storage.id
 
    eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.example.id
 
  depends_on = [azurerm_storage_account.storage]

 metric {
    category = "Basic" 
   
    
    retention_policy {
      enabled =true
      days = 365
    }
  }

 metric {
    category = "InstanceAndAppAdvanced" 
   
    
    retention_policy {
      enabled =true
      days = 365
    }
  }
 

}


resource "azurerm_eventhub_namespace" "example" {
  name                = "prademo-ehnamespace"
    location = "East US"
  resource_group_name        ="${azurerm_resource_group.production.name}"
  sku                 = "Standard"
  capacity            = 2


}

resource "azurerm_eventhub_namespace_authorization_rule" "example" {
  name                = "prademo-nsauth-rule"
  namespace_name      = "${azurerm_eventhub_namespace.example.name}"
 
  resource_group_name        ="${azurerm_resource_group.production.name}"

  listen = true
  send   = true
  manage = true
}

resource "azurerm_eventhub" "example" {
  name                = "prademo-eh1"
  namespace_name      = "${azurerm_eventhub_namespace.example.name}"
  resource_group_name        ="${azurerm_resource_group.production.name}"

  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "prademo-enauth-rule"
  namespace_name      = "${azurerm_eventhub_namespace.example.name}"
  eventhub_name       = "${azurerm_eventhub.example.name}"
  resource_group_name        ="${azurerm_resource_group.production.name}"

  listen = true
  send   = true
  manage = true
}





variable "azure_elasticpool_name" {
  description = "The name of the elastic pool used by SQL Server for the environment. If empty, no Elastic Pool resource is created."
  default     = "prademoelasticpool"
}

variable "azure_elasticpool_per_database_settings_max_capacity" {
  description = "The maximum capacity any one database can consume (i.e. compute units)."
  default     = 50
}

variable "azure_elasticpool_max_size_gb" {
  description = "The max data size of the elastic pool in gigabytes."
  default     = "50"
}

variable "azure_elasticpool_sku_capacity" {
  description = "The scale up/out capacity, representing server's compute units."
  default     = 50
}

variable "azure_elasticpool_sku_tier" {
  description = "The tier of the particular SKU. We accept Basic/Standard/Premium and will concatenate it to create a BasicPool/StandardPool/PremiumPool SKU name."
  default     = "Standard"
}


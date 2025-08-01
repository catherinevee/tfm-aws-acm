# ==============================================================================
# Advanced Azure Cosmos DB Example
# ==============================================================================

# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-cosmosdb-advanced"
  location = "East US"
}

# Create a virtual network for private access
resource "azurerm_virtual_network" "example" {
  name                = "vnet-cosmosdb"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet for Cosmos DB
resource "azurerm_subnet" "example" {
  name                 = "subnet-cosmosdb"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.AzureCosmosDB"]
}

# Create a Key Vault for customer-managed keys
resource "azurerm_key_vault" "example" {
  name                        = "kv-cosmosdb-${random_string.suffix.result}"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

# Deploy the advanced Cosmos DB module
module "cosmosdb_advanced" {
  source = "../../"

  cosmosdb_account_name = "cosmosdb-advanced-${random_string.suffix.result}"
  location             = azurerm_resource_group.example.location
  resource_group_name  = azurerm_resource_group.example.name

  # Advanced account configuration
  kind = "GlobalDocumentDB"
  enable_automatic_failover = true
  enable_multiple_write_locations = true
  consistency_level = "Strong"

  # Multi-region deployment
  geo_locations = [
    {
      location          = "East US"
      failover_priority = 0
      zone_redundant    = true
    },
    {
      location          = "West US"
      failover_priority = 1
      zone_redundant    = false
    }
  ]

  # Backup policy
  backup_policy = {
    type                = "Continuous"
    retention_in_hours  = 720
    storage_redundancy  = "Local"
  }

  # Network security
  public_network_access_enabled = false
  virtual_network_rules = [
    {
      subnet_id = azurerm_subnet.example.id
      ignore_missing_vnet_service_endpoint = false
    }
  ]

  # Analytical storage
  analytical_storage = {
    schema_type = "WellDefined"
  }

  # Identity
  identity = {
    type = "SystemAssigned"
  }

  # CORS rules
  cors_rules = [
    {
      allowed_origins    = ["https://myapp.com", "https://api.myapp.com"]
      allowed_methods    = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
      allowed_headers    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 86400
    }
  ]

  # Multiple API support
  capabilities = [
    "EnableAggregationPipeline",
    "EnableCassandra",
    "EnableGremlin",
    "EnableTable"
  ]

  # SQL API resources
  sql_databases = {
    "sqldb" = {
      name = "sqldb"
      autoscale_settings = {
        max_throughput = 4000
      }
    }
  }

  sql_containers = {
    "users" = {
      name                = "users"
      database_name       = "sqldb"
      partition_key_path  = "/userId"
      autoscale_settings = {
        max_throughput = 4000
      }
      unique_keys = [
        {
          paths = ["/email"]
        }
      ]
      indexing_policy = {
        indexing_mode = "consistent"
        included_paths = [
          {
            path = "/*"
          }
        ]
        excluded_paths = [
          {
            path = "/\"_etag\"/?"
          }
        ]
        composite_indexes = [
          {
            indexes = [
              {
                path  = "/name"
                order = "ascending"
              },
              {
                path  = "/age"
                order = "descending"
              }
            ]
          }
        ]
      }
      default_ttl = 86400
    }
  }

  # MongoDB API resources
  mongo_databases = {
    "mongodb" = {
      name = "mongodb"
      throughput = 400
    }
  }

  mongo_collections = {
    "products" = {
      name          = "products"
      database_name = "mongodb"
      throughput    = 400
      indexes = [
        {
          keys   = ["_id"]
          unique = true
        },
        {
          keys   = ["category"]
          unique = false
        },
        {
          keys   = ["price"]
          unique = false
        }
      ]
      default_ttl_seconds = 2592000  # 30 days
    }
  }

  # Cassandra API resources
  cassandra_keyspaces = {
    "cassandra" = {
      name = "cassandra"
      autoscale_settings = {
        max_throughput = 4000
      }
    }
  }

  cassandra_tables = {
    "events" = {
      name          = "events"
      keyspace_name = "cassandra"
      throughput    = 400
      schema = {
        column = {
          name = "event_id"
          type = "uuid"
        }
        partition_keys = [
          {
            name = "event_id"
          }
        ]
        cluster_keys = [
          {
            name     = "timestamp"
            order_by = "desc"
          }
        ]
      }
    }
  }

  # Gremlin API resources
  gremlin_databases = {
    "gremlin" = {
      name = "gremlin"
      autoscale_settings = {
        max_throughput = 4000
      }
    }
  }

  gremlin_graphs = {
    "social" = {
      name                = "social"
      database_name       = "gremlin"
      partition_key_path  = "/pk"
      autoscale_settings = {
        max_throughput = 4000
      }
      index_policy = {
        indexing_mode = "consistent"
        included_paths = [
          {
            path = "/*"
          }
        ]
        excluded_paths = [
          {
            path = "/\"_etag\"/?"
          }
        ]
      }
    }
  }

  # Table API resources
  tables = {
    "logs" = {
      name = "logs"
      throughput = 400
    }
  }

  tags = {
    Environment = "Production"
    CostCenter  = "IT"
    Owner       = "Database Team"
    Project     = "Multi-API Application"
  }
}

# Generate a random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Output the results
output "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account"
  value       = module.cosmosdb_advanced.cosmosdb_account_name
}

output "cosmosdb_account_endpoint" {
  description = "The endpoint of the Cosmos DB account"
  value       = module.cosmosdb_advanced.cosmosdb_account_endpoint
}

output "cosmosdb_account_primary_key" {
  description = "The primary key of the Cosmos DB account"
  value       = module.cosmosdb_advanced.cosmosdb_account_primary_key
  sensitive   = true
}

output "total_databases" {
  description = "Total number of databases created"
  value       = module.cosmosdb_advanced.total_databases
}

output "total_containers" {
  description = "Total number of containers created"
  value       = module.cosmosdb_advanced.total_containers
}

output "cosmosdb_account_summary" {
  description = "Summary of the Cosmos DB account configuration"
  value       = module.cosmosdb_advanced.cosmosdb_account_summary
} 
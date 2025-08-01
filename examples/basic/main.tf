# ==============================================================================
# Basic Azure Cosmos DB Example
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
  name     = "rg-cosmosdb-example"
  location = "East US"
}

# Deploy the Cosmos DB module
module "cosmosdb" {
  source = "../../"

  cosmosdb_account_name = "cosmosdb-example-${random_string.suffix.result}"
  location             = azurerm_resource_group.example.location
  resource_group_name  = azurerm_resource_group.example.name

  # Basic SQL API configuration
  kind = "GlobalDocumentDB"
  
  # Single region deployment
  geo_locations = [
    {
      location          = "East US"
      failover_priority = 0
      zone_redundant    = false
    }
  ]

  # Create a simple SQL database
  sql_databases = {
    "mydb" = {
      name = "mydb"
      throughput = 400
    }
  }

  # Create a simple SQL container
  sql_containers = {
    "mycontainer" = {
      name                = "mycontainer"
      database_name       = "mydb"
      partition_key_path  = "/id"
      throughput          = 400
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
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "CosmosDB Example"
    Owner       = "DevOps Team"
  }
}

# Generate a random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Output the results
output "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account"
  value       = module.cosmosdb.cosmosdb_account_name
}

output "cosmosdb_account_endpoint" {
  description = "The endpoint of the Cosmos DB account"
  value       = module.cosmosdb.cosmosdb_account_endpoint
}

output "cosmosdb_account_primary_key" {
  description = "The primary key of the Cosmos DB account"
  value       = module.cosmosdb.cosmosdb_account_primary_key
  sensitive   = true
}

output "sql_databases" {
  description = "The SQL databases created"
  value       = module.cosmosdb.sql_databases
}

output "sql_containers" {
  description = "The SQL containers created"
  value       = module.cosmosdb.sql_containers
} 
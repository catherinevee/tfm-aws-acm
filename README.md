# Azure Cosmos DB Terraform Module

A comprehensive Terraform module for deploying Azure Cosmos DB accounts with support for all API types (SQL, MongoDB, Cassandra, Gremlin, and Table) and extensive customization options.

## Features

- **Multi-API Support**: Deploy Cosmos DB accounts with SQL, MongoDB, Cassandra, Gremlin, or Table API
- **Comprehensive Configuration**: Support for all major Cosmos DB features including:
  - Geo-replication and failover
  - Backup policies (Periodic and Continuous)
  - Network security (VNet rules, IP filters)
  - Customer-managed keys with Key Vault integration
  - Analytical storage
  - CORS configuration
  - Identity and access management
- **Flexible Throughput**: Support for both manual and autoscale throughput provisioning
- **Advanced Indexing**: Configurable indexing policies for SQL and Gremlin APIs
- **TTL Support**: Time-to-live configuration for data lifecycle management
- **Security**: Built-in security features with comprehensive validation

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cosmosdb_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_sql_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |
| [azurerm_cosmosdb_sql_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container) | resource |
| [azurerm_cosmosdb_mongo_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_mongo_database) | resource |
| [azurerm_cosmosdb_mongo_collection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_mongo_collection) | resource |
| [azurerm_cosmosdb_cassandra_keyspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_cassandra_keyspace) | resource |
| [azurerm_cosmosdb_cassandra_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_cassandra_table) | resource |
| [azurerm_cosmosdb_gremlin_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_gremlin_database) | resource |
| [azurerm_cosmosdb_gremlin_graph](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_gremlin_graph) | resource |
| [azurerm_cosmosdb_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_table) | resource |

## Inputs

### Required Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cosmosdb_account_name | The name of the Cosmos DB account | `string` | n/a | yes |
| location | The Azure region where the Cosmos DB account will be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group where the Cosmos DB account will be created | `string` | n/a | yes |

### Optional Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| offer_type | The offer type for the Cosmos DB account | `string` | `"Standard"` | no |
| kind | The kind of Cosmos DB account | `string` | `"GlobalDocumentDB"` | no |
| enable_automatic_failover | Enable automatic failover for the Cosmos DB account | `bool` | `false` | no |
| enable_free_tier | Enable free tier for the Cosmos DB account | `bool` | `false` | no |
| enable_multiple_write_locations | Enable multiple write locations for the Cosmos DB account | `bool` | `false` | no |
| consistency_level | The consistency level for the Cosmos DB account | `string` | `"Session"` | no |
| max_interval_in_seconds | The maximum interval in seconds for bounded staleness consistency | `number` | `5` | no |
| max_staleness_prefix | The maximum staleness prefix for bounded staleness consistency | `number` | `100` | no |
| geo_locations | List of geo locations for the Cosmos DB account | `list(object)` | `[]` | no |
| backup_policy | Backup policy configuration for the Cosmos DB account | `object` | `null` | no |
| virtual_network_rules | List of virtual network rules for the Cosmos DB account | `list(object)` | `[]` | no |
| ip_range_filter | IP range filter for the Cosmos DB account | `string` | `null` | no |
| public_network_access_enabled | Enable public network access for the Cosmos DB account | `bool` | `true` | no |
| key_vault_key_id | Key Vault Key ID for customer-managed keys | `string` | `null` | no |
| analytical_storage | Analytical storage configuration | `object` | `null` | no |
| capacity | Capacity configuration for the Cosmos DB account | `object` | `null` | no |
| identity | Identity configuration for the Cosmos DB account | `object` | `null` | no |
| restore | Restore configuration for the Cosmos DB account | `object` | `null` | no |
| cors_rules | List of CORS rules for the Cosmos DB account | `list(object)` | `[]` | no |
| capabilities | List of capabilities to enable for the Cosmos DB account | `list(string)` | `[]` | no |
| sql_databases | Map of SQL databases to create | `map(object)` | `{}` | no |
| sql_containers | Map of SQL containers to create | `map(object)` | `{}` | no |
| mongo_databases | Map of MongoDB databases to create | `map(object)` | `{}` | no |
| mongo_collections | Map of MongoDB collections to create | `map(object)` | `{}` | no |
| cassandra_keyspaces | Map of Cassandra keyspaces to create | `map(object)` | `{}` | no |
| cassandra_tables | Map of Cassandra tables to create | `map(object)` | `{}` | no |
| gremlin_databases | Map of Gremlin databases to create | `map(object)` | `{}` | no |
| gremlin_graphs | Map of Gremlin graphs to create | `map(object)` | `{}` | no |
| tables | Map of Table API tables to create | `map(object)` | `{}` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cosmosdb_account_id | The ID of the Cosmos DB account |
| cosmosdb_account_name | The name of the Cosmos DB account |
| cosmosdb_account_endpoint | The endpoint of the Cosmos DB account |
| cosmosdb_account_read_endpoints | The read endpoints of the Cosmos DB account |
| cosmosdb_account_write_endpoints | The write endpoints of the Cosmos DB account |
| cosmosdb_account_primary_key | The primary key of the Cosmos DB account |
| cosmosdb_account_secondary_key | The secondary key of the Cosmos DB account |
| cosmosdb_account_primary_readonly_key | The primary readonly key of the Cosmos DB account |
| cosmosdb_account_secondary_readonly_key | The secondary readonly key of the Cosmos DB account |
| cosmosdb_account_connection_strings | The connection strings of the Cosmos DB account |
| cosmosdb_account_geo_locations | The geo locations of the Cosmos DB account |
| cosmosdb_account_consistency_policy | The consistency policy of the Cosmos DB account |
| sql_databases | Map of SQL databases created |
| sql_containers | Map of SQL containers created |
| mongo_databases | Map of MongoDB databases created |
| mongo_collections | Map of MongoDB collections created |
| cassandra_keyspaces | Map of Cassandra keyspaces created |
| cassandra_tables | Map of Cassandra tables created |
| gremlin_databases | Map of Gremlin databases created |
| gremlin_graphs | Map of Gremlin graphs created |
| tables | Map of Table API tables created |
| total_databases | Total number of databases created across all APIs |
| total_containers | Total number of containers/collections/tables/graphs created |
| cosmosdb_account_summary | Summary of the Cosmos DB account configuration |

## Usage Examples

### Basic SQL API Example

```hcl
module "cosmosdb" {
  source = "./tfm-aws-acm"

  cosmosdb_account_name = "my-cosmosdb-account"
  location             = "East US"
  resource_group_name  = "my-resource-group"

  # Basic SQL API configuration
  kind = "GlobalDocumentDB"
  
  # Geo-replication
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

  # SQL databases and containers
  sql_databases = {
    "mydb" = {
      name = "mydb"
      autoscale_settings = {
        max_throughput = 4000
      }
    }
  }

  sql_containers = {
    "mycontainer" = {
      name                = "mycontainer"
      database_name       = "mydb"
      partition_key_path  = "/id"
      autoscale_settings = {
        max_throughput = 4000
      }
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
    Environment = "Production"
    Project     = "MyApp"
  }
}
```

### MongoDB API Example

```hcl
module "cosmosdb_mongo" {
  source = "./tfm-aws-acm"

  cosmosdb_account_name = "my-mongo-cosmosdb"
  location             = "East US"
  resource_group_name  = "my-resource-group"

  # MongoDB API configuration
  kind = "MongoDB"
  capabilities = ["EnableMongo"]

  # MongoDB databases and collections
  mongo_databases = {
    "mymongodb" = {
      name = "mymongodb"
      throughput = 400
    }
  }

  mongo_collections = {
    "mycollection" = {
      name          = "mycollection"
      database_name = "mymongodb"
      throughput    = 400
      indexes = [
        {
          keys   = ["_id"]
          unique = true
        },
        {
          keys   = ["name"]
          unique = false
        }
      ]
      default_ttl_seconds = 86400
    }
  }

  tags = {
    Environment = "Development"
    API         = "MongoDB"
  }
}
```

### Cassandra API Example

```hcl
module "cosmosdb_cassandra" {
  source = "./tfm-aws-acm"

  cosmosdb_account_name = "my-cassandra-cosmosdb"
  location             = "East US"
  resource_group_name  = "my-resource-group"

  # Cassandra API configuration
  capabilities = ["EnableCassandra"]

  # Cassandra keyspaces and tables
  cassandra_keyspaces = {
    "mykeyspace" = {
      name = "mykeyspace"
      autoscale_settings = {
        max_throughput = 4000
      }
    }
  }

  cassandra_tables = {
    "mytable" = {
      name          = "mytable"
      keyspace_name = "mykeyspace"
      throughput    = 400
      schema = {
        column = {
          name = "id"
          type = "uuid"
        }
        partition_keys = [
          {
            name = "id"
          }
        ]
      }
    }
  }

  tags = {
    Environment = "Staging"
    API         = "Cassandra"
  }
}
```

### Advanced Configuration Example

```hcl
module "cosmosdb_advanced" {
  source = "./tfm-aws-acm"

  cosmosdb_account_name = "my-advanced-cosmosdb"
  location             = "East US"
  resource_group_name  = "my-resource-group"

  # Advanced account configuration
  enable_automatic_failover = true
  enable_multiple_write_locations = true
  consistency_level = "Strong"

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
      subnet_id = "/subscriptions/.../subnets/my-subnet"
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
      allowed_origins    = ["https://myapp.com"]
      allowed_methods    = ["GET", "POST", "PUT", "DELETE"]
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

  # Mixed API resources
  sql_databases = {
    "sqldb" = {
      name = "sqldb"
      throughput = 400
    }
  }

  gremlin_databases = {
    "gremlindb" = {
      name = "gremlindb"
      autoscale_settings = {
        max_throughput = 4000
      }
    }
  }

  tables = {
    "mytable" = {
      name = "mytable"
      throughput = 400
    }
  }

  tags = {
    Environment = "Production"
    CostCenter  = "IT"
    Owner       = "Database Team"
  }
}
```

## Best Practices

### Security
- Use VNet rules to restrict network access
- Enable customer-managed keys for encryption
- Use system-assigned managed identities
- Configure appropriate CORS rules
- Enable private endpoints for production workloads

### Performance
- Choose appropriate consistency levels based on your application needs
- Use autoscale throughput for variable workloads
- Configure proper indexing policies
- Consider analytical storage for analytics workloads

### Cost Optimization
- Use free tier for development and testing
- Monitor and adjust throughput based on usage patterns
- Use appropriate backup policies
- Consider serverless capacity for low-traffic applications

### Monitoring
- Enable diagnostic settings
- Monitor throughput and storage usage
- Set up alerts for cost and performance metrics
- Use Azure Monitor for comprehensive monitoring

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For issues and questions, please open an issue in the repository or contact the maintainers.
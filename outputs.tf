# ==============================================================================
# Azure Cosmos DB Module - Outputs
# ==============================================================================

# Cosmos DB Account Outputs
output "cosmosdb_account_id" {
  description = "The ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.id
}

output "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmosdb_account_endpoint" {
  description = "The endpoint of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmosdb_account_read_endpoints" {
  description = "The read endpoints of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.read_endpoints
}

output "cosmosdb_account_write_endpoints" {
  description = "The write endpoints of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.write_endpoints
}

output "cosmosdb_account_primary_key" {
  description = "The primary key of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "cosmosdb_account_secondary_key" {
  description = "The secondary key of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.secondary_key
  sensitive   = true
}

output "cosmosdb_account_primary_readonly_key" {
  description = "The primary readonly key of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.primary_readonly_key
  sensitive   = true
}

output "cosmosdb_account_secondary_readonly_key" {
  description = "The secondary readonly key of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.secondary_readonly_key
  sensitive   = true
}

output "cosmosdb_account_connection_strings" {
  description = "The connection strings of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.connection_strings
  sensitive   = true
}

output "cosmosdb_account_geo_locations" {
  description = "The geo locations of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.geo_locations
}

output "cosmosdb_account_consistency_policy" {
  description = "The consistency policy of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.consistency_policy
}

# SQL Database Outputs
output "sql_databases" {
  description = "Map of SQL databases created"
  value = {
    for k, v in azurerm_cosmosdb_sql_database.databases : k => {
      id       = v.id
      name     = v.name
      resource_group_name = v.resource_group_name
      account_name = v.account_name
    }
  }
}

output "sql_database_ids" {
  description = "List of SQL database IDs"
  value       = values(azurerm_cosmosdb_sql_database.databases)[*].id
}

output "sql_database_names" {
  description = "List of SQL database names"
  value       = values(azurerm_cosmosdb_sql_database.databases)[*].name
}

# SQL Container Outputs
output "sql_containers" {
  description = "Map of SQL containers created"
  value = {
    for k, v in azurerm_cosmosdb_sql_container.containers : k => {
      id       = v.id
      name     = v.name
      database_name = v.database_name
      resource_group_name = v.resource_group_name
      account_name = v.account_name
      partition_key_paths = v.partition_key_paths
      partition_key_version = v.partition_key_version
      default_ttl = v.default_ttl
      analytical_storage_ttl = v.analytical_storage_ttl
    }
  }
}

output "sql_container_ids" {
  description = "List of SQL container IDs"
  value       = values(azurerm_cosmosdb_sql_container.containers)[*].id
}

output "sql_container_names" {
  description = "List of SQL container names"
  value       = values(azurerm_cosmosdb_sql_container.containers)[*].name
}

# MongoDB Database Outputs
output "mongo_databases" {
  description = "Map of MongoDB databases created"
  value = {
    for k, v in azurerm_cosmosdb_mongo_database.mongo_databases : k => {
      id       = v.id
      name     = v.name
      resource_group_name = v.resource_group_name
      account_name = v.account_name
    }
  }
}

output "mongo_database_ids" {
  description = "List of MongoDB database IDs"
  value       = values(azurerm_cosmosdb_mongo_database.mongo_databases)[*].id
}

output "mongo_database_names" {
  description = "List of MongoDB database names"
  value       = values(azurerm_cosmosdb_mongo_database.mongo_databases)[*].name
}

# MongoDB Collection Outputs
output "mongo_collections" {
  description = "Map of MongoDB collections created"
  value = {
    for k, v in azurerm_cosmosdb_mongo_collection.mongo_collections : k => {
      id       = v.id
      name     = v.name
      database_name = v.database_name
      resource_group_name = v.resource_group_name
      account_name = v.account_name
      default_ttl_seconds = v.default_ttl_seconds
      analytical_storage_ttl = v.analytical_storage_ttl
    }
  }
}

output "mongo_collection_ids" {
  description = "List of MongoDB collection IDs"
  value       = values(azurerm_cosmosdb_mongo_collection.mongo_collections)[*].id
}

output "mongo_collection_names" {
  description = "List of MongoDB collection names"
  value       = values(azurerm_cosmosdb_mongo_collection.mongo_collections)[*].name
}

# Cassandra Keyspace Outputs
output "cassandra_keyspaces" {
  description = "Map of Cassandra keyspaces created"
  value = {
    for k, v in azurerm_cosmosdb_cassandra_keyspace.cassandra_keyspaces : k => {
      id       = v.id
      name     = v.name
      resource_group_name = v.resource_group_name
      account_name = v.account_name
    }
  }
}

output "cassandra_keyspace_ids" {
  description = "List of Cassandra keyspace IDs"
  value       = values(azurerm_cosmosdb_cassandra_keyspace.cassandra_keyspaces)[*].id
}

output "cassandra_keyspace_names" {
  description = "List of Cassandra keyspace names"
  value       = values(azurerm_cosmosdb_cassandra_keyspace.cassandra_keyspaces)[*].name
}

# Cassandra Table Outputs
output "cassandra_tables" {
  description = "Map of Cassandra tables created"
  value = {
    for k, v in azurerm_cosmosdb_cassandra_table.cassandra_tables : k => {
      id       = v.id
      name     = v.name
      cassandra_keyspace_id = v.cassandra_keyspace_id
      default_ttl = v.default_ttl
    }
  }
}

output "cassandra_table_ids" {
  description = "List of Cassandra table IDs"
  value       = values(azurerm_cosmosdb_cassandra_table.cassandra_tables)[*].id
}

output "cassandra_table_names" {
  description = "List of Cassandra table names"
  value       = values(azurerm_cosmosdb_cassandra_table.cassandra_tables)[*].name
}

# Gremlin Database Outputs
output "gremlin_databases" {
  description = "Map of Gremlin databases created"
  value = {
    for k, v in azurerm_cosmosdb_gremlin_database.gremlin_databases : k => {
      id       = v.id
      name     = v.name
      resource_group_name = v.resource_group_name
      account_name = v.account_name
    }
  }
}

output "gremlin_database_ids" {
  description = "List of Gremlin database IDs"
  value       = values(azurerm_cosmosdb_gremlin_database.gremlin_databases)[*].id
}

output "gremlin_database_names" {
  description = "List of Gremlin database names"
  value       = values(azurerm_cosmosdb_gremlin_database.gremlin_databases)[*].name
}

# Gremlin Graph Outputs
output "gremlin_graphs" {
  description = "Map of Gremlin graphs created"
  value = {
    for k, v in azurerm_cosmosdb_gremlin_graph.gremlin_graphs : k => {
      id       = v.id
      name     = v.name
      database_name = v.database_name
      resource_group_name = v.resource_group_name
      account_name = v.account_name
      partition_key_paths = v.partition_key_paths
      partition_key_version = v.partition_key_version
      default_ttl = v.default_ttl
      analytical_storage_ttl = v.analytical_storage_ttl
    }
  }
}

output "gremlin_graph_ids" {
  description = "List of Gremlin graph IDs"
  value       = values(azurerm_cosmosdb_gremlin_graph.gremlin_graphs)[*].id
}

output "gremlin_graph_names" {
  description = "List of Gremlin graph names"
  value       = values(azurerm_cosmosdb_gremlin_graph.gremlin_graphs)[*].name
}

# Table API Outputs
output "tables" {
  description = "Map of Table API tables created"
  value = {
    for k, v in azurerm_cosmosdb_table.tables : k => {
      id       = v.id
      name     = v.name
      resource_group_name = v.resource_group_name
      account_name = v.account_name
    }
  }
}

output "table_ids" {
  description = "List of Table API table IDs"
  value       = values(azurerm_cosmosdb_table.tables)[*].id
}

output "table_names" {
  description = "List of Table API table names"
  value       = values(azurerm_cosmosdb_table.tables)[*].name
}

# Summary Outputs
output "total_databases" {
  description = "Total number of databases created across all APIs"
  value = {
    sql_databases     = length(var.sql_databases)
    mongo_databases   = length(var.mongo_databases)
    cassandra_keyspaces = length(var.cassandra_keyspaces)
    gremlin_databases = length(var.gremlin_databases)
    total = length(var.sql_databases) + length(var.mongo_databases) + length(var.cassandra_keyspaces) + length(var.gremlin_databases)
  }
}

output "total_containers" {
  description = "Total number of containers/collections/tables/graphs created"
  value = {
    sql_containers    = length(var.sql_containers)
    mongo_collections = length(var.mongo_collections)
    cassandra_tables  = length(var.cassandra_tables)
    gremlin_graphs    = length(var.gremlin_graphs)
    tables            = length(var.tables)
    total = length(var.sql_containers) + length(var.mongo_collections) + length(var.cassandra_tables) + length(var.gremlin_graphs) + length(var.tables)
  }
}

output "cosmosdb_account_summary" {
  description = "Summary of the Cosmos DB account configuration"
  value = {
    name                = azurerm_cosmosdb_account.main.name
    location            = azurerm_cosmosdb_account.main.location
    resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
    offer_type          = azurerm_cosmosdb_account.main.offer_type
    kind                = azurerm_cosmosdb_account.main.kind
    consistency_level   = azurerm_cosmosdb_account.main.consistency_policy[0].consistency_level
    geo_locations_count = length(azurerm_cosmosdb_account.main.geo_locations)
    capabilities_count  = length(var.capabilities)
    public_network_access_enabled = azurerm_cosmosdb_account.main.public_network_access_enabled
  }
} 
# ==============================================================================
# Azure Cosmos DB Module - Main Configuration
# ==============================================================================

# Azure Cosmos DB Account
resource "azurerm_cosmosdb_account" "main" {
  name                = var.cosmosdb_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.kind

  # Enable/disable capabilities
  enable_automatic_failover = var.enable_automatic_failover
  enable_free_tier         = var.enable_free_tier
  enable_multiple_write_locations = var.enable_multiple_write_locations

  # Consistency policy
  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }

  # Geo location configuration
  dynamic "geo_location" {
    for_each = var.geo_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = lookup(geo_location.value, "zone_redundant", false)
    }
  }

  # Backup policy
  dynamic "backup" {
    for_each = var.backup_policy != null ? [var.backup_policy] : []
    content {
      type                = backup.value.type
      interval_in_minutes = lookup(backup.value, "interval_in_minutes", null)
      retention_in_hours  = lookup(backup.value, "retention_in_hours", null)
      storage_redundancy  = lookup(backup.value, "storage_redundancy", null)
    }
  }

  # Network configuration
  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules
    content {
      id                                   = virtual_network_rule.value.subnet_id
      ignore_missing_vnet_service_endpoint = lookup(virtual_network_rule.value, "ignore_missing_vnet_service_endpoint", false)
    }
  }

  # IP range filter
  ip_range_filter = var.ip_range_filter

  # Public network access
  public_network_access_enabled = var.public_network_access_enabled

  # Key Vault Key ID for customer-managed keys
  key_vault_key_id = var.key_vault_key_id

  # Analytical storage configuration
  dynamic "analytical_storage" {
    for_each = var.analytical_storage != null ? [var.analytical_storage] : []
    content {
      schema_type = analytical_storage.value.schema_type
    }
  }

  # Capacity configuration
  dynamic "capacity" {
    for_each = var.capacity != null ? [var.capacity] : []
    content {
      total_throughput_limit = capacity.value.total_throughput_limit
    }
  }

  # Identity configuration
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  # Restore configuration
  dynamic "restore" {
    for_each = var.restore != null ? [var.restore] : []
    content {
      source_cosmosdb_account_id = restore.value.source_cosmosdb_account_id
      restore_timestamp_in_utc   = restore.value.restore_timestamp_in_utc
      dynamic "databases" {
        for_each = restore.value.databases
        content {
          name = databases.value.name
          collection_names = lookup(databases.value, "collection_names", null)
        }
      }
    }
  }

  # CORS rules
  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_origins    = cors_rule.value.allowed_origins
      exposed_headers    = lookup(cors_rule.value, "exposed_headers", null)
      allowed_headers    = lookup(cors_rule.value, "allowed_headers", null)
      allowed_methods    = lookup(cors_rule.value, "allowed_methods", null)
      max_age_in_seconds = lookup(cors_rule.value, "max_age_in_seconds", null)
    }
  }

  # Capabilities
  dynamic "capabilities" {
    for_each = var.capabilities
    content {
      name = capabilities.value
    }
  }

  tags = var.tags
}

# SQL Databases
resource "azurerm_cosmosdb_sql_database" "databases" {
  for_each = var.sql_databases

  name                = each.value.name
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name

  # Throughput configuration
  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_settings", null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  throughput = lookup(each.value, "throughput", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# SQL Containers
resource "azurerm_cosmosdb_sql_container" "containers" {
  for_each = var.sql_containers

  name                = each.value.name
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.databases[each.value.database_name].name

  # Partition key configuration
  partition_key_paths   = [each.value.partition_key_path]
  partition_key_version = lookup(each.value, "partition_key_version", 1)

  # Throughput configuration
  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_settings", null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  throughput = lookup(each.value, "throughput", null)

  # Unique key policy
  dynamic "unique_key" {
    for_each = lookup(each.value, "unique_keys", [])
    content {
      paths = unique_key.value.paths
    }
  }

  # Indexing policy
  dynamic "indexing_policy" {
    for_each = lookup(each.value, "indexing_policy", null) != null ? [each.value.indexing_policy] : []
    content {
      indexing_mode = lookup(indexing_policy.value, "indexing_mode", "consistent")

      dynamic "included_path" {
        for_each = lookup(indexing_policy.value, "included_paths", [])
        content {
          path = included_path.value.path
        }
      }

      dynamic "excluded_path" {
        for_each = lookup(indexing_policy.value, "excluded_paths", [])
        content {
          path = excluded_path.value.path
        }
      }

      dynamic "composite_index" {
        for_each = lookup(indexing_policy.value, "composite_indexes", [])
        content {
          dynamic "index" {
            for_each = composite_index.value.indexes
            content {
              path  = index.value.path
              order = index.value.order
            }
          }
        }
      }

      dynamic "spatial_index" {
        for_each = lookup(indexing_policy.value, "spatial_indexes", [])
        content {
          path = spatial_index.value.path
        }
      }
    }
  }

  # Conflict resolution policy
  dynamic "conflict_resolution_policy" {
    for_each = lookup(each.value, "conflict_resolution_policy", null) != null ? [each.value.conflict_resolution_policy] : []
    content {
      mode                          = conflict_resolution_policy.value.mode
      conflict_resolution_path      = lookup(conflict_resolution_policy.value, "conflict_resolution_path", null)
      conflict_resolution_procedure = lookup(conflict_resolution_policy.value, "conflict_resolution_procedure", null)
    }
  }

  # Default TTL
  default_ttl = lookup(each.value, "default_ttl", null)

  # Analytical TTL
  analytical_storage_ttl = lookup(each.value, "analytical_storage_ttl", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# MongoDB Databases
resource "azurerm_cosmosdb_mongo_database" "mongo_databases" {
  for_each = var.mongo_databases

  name                = each.value.name
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name

  # Throughput configuration
  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_settings", null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  throughput = lookup(each.value, "throughput", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# MongoDB Collections
resource "azurerm_cosmosdb_mongo_collection" "mongo_collections" {
  for_each = var.mongo_collections

  name                = each.value.name
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_mongo_database.mongo_databases[each.value.database_name].name

  # Throughput configuration
  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_settings", null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  throughput = lookup(each.value, "throughput", null)

  # Index configuration
  dynamic "index" {
    for_each = lookup(each.value, "indexes", [])
    content {
      keys   = index.value.keys
      unique = lookup(index.value, "unique", false)
    }
  }

  # Default TTL
  default_ttl_seconds = lookup(each.value, "default_ttl_seconds", null)

  # Analytical TTL
  analytical_storage_ttl = lookup(each.value, "analytical_storage_ttl", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# Cassandra Keyspaces
resource "azurerm_cosmosdb_cassandra_keyspace" "cassandra_keyspaces" {
  for_each = var.cassandra_keyspaces

  name                = each.value.name
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name

  # Throughput configuration
  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_settings", null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  throughput = lookup(each.value, "throughput", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# Cassandra Tables
resource "azurerm_cosmosdb_cassandra_table" "cassandra_tables" {
  for_each = var.cassandra_tables

  name                = each.value.name
  cassandra_keyspace_id = azurerm_cosmosdb_cassandra_keyspace.cassandra_keyspaces[each.value.keyspace_name].id

  # Schema configuration
  default_ttl = lookup(each.value, "default_ttl", null)

  # Throughput configuration
  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_settings", null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  throughput = lookup(each.value, "throughput", null)

  # Schema definition
  dynamic "schema" {
    for_each = lookup(each.value, "schema", null) != null ? [each.value.schema] : []
    content {
      column {
        name = schema.value.column.name
        type = schema.value.column.type
      }

      dynamic "partition_key" {
        for_each = lookup(schema.value, "partition_keys", [])
        content {
          name = partition_key.value.name
        }
      }

      dynamic "cluster_key" {
        for_each = lookup(schema.value, "cluster_keys", [])
        content {
          name      = cluster_key.value.name
          order_by  = cluster_key.value.order_by
        }
      }
    }
  }

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# Gremlin Databases
resource "azurerm_cosmosdb_gremlin_database" "gremlin_databases" {
  for_each = var.gremlin_databases

  name                = each.value.name
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name

  # Throughput configuration
  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_settings", null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  throughput = lookup(each.value, "throughput", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# Gremlin Graphs
resource "azurerm_cosmosdb_gremlin_graph" "gremlin_graphs" {
  for_each = var.gremlin_graphs

  name                = each.value.name
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_gremlin_database.gremlin_databases[each.value.database_name].name

  # Partition key configuration
  partition_key_path    = each.value.partition_key_path
  partition_key_version = lookup(each.value, "partition_key_version", 1)

  # Throughput configuration
  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_settings", null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  throughput = lookup(each.value, "throughput", null)

  # Indexing policy
  dynamic "index_policy" {
    for_each = lookup(each.value, "index_policy", null) != null ? [each.value.index_policy] : []
    content {
      indexing_mode = lookup(index_policy.value, "indexing_mode", "consistent")

      dynamic "included_path" {
        for_each = lookup(index_policy.value, "included_paths", [])
        content {
          path = included_path.value.path
        }
      }

      dynamic "excluded_path" {
        for_each = lookup(index_policy.value, "excluded_paths", [])
        content {
          path = excluded_path.value.path
        }
      }

      dynamic "composite_index" {
        for_each = lookup(index_policy.value, "composite_indexes", [])
        content {
          dynamic "index" {
            for_each = composite_index.value.indexes
            content {
              path  = index.value.path
              order = index.value.order
            }
          }
        }
      }

      dynamic "spatial_index" {
        for_each = lookup(index_policy.value, "spatial_indexes", [])
        content {
          path = spatial_index.value.path
        }
      }
    }
  }

  # Conflict resolution policy
  dynamic "conflict_resolution_policy" {
    for_each = lookup(each.value, "conflict_resolution_policy", null) != null ? [each.value.conflict_resolution_policy] : []
    content {
      mode                          = conflict_resolution_policy.value.mode
      conflict_resolution_path      = lookup(conflict_resolution_policy.value, "conflict_resolution_path", null)
      conflict_resolution_procedure = lookup(conflict_resolution_policy.value, "conflict_resolution_procedure", null)
    }
  }

  # Default TTL
  default_ttl = lookup(each.value, "default_ttl", null)

  # Analytical TTL
  analytical_storage_ttl = lookup(each.value, "analytical_storage_ttl", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# Table API Tables
resource "azurerm_cosmosdb_table" "tables" {
  for_each = var.tables

  name                = each.value.name
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name

  # Throughput configuration
  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_settings", null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  throughput = lookup(each.value, "throughput", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))
} 
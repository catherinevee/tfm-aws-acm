# ==============================================================================
# Azure Cosmos DB Module - Variables
# ==============================================================================

# Required Variables
variable "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,50}$", var.cosmosdb_account_name))
    error_message = "Cosmos DB account name must be between 3-50 characters long and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the Cosmos DB account will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Cosmos DB account will be created"
  type        = string
}

# Optional Variables with Defaults
variable "offer_type" {
  description = "The offer type for the Cosmos DB account. Default is 'Standard'"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard"], var.offer_type)
    error_message = "Offer type must be 'Standard'."
  }
}

variable "kind" {
  description = "The kind of Cosmos DB account. Default is 'GlobalDocumentDB'"
  type        = string
  default     = "GlobalDocumentDB"

  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB", "Parse"], var.kind)
    error_message = "Kind must be one of: GlobalDocumentDB, MongoDB, Parse."
  }
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover for the Cosmos DB account. Default is false"
  type        = bool
  default     = false
}

variable "enable_free_tier" {
  description = "Enable free tier for the Cosmos DB account. Default is false"
  type        = bool
  default     = false
}

variable "enable_multiple_write_locations" {
  description = "Enable multiple write locations for the Cosmos DB account. Default is false"
  type        = bool
  default     = false
}

# Consistency Policy Variables
variable "consistency_level" {
  description = "The consistency level for the Cosmos DB account. Default is 'Session'"
  type        = string
  default     = "Session"

  validation {
    condition     = contains(["Eventual", "ConsistentPrefix", "Session", "BoundedStaleness", "Strong"], var.consistency_level)
    error_message = "Consistency level must be one of: Eventual, ConsistentPrefix, Session, BoundedStaleness, Strong."
  }
}

variable "max_interval_in_seconds" {
  description = "The maximum interval in seconds for bounded staleness consistency. Default is 5"
  type        = number
  default     = 5

  validation {
    condition     = var.max_interval_in_seconds >= 5 && var.max_interval_in_seconds <= 86400
    error_message = "Max interval in seconds must be between 5 and 86400."
  }
}

variable "max_staleness_prefix" {
  description = "The maximum staleness prefix for bounded staleness consistency. Default is 100"
  type        = number
  default     = 100

  validation {
    condition     = var.max_staleness_prefix >= 10 && var.max_staleness_prefix <= 2147483647
    error_message = "Max staleness prefix must be between 10 and 2147483647."
  }
}

# Geo Location Variables
variable "geo_locations" {
  description = "List of geo locations for the Cosmos DB account"
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for geo in var.geo_locations : geo.failover_priority >= 0
    ])
    error_message = "Failover priority must be a non-negative integer."
  }
}

# Backup Policy Variables
variable "backup_policy" {
  description = "Backup policy configuration for the Cosmos DB account"
  type = object({
    type                = string
    interval_in_minutes = optional(number)
    retention_in_hours  = optional(number)
    storage_redundancy  = optional(string)
  })
  default = null

  validation {
    condition = var.backup_policy == null || contains(["Periodic", "Continuous"], var.backup_policy.type)
    error_message = "Backup policy type must be either 'Periodic' or 'Continuous'."
  }
}

# Network Configuration Variables
variable "virtual_network_rules" {
  description = "List of virtual network rules for the Cosmos DB account"
  type = list(object({
    subnet_id                                   = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  default = []
}

variable "ip_range_filter" {
  description = "IP range filter for the Cosmos DB account"
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Enable public network access for the Cosmos DB account. Default is true"
  type        = bool
  default     = true
}

# Key Vault Integration
variable "key_vault_key_id" {
  description = "Key Vault Key ID for customer-managed keys"
  type        = string
  default     = null
}

# Analytical Storage Variables
variable "analytical_storage" {
  description = "Analytical storage configuration"
  type = object({
    schema_type = string
  })
  default = null

  validation {
    condition = var.analytical_storage == null || contains(["WellDefined", "FullFidelity"], var.analytical_storage.schema_type)
    error_message = "Analytical storage schema type must be either 'WellDefined' or 'FullFidelity'."
  }
}

# Capacity Variables
variable "capacity" {
  description = "Capacity configuration for the Cosmos DB account"
  type = object({
    total_throughput_limit = number
  })
  default = null
}

# Identity Variables
variable "identity" {
  description = "Identity configuration for the Cosmos DB account"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned,UserAssigned"], var.identity.type)
    error_message = "Identity type must be one of: SystemAssigned, UserAssigned, SystemAssigned,UserAssigned."
  }
}

# Restore Variables
variable "restore" {
  description = "Restore configuration for the Cosmos DB account"
  type = object({
    source_cosmosdb_account_id = string
    restore_timestamp_in_utc   = string
    databases = list(object({
      name             = string
      collection_names = optional(list(string))
    }))
  })
  default = null
}

# CORS Rules Variables
variable "cors_rules" {
  description = "List of CORS rules for the Cosmos DB account"
  type = list(object({
    allowed_origins    = list(string)
    exposed_headers    = optional(list(string))
    allowed_headers    = optional(list(string))
    allowed_methods    = optional(list(string))
    max_age_in_seconds = optional(number)
  }))
  default = []
}

# Capabilities Variables
variable "capabilities" {
  description = "List of capabilities to enable for the Cosmos DB account"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cap in var.capabilities : contains([
        "EnableAggregationPipeline",
        "EnableCassandra",
        "EnableGremlin",
        "EnableTable",
        "EnableServerless",
        "EnableMongo",
        "EnableAnalyticalStorage"
      ], cap)
    ])
    error_message = "Invalid capability specified. Valid capabilities are: EnableAggregationPipeline, EnableCassandra, EnableGremlin, EnableTable, EnableServerless, EnableMongo, EnableAnalyticalStorage."
  }
}

# SQL Database Variables
variable "sql_databases" {
  description = "Map of SQL databases to create"
  type = map(object({
    name = string
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    throughput = optional(number)
    tags       = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for db in values(var.sql_databases) : 
      (db.autoscale_settings == null && db.throughput != null) ||
      (db.autoscale_settings != null && db.throughput == null) ||
      (db.autoscale_settings == null && db.throughput == null)
    ])
    error_message = "For each SQL database, either autoscale_settings or throughput must be specified, but not both."
  }
}

# SQL Container Variables
variable "sql_containers" {
  description = "Map of SQL containers to create"
  type = map(object({
    name                = string
    database_name       = string
    partition_key_path  = string
    partition_key_version = optional(number, 1)
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    throughput = optional(number)
    unique_keys = optional(list(object({
      paths = list(string)
    })))
    indexing_policy = optional(object({
      indexing_mode = optional(string, "consistent")
      included_paths = optional(list(object({
        path = string
      })))
      excluded_paths = optional(list(object({
        path = string
      })))
      composite_indexes = optional(list(object({
        indexes = list(object({
          path  = string
          order = string
        }))
      })))
      spatial_indexes = optional(list(object({
        path = string
      })))
    }))
    conflict_resolution_policy = optional(object({
      mode                          = string
      conflict_resolution_path      = optional(string)
      conflict_resolution_procedure = optional(string)
    }))
    default_ttl = optional(number)
    analytical_storage_ttl = optional(number)
    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for container in values(var.sql_containers) : 
      (container.autoscale_settings == null && container.throughput != null) ||
      (container.autoscale_settings != null && container.throughput == null) ||
      (container.autoscale_settings == null && container.throughput == null)
    ])
    error_message = "For each SQL container, either autoscale_settings or throughput must be specified, but not both."
  }
}

# MongoDB Database Variables
variable "mongo_databases" {
  description = "Map of MongoDB databases to create"
  type = map(object({
    name = string
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    throughput = optional(number)
    tags       = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for db in values(var.mongo_databases) : 
      (db.autoscale_settings == null && db.throughput != null) ||
      (db.autoscale_settings != null && db.throughput == null) ||
      (db.autoscale_settings == null && db.throughput == null)
    ])
    error_message = "For each MongoDB database, either autoscale_settings or throughput must be specified, but not both."
  }
}

# MongoDB Collection Variables
variable "mongo_collections" {
  description = "Map of MongoDB collections to create"
  type = map(object({
    name                = string
    database_name       = string
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    throughput = optional(number)
    indexes = optional(list(object({
      keys   = list(string)
      unique = optional(bool, false)
    })))
    default_ttl_seconds = optional(number)
    analytical_storage_ttl = optional(number)
    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for collection in values(var.mongo_collections) : 
      (collection.autoscale_settings == null && collection.throughput != null) ||
      (collection.autoscale_settings != null && collection.throughput == null) ||
      (collection.autoscale_settings == null && collection.throughput == null)
    ])
    error_message = "For each MongoDB collection, either autoscale_settings or throughput must be specified, but not both."
  }
}

# Cassandra Keyspace Variables
variable "cassandra_keyspaces" {
  description = "Map of Cassandra keyspaces to create"
  type = map(object({
    name = string
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    throughput = optional(number)
    tags       = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for keyspace in values(var.cassandra_keyspaces) : 
      (keyspace.autoscale_settings == null && keyspace.throughput != null) ||
      (keyspace.autoscale_settings != null && keyspace.throughput == null) ||
      (keyspace.autoscale_settings == null && keyspace.throughput == null)
    ])
    error_message = "For each Cassandra keyspace, either autoscale_settings or throughput must be specified, but not both."
  }
}

# Cassandra Table Variables
variable "cassandra_tables" {
  description = "Map of Cassandra tables to create"
  type = map(object({
    name                = string
    keyspace_name       = string
    default_ttl         = optional(number)
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    throughput = optional(number)
    schema = optional(object({
      column = object({
        name = string
        type = string
      })
      partition_keys = optional(list(object({
        name = string
      })))
      cluster_keys = optional(list(object({
        name     = string
        order_by = string
      })))
    }))
    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for table in values(var.cassandra_tables) : 
      (table.autoscale_settings == null && table.throughput != null) ||
      (table.autoscale_settings != null && table.throughput == null) ||
      (table.autoscale_settings == null && table.throughput == null)
    ])
    error_message = "For each Cassandra table, either autoscale_settings or throughput must be specified, but not both."
  }
}

# Gremlin Database Variables
variable "gremlin_databases" {
  description = "Map of Gremlin databases to create"
  type = map(object({
    name = string
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    throughput = optional(number)
    tags       = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for db in values(var.gremlin_databases) : 
      (db.autoscale_settings == null && db.throughput != null) ||
      (db.autoscale_settings != null && db.throughput == null) ||
      (db.autoscale_settings == null && db.throughput == null)
    ])
    error_message = "For each Gremlin database, either autoscale_settings or throughput must be specified, but not both."
  }
}

# Gremlin Graph Variables
variable "gremlin_graphs" {
  description = "Map of Gremlin graphs to create"
  type = map(object({
    name                = string
    database_name       = string
    partition_key_path  = string
    partition_key_version = optional(number, 1)
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    throughput = optional(number)
    index_policy = optional(object({
      indexing_mode = optional(string, "consistent")
      included_paths = optional(list(object({
        path = string
      })))
      excluded_paths = optional(list(object({
        path = string
      })))
      composite_indexes = optional(list(object({
        indexes = list(object({
          path  = string
          order = string
        }))
      })))
      spatial_indexes = optional(list(object({
        path = string
      })))
    }))
    conflict_resolution_policy = optional(object({
      mode                          = string
      conflict_resolution_path      = optional(string)
      conflict_resolution_procedure = optional(string)
    }))
    default_ttl = optional(number)
    analytical_storage_ttl = optional(number)
    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for graph in values(var.gremlin_graphs) : 
      (graph.autoscale_settings == null && graph.throughput != null) ||
      (graph.autoscale_settings != null && graph.throughput == null) ||
      (graph.autoscale_settings == null && graph.throughput == null)
    ])
    error_message = "For each Gremlin graph, either autoscale_settings or throughput must be specified, but not both."
  }
}

# Table API Variables
variable "tables" {
  description = "Map of Table API tables to create"
  type = map(object({
    name = string
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    throughput = optional(number)
    tags       = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for table in values(var.tables) : 
      (table.autoscale_settings == null && table.throughput != null) ||
      (table.autoscale_settings != null && table.throughput == null) ||
      (table.autoscale_settings == null && table.throughput == null)
    ])
    error_message = "For each Table API table, either autoscale_settings or throughput must be specified, but not both."
  }
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
} 
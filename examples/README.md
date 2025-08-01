# Azure Cosmos DB Module Examples

This directory contains example configurations for the Azure Cosmos DB Terraform module.

## Examples Overview

### Basic Example (`basic/`)

A simple example demonstrating basic SQL API usage with:
- Single-region deployment
- Basic SQL database and container
- Standard indexing policy
- Manual throughput provisioning

**Use case**: Development and testing environments, simple applications

### Advanced Example (`advanced/`)

A comprehensive example demonstrating advanced features including:
- Multi-region deployment with geo-replication
- Multiple API support (SQL, MongoDB, Cassandra, Gremlin, Table)
- Advanced security features (VNet integration, private access)
- Complex indexing policies
- Autoscale throughput
- Backup policies
- CORS configuration
- Analytical storage

**Use case**: Production environments, complex multi-API applications

## Getting Started

### Prerequisites

1. **Azure CLI**: Install and authenticate with Azure
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

2. **Terraform**: Install Terraform (version >= 1.0)
   ```bash
   # Download from https://www.terraform.io/downloads.html
   # or use package manager
   ```

3. **Azure Provider**: The examples use the Azure provider (~> 3.0)

### Running the Examples

1. **Navigate to an example directory**:
   ```bash
   cd examples/basic
   # or
   cd examples/advanced
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the plan**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

5. **Clean up resources** (when done):
   ```bash
   terraform destroy
   ```

## Example Configurations

### Basic Example Features

```hcl
# Simple SQL API configuration
module "cosmosdb" {
  source = "../../"

  cosmosdb_account_name = "cosmosdb-example-abc123"
  location             = "East US"
  resource_group_name  = "rg-cosmosdb-example"

  # Single region deployment
  geo_locations = [
    {
      location          = "East US"
      failover_priority = 0
      zone_redundant    = false
    }
  ]

  # Basic SQL database and container
  sql_databases = {
    "mydb" = {
      name = "mydb"
      throughput = 400
    }
  }

  sql_containers = {
    "mycontainer" = {
      name                = "mycontainer"
      database_name       = "mydb"
      partition_key_path  = "/id"
      throughput          = 400
    }
  }
}
```

### Advanced Example Features

```hcl
# Multi-API configuration with advanced features
module "cosmosdb_advanced" {
  source = "../../"

  cosmosdb_account_name = "cosmosdb-advanced-abc123"
  location             = "East US"
  resource_group_name  = "rg-cosmosdb-advanced"

  # Multi-region deployment
  enable_automatic_failover = true
  enable_multiple_write_locations = true
  consistency_level = "Strong"

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

  # Network security
  public_network_access_enabled = false
  virtual_network_rules = [
    {
      subnet_id = azurerm_subnet.example.id
      ignore_missing_vnet_service_endpoint = false
    }
  ]

  # Multiple APIs
  capabilities = [
    "EnableAggregationPipeline",
    "EnableCassandra",
    "EnableGremlin",
    "EnableTable"
  ]

  # Mixed API resources
  sql_databases = { /* ... */ }
  mongo_databases = { /* ... */ }
  cassandra_keyspaces = { /* ... */ }
  gremlin_databases = { /* ... */ }
  tables = { /* ... */ }
}
```

## Cost Considerations

### Basic Example
- **Estimated cost**: $25-50/month
- Single region deployment
- Minimal throughput (400 RU/s)
- Suitable for development/testing

### Advanced Example
- **Estimated cost**: $200-500/month
- Multi-region deployment
- Higher throughput (4000 RU/s autoscale)
- Multiple APIs and features
- Suitable for production workloads

## Security Best Practices

1. **Network Security**:
   - Use VNet rules to restrict access
   - Disable public network access for production
   - Enable service endpoints

2. **Authentication**:
   - Use managed identities when possible
   - Rotate access keys regularly
   - Use Key Vault for key management

3. **Data Protection**:
   - Enable customer-managed keys
   - Configure appropriate backup policies
   - Use strong consistency when needed

## Monitoring and Maintenance

1. **Set up monitoring**:
   - Enable diagnostic settings
   - Configure alerts for cost and performance
   - Monitor throughput usage

2. **Regular maintenance**:
   - Review and optimize indexing policies
   - Monitor and adjust throughput
   - Update security configurations

## Troubleshooting

### Common Issues

1. **Naming conflicts**: Ensure unique account names across Azure
2. **Network connectivity**: Verify VNet rules and service endpoints
3. **Throughput limits**: Check for capacity constraints
4. **API compatibility**: Ensure correct capabilities are enabled

### Getting Help

- Check the main module README for detailed documentation
- Review Azure Cosmos DB documentation
- Open an issue in the repository for bugs or questions

## Next Steps

After running the examples:

1. **Customize the configuration** for your specific needs
2. **Add monitoring and alerting** for production use
3. **Implement CI/CD pipelines** for automated deployments
4. **Set up backup and disaster recovery** procedures
5. **Configure cost optimization** strategies 
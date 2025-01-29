# Migrating Azure Storage Accounts from V1 to V2

## Overview

Azure Storage accounts come in different **kinds** (or SKUs), including **Storage (V1)**, **StorageV2 (General Purpose v2)**, and **BlobStorage**. Migrating from a **Storage V1** account to a **StorageV2** account provides access to a wide range of features and enhancements, including improved performance, lower costs (depending on usage), and additional security and networking options.

This guide walks you through:

1. **Reasons to migrate** to **StorageV2**  
2. **How to identify** existing **Storage V1** accounts  
3. **Steps to migrate** your **Storage V1** accounts to **StorageV2**  

---

## Why Migrate to StorageV2

Migrating from **Storage V1** to **StorageV2** unlocks the following benefits:

1. **Enhanced Features**  
   - Access to **lifecycle management** for automatic data movement between tiers (Hot, Cool, Archive).
   - **Virtual networks** and **Firewall rules** for securing and restricting access.
   - **Storage analytics** with more detailed metrics and logging.
   - **Customer-managed keys** (CMK) encryption and advanced security configurations.

2. **Cost-Effectiveness**  
   - **Tiered storage pricing**: Choose between Hot, Cool, and Archive based on access frequency, allowing more cost-effective data management.
   - Built-in **lifecycle management** ensures optimal data placement across tiers.

3. **Performance and Scalability**  
   - **Better performance**: StorageV2 is optimized for modern workloads.
   - **Higher throughput** and improved transaction rates for demanding scenarios.

4. **Future-Proofing**  
   - Ongoing investments and new features from Microsoft target **StorageV2** more than older SKUs.
   - Ensures compatibility with new **Azure features** and services.

---

## Identifying Your Storage V1 Accounts

Use the following Azure Resource Graph **KQL** query to list all **Storage V1** accounts (kind=Storage). It will show the account name, resource group, and subscription, as well as generate a sample CLI migration command.

```kql
Resources
| where type == "microsoft.storage/storageaccounts"
| where kind == "Storage"
| project 
    name, 
    resourceGroup, 
    subscriptionId, 
    location, 
    kind, 
    sku,
    MigrationCommand = strcat(
        "az storage account update -g ", 
        resourceGroup,
        " -n ", 
        name,
        " --set kind=StorageV2 --access-tier=Hot"
    )
```

### Explanation

- **where type == "microsoft.storage/storageaccounts"**: Filters the resources to storage accounts.  
- **where kind == "Storage"**: Selects only **Storage V1** accounts (older general purpose).  
- **project**: Displays specific columns, plus a **MigrationCommand** to **easily** move the account to **StorageV2** with a **Hot** access tier.

---

## Migration Steps

The sample command in the `MigrationCommand` column shows you how to update an existing **Storage V1** account to **StorageV2**:

```bash
az storage account update -g <resource-group> -n <storage-account> --set kind=StorageV2 --access-tier=Hot
```

### Step-by-Step Migration

1. **Review Existing Accounts**  
   - Run the KQL query (either in Azure Resource Graph Explorer or via Azure CLI with Resource Graph)  
   - Identify the **Storage V1** accounts you need to upgrade.

2. **Check Dependencies**  
   - Confirm no critical application dependencies will break during the migration.  
   - Ensure backup/restore processes are in place in case of unexpected changes.

3. **Plan an Access Tier**  
   - By default, the command sets the **Hot** tier, suitable for frequent access.  
   - If data is infrequently accessed, consider **Cool** or eventually **Archive** for further cost savings.

4. **Update to StorageV2**  
   - Run the generated **az storage account update** command for each Storage V1 account.  
   - E.g.:
     ```bash
     az storage account update -g MyResourceGroup -n MyStorageV1Acct --set kind=StorageV2 --access-tier=Hot
     ```
   - This operation is typically quick, but plan accordingly to avoid disruptions.

5. **Validate the Upgrade**  
   - Verify each storage account now shows **kind=StorageV2** in Azure Portal or via CLI:
     ```bash
     az storage account show -n MyStorageV1Acct -g MyResourceGroup --query "kind" -o tsv
     ```
   - Confirm the account is functioning as expected (blob data, file shares, etc. remain accessible).

---

## Additional Considerations

- **Data Redundancy**: Ensure your replication (LRS, GRS, RA-GRS, etc.) settings are preserved or reconfigured if needed.  
- **Networking and Security**: **StorageV2** offers improved networking (VNET endpoints, firewall rules) and security features (advanced threat protection, encryption with customer-managed keys). Evaluate these options.  
- **Audit Logs**: Check your activity logs to ensure the update operation completed without errors.  
- **Monitor Costs**: Since **StorageV2** automatically exposes tiered pricing, keep an eye on your storage bill, especially if you move data from Hot to Cool or Archive tiers.

---

## Conclusion

Upgrading to **StorageV2** is a straightforward process that unlocks a variety of performance, security, and cost benefits. By running the provided **KQL** query, you can quickly identify your existing **Storage V1** accounts and generate the CLI command to perform the upgrade seamlessly. Make sure to review your application dependencies, configure the correct access tier, and validate the results for a smooth transition.

> **Tip**: After migration, explore features like **lifecycle management**, **advanced networking**, and **encryption** options to fully leverage the advantages of **StorageV2**.



Below is a simple footer template you can place at the end of your Markdown documentation to track changes. Just paste it into your document (replace the placeholder text with your own details) and add rows as needed whenever changes occur.

---

```markdown
## Change Log
| Version | Date       | Author             | Description                                                        |
|---------|------------|--------------------|--------------------------------------------------------------------|
| 1.0     | 2025-01-29 | Chris Cabezudo     | *Initial creation.*                                                |
```

# RBAC Role Assignment for GLASS Application
 
## Overview
When creating a new **Resource Group** to host the **GLASS** application, the following **Role-Based Access Control (RBAC)** assignments must be applied to ensure the necessary permissions are granted to service identities.
 
## Required Assignments
The following roles must be assigned to the identities **FF-Developer** and **ff-github-app** for every new resource group.
 
### **Set the Scope Variable**
Before running the commands, replace `<your-scope-here>` with the **Azure Resource Group scope** where the GLASS application is being deployed:
 
```sh
SCOPE="/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>"
```
 
### **Assigning Roles to FF-Developer**
```sh
az role assignment create --assignee FF-Developer --role "Contributor" --scope $SCOPE
az role assignment create --assignee FF-Developer --role "Key Vault Secrets Officer" --scope $SCOPE
az role assignment create --assignee FF-Developer --role "Storage Blob Data Contributor" --scope $SCOPE
```
 
### **Assigning Roles to ff-github-app**
```sh
az role assignment create --assignee ff-github-app --role "Contributor" --scope $SCOPE
az role assignment create --assignee ff-github-app --role "Key Vault Secrets Officer" --scope $SCOPE
az role assignment create --assignee ff-github-app --role "Storage Blob Data Contributor" --scope $SCOPE
```
 
## Notes
- Ensure that **FF-Developer** and **ff-github-app** are valid Azure AD **Object IDs** or **Service Principals**.
- If these identities are service principals, retrieve their Object IDs using:
  ```sh
  az ad sp list --display-name "FF-Developer" --query "[].{id:appId, name:displayName}"
  az ad sp list --display-name "ff-github-app" --query "[].{id:appId, name:displayName}"
  ```
- Update `--assignee` in the commands above with the correct **Object ID** if necessary.
 
## When to Run These Commands
Run these commands **each time** a new resource group is created for the **GLASS** application to ensure proper access management.
 
---
_Last Updated: $(date)_
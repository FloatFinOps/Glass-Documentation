# AI Process Documentation – Cloud Resource Action Report

## 1. Overview

The Cloud Resource Action Report API generates AI-driven reports for multiple cloud resources and actions. It orchestrates parallel execution of individual resource-action evaluations and aggregates the results into a unified response. The system leverages caching and concurrent processing to improve performance and scalability.

---

## 2. API Purpose

This API provides:
- AI-generated reports for multiple resources and actions
- Parallel processing of resource-action combinations
- Aggregated results for bulk evaluation scenarios

---

## 3. Components

### Core Components

- API Layer (entry point)
- Request Validator (`GetCloudResourceActionReportRequestValidator`)
- Memory Cache (`_memoryCache`)
- Parallel Execution Engine (`Task.WhenAll`)
- Single Action Report Service (`GetCloudResourceSingleActionReport`)
- AI Orchestrator (delegated to single-action API)
- Response Aggregator

---

## 4. Workflow

### Step-by-step execution

1. Receive API request
2. Validate request parameters
3. Generate cache key
4. If ResetCache is true:
   - Clear memory cache
5. Check memory cache:
   - If exists → return cached result
6. Initialize task list
7. For each action:
   - For each resourceId:
     - Create single-action request
     - Add async task to list
8. Execute all tasks in parallel:
   - Task.WhenAll
9. Filter successful results
10. Aggregate responses into list
11. Store result in cache
12. Return aggregated response

---

## 5. Data Flow

### Input

- ResourceIds (list)
- Actions (list)
- AIModelDeploymentName
- ResetCache

### Processing Flow

Request
  ↓
Validate Input
  ↓
Cache Key Generation
  ↓
Memory Cache Check
  ↓
Generate Task List
  ↓
  ├─ ResourceId × Action combinations
  ↓
Parallel Execution (Task.WhenAll)
  ↓
  ├─ GetCloudResourceSingleActionReport
  │     ├─ Fetch Resource Metadata
  │     ├─ Build Prompt
  │     ├─ Call Azure OpenAI
  │     └─ Generate Report
  ↓
Filter Successful Results
  ↓
Aggregate Response List
  ↓
Cache Storage
  ↓
Return

---

## 6. Component Interaction

| From | To | Purpose |
|------|----|--------|
| API Layer | Validator | Validate request |
| API Layer | Memory Cache | Retrieve/store result |
| API Layer | Task Engine | Execute parallel processing |
| API Layer | Single Action Service | Generate individual reports |
| Single Action Service | Azure APIs | Fetch resource metadata |
| Single Action Service | Prompt Builder | Construct AI input |
| Single Action Service | Azure OpenAI | Generate report |
| API Layer | Response Model | Aggregate output |

---

## 7. Concurrency & Optimization

### Parallel Processing
- Uses `Task.WhenAll`
- Executes multiple resource-action evaluations concurrently
- Significantly improves performance for bulk operations

### Caching
- Avoids repeated computation for identical requests
- TTL-based expiration

### Delegated AI Execution
- AI calls handled in single-action service
- Enables reuse and modular design

---

## 8. Response Structure

### CloudResourceActionReportResponse

- ResourceId
- Action
- Report (AI-generated content)

---

## 9. Workflow Diagram

![Exports page](Workflow-GetCloudResourceActionReport.png)
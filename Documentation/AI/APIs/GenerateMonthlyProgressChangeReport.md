# AI Process Documentation – Monthly Progress Change Report

## 1. Overview

The Monthly Progress Change Report API aggregates multiple AI-driven and data-driven services to generate a comprehensive monthly report for a customer’s Azure environment. It combines infrastructure snapshot data, Teams meeting insights, and architectural evaluation into a unified report and optionally stores the result in cloud storage.

---

## 2. API Purpose

This API provides:
- Consolidated monthly report of cloud environment changes
- AI-generated meeting insights (Teams transcripts summary)
- AI-driven architectural evaluation (Well-Architected Framework)
- Full environment snapshot for context
- Optional persistent storage of report

---

## 3. Components

### Core Components

- API Layer (entry point)
- Request Validator (`MonthlyProgressChangeReportRequestValidator`)
- Cloud Resource Snapshot Service (`GatherCloudResourceSnapshot`)
- Teams Transcript Summary Service (`SummaryTeamsMeetingTranscripts`)
- Architecture Evaluation Service (`EvaluationAgainstWellArchitectedFramework`)
- AI Orchestration (delegated to sub-services)
- Blob Storage (`_blobHelper`)
- JSON Serializer
- Response Aggregator

---

## 4. Workflow

### Step-by-step execution

1. Receive API request
2. Validate request parameters
3. Gather cloud resource snapshot:
   - Subscription metadata
   - Resource inventory
   - Governance and configuration data
4. Retrieve Teams meeting summary:
   - Calls transcript summarization API
5. Perform architectural evaluation:
   - Calls Well-Architected evaluation API
6. Aggregate results into unified report:
   - Snapshot + Transcripts + Evaluation
7. If StoreInCloud is true:
   - Serialize report to JSON
   - Upload to Blob Storage
8. Return report response

---

## 5. Data Flow

### Input

- SubscriptionId
- ResourceGroup
- CustomerId
- StartDate
- EndDate
- AIModelDeploymentName
- ResetCache
- StoreInCloud

### Processing Flow

Request
  ↓
Validate Input
  ↓
GatherCloudResourceSnapshot
  ↓
SummaryTeamsMeetingTranscripts
  ↓
EvaluationAgainstWellArchitectedFramework
  ↓
Aggregate Results
  ↓
  ├─ Cloud Resource Snapshot
  ├─ Teams Meeting Summary
  └─ Architecture Evaluation
  ↓
(Optional) Serialize Report (JSON)
  ↓
(Optional) Upload to Blob Storage
  ↓
Return Report

---

## 6. Component Interaction

| From | To | Purpose |
|------|----|--------|
| API Layer | Validator | Validate request |
| API Layer | Snapshot Service | Retrieve environment data |
| API Layer | Teams Summary Service | Retrieve AI-generated meeting insights |
| API Layer | Architecture Evaluation Service | Retrieve AI-driven evaluation |
| Snapshot Service | Azure APIs | Fetch resource data |
| Teams Service | Microsoft Graph API | Fetch transcripts |
| Evaluation Service | Azure OpenAI | Perform AI evaluation |
| Teams Summary Service | Azure OpenAI | Generate summary |
| API Layer | Blob Storage | Store report |
| API Layer | Response Model | Structure output |

---

## 7. Concurrency & Optimization

### Delegated AI Processing
- AI operations are handled by underlying services:
  - Transcript summarization
  - Architecture evaluation

### Modular Design
- Each major function is separated into reusable services
- Promotes scalability and maintainability

### Optional Storage
- Report persistence is optional via `StoreInCloud`
- Reduces unnecessary storage operations

---

## 8. Response Structure

### MonthlyProgressChangeReportResponse

- SubscriptionId
- ResourceGroup
- CustomerId
- CloudResourceSnapshot
- TeamsMeetingTranscripts
- EvaluationAgainstWellArchitectedFramework

---

## 9. Workflow Diagram

![Exports page](images/Workflow-GenerateMonthlyProgressChangeReport.png)
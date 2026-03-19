# AI Process Documentation – Compare Monthly Progress Change Report

## 1. Overview

The Compare Monthly Progress Change Report API compares two previously generated monthly reports and produces an AI-driven analysis of changes. It retrieves reports from cloud storage, constructs a structured comparison prompt, and leverages an AI model (Azure OpenAI) to generate insights on cloud resource changes and progress over time.

---

## 2. API Purpose

This API provides:
- AI-driven comparison between two monthly reports
- Summary of cloud resource changes
- Summary of Teams meeting progress changes
- Fully formatted report content for presentation

---

## 3. Components

### Core Components

- API Layer (entry point)
- Request Validator (`CompareMonthlyProgressChangeReportRequestValidator`)
- Memory Cache (`_memoryCache`)
- Database (Customer + Prompt Storage)
- Blob Storage (`_blobHelper`)
- Prompt Builder (template + report injection)
- AI Concurrency Control (`_aiSemaphore`)
- Azure OpenAI (Chat Completion API)
- Response Processor

---

## 4. Workflow

### Step-by-step execution

1. Receive API request
2. Validate request parameters
3. Retrieve customer information from database
4. Generate cache key
5. If ResetCache is true:
   - Clear memory cache
6. Check memory cache:
   - If exists → return cached result
7. Fetch base report from Blob Storage
8. Fetch comparison report from Blob Storage
9. Deserialize both reports
10. Retrieve prompt template from database:
    - PromptType = Report
    - PromptName = monthly-change-progress-report
11. Construct AI prompt:
    - Inject base report JSON
    - Inject comparison report JSON
    - Inject customer name and dates
12. Acquire AI semaphore:
    - Prevent excessive concurrent AI calls
13. Call Azure OpenAI
14. Release semaphore
15. Parse AI response (JSON format)
16. Build structured response
17. Store result in cache
18. Return response

---

## 5. Data Flow

### Input

- CustomerId
- SubscriptionId
- ResourceGroup
- BaseDate
- ComparisonDate
- AIModelDeploymentName
- ResetCache

### Processing Flow

Request
  ↓
Validate Input
  ↓
Fetch Customer (DB)
  ↓
Cache Key Generation
  ↓
Memory Cache Check
  ↓
Fetch Base Report (Blob)
  ↓
Fetch Comparison Report (Blob)
  ↓
Deserialize Reports
  ↓
Fetch Prompt Template (DB)
  ↓
Prompt Construction (Template Injection)
  ↓
AI Semaphore Control
  ↓
Azure OpenAI (Chat Completion)
  ↓
AI Response (JSON)
  ↓
Parse AI Output
  ↓
Structured Response
  ↓
Cache Storage
  ↓
Return

---

## 6. Component Interaction

| From | To | Purpose |
|------|----|--------|
| API Layer | Validator | Validate request |
| API Layer | Database | Fetch customer and prompt template |
| API Layer | Memory Cache | Retrieve/store result |
| API Layer | Blob Storage | Download reports |
| Blob Storage | API Layer | Return report JSON |
| API Layer | Prompt Builder | Construct AI input |
| API Layer | AI Semaphore | Control concurrency |
| API Layer | Azure OpenAI | Submit AI request |
| Azure OpenAI | API Layer | Return analysis |
| API Layer | Response Model | Structure output |

---

## 7. Concurrency & Optimization

### Caching
- Avoids repeated AI comparisons
- TTL-based expiration

### AI Concurrency Control
- Uses semaphore (`_aiSemaphore`)
- Prevents overload of AI service

### Reuse of Stored Reports
- Avoids recomputation by using persisted reports
- Improves efficiency and reduces cost

---

## 8. Response Structure

### CompareMonthlyProgressChangeReportResponse

- CustomerId
- CustomerName
- SubscriptionId
- ResourceGroup
- BaseDate
- ComparisonDate
- CloudResourceSummary
- TeamsMeetingNoteSummary
- FormattedContent

---

## 9. Workflow Diagram

![Exports page](../Images/Workflow-CompareMonthlyProgressChangeReport.png)
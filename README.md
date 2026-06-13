# Azure Serverless Data Ingestion Platform

## Overview

This repository contains Infrastructure as Code (IaC) for a secure, Azure-based serverless data ingestion platform built with Terraform.

The solution demonstrates how to build a production-oriented architecture using:

- Azure Logic Apps (Standard)
- Azure Storage Accounts
- Azure Key Vault
- User Assigned Managed Identities
- Private Endpoints
- Private DNS Zones
- Virtual Networks
- Azure RBAC

The platform is designed to securely ingest files from external sources (e.g., Outlook email attachments) into a landing storage account for downstream processing.

---

## Architecture

```text
External Source (Outlook, Email, APIs)
                 │
                 ▼
         Azure Logic App
                 │
                 │ Managed Identity
                 ▼
     Landing Storage Account
                 │
                 ▼
       Downstream Processing
```

All Azure services are accessed through Private Endpoints and remain isolated within a Virtual Network.

```text
┌─────────────────────────────────────────────┐
│ Resource Group                              │
│                                              │
│  ┌───────────────────────────────────────┐   │
│  │ Virtual Network                       │   │
│  │                                       │   │
│  │  ┌──────────────┐                     │   │
│  │  │ Logic App    │                     │   │
│  │  │ Subnet       │                     │   │
│  │  └──────┬───────┘                     │   │
│  │         │                             │   │
│  │         ▼                             │   │
│  │  ┌──────────────┐                     │   │
│  │  │ Private      │                     │   │
│  │  │ Endpoint     │                     │   │
│  │  │ Subnet       │                     │   │
│  │  └──────┬───────┘                     │   │
│  │         │                             │   │
│  │         ▼                             │   │
│  │  ┌──────────────┐                     │   │
│  │  │ Storage      │                     │   │
│  │  │ Accounts     │                     │   │
│  │  └──────────────┘                     │   │
│  │                                       │   │
│  │  ┌──────────────┐                     │   │
│  │  │ Management   │                     │   │
│  │  │ Subnet       │                     │   │
│  │  └──────────────┘                     │   │
│  └───────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

---

## Infrastructure Components

### Resource Group

A dedicated resource group hosts all resources required for the platform.

### Virtual Network

The platform uses a dedicated Virtual Network with network segmentation through multiple subnets:

| Subnet | Purpose |
|----------|----------|
| Logic App Subnet | VNet integration for Logic App Standard |
| Private Endpoint Subnet | Hosts all Private Endpoints |
| Management Subnet | Reserved for administration and future workloads |

### Storage Accounts

#### Backend Storage Account

Used internally by the Logic App Standard runtime.

Responsibilities:

- Workflow state management
- Runtime metadata
- Internal application storage

#### Landing Storage Account

Acts as the ingestion target for incoming files.

Responsibilities:

- Landing zone for uploaded files
- Data staging area
- Input for downstream processing pipelines

### Azure Logic App

The Logic App serves as the ingestion engine.

Example workflow:

1. Monitor an Outlook mailbox
2. Detect incoming emails
3. Extract attachments
4. Upload files to the Landing Storage Account

The Logic App authenticates using a User Assigned Managed Identity.

### User Assigned Managed Identity

A dedicated managed identity is attached to the Logic App.

Benefits:

- No secrets stored in code
- Centralized identity lifecycle management
- Native Azure authentication

### Azure Key Vault

Azure Key Vault is used to securely manage encryption keys and secrets.

Potential use cases:

- Customer-managed encryption keys (CMK)
- Application secrets
- Future credential storage

Access is controlled using Azure RBAC.

### Private Endpoints

Private Endpoints are deployed for:

- Backend Storage Account
- Landing Storage Account
- Key Vault

This ensures all communication remains on the Microsoft backbone network and avoids exposure through public endpoints.

### Private DNS Zones

Private DNS Zones provide name resolution for services exposed through Private Endpoints.

Examples:

| Service | Private DNS Zone |
|----------|----------|
| Blob Storage | `privatelink.blob.core.windows.net` |
| Blob Storage | `privatelink.web.core.windows.net` |
| Blob Storage | `privatelink.queue.core.windows.net` |
| Blob Storage | `privatelink.table.core.windows.net` |
| Blob Storage | `privatelink.file.core.windows.net` |
| Blob Storage | `privatelink.dfs.core.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |

Each zone is linked to the Virtual Network to allow workloads to resolve service endpoints to private IP addresses.

---

## Security Design

### Network Security

- Private Endpoints for supported services
- Dedicated Virtual Network
- Segregated subnet architecture
- Optional public network access disablement

### Identity-Based Authentication

The platform uses Managed Identities instead of shared secrets.

Benefits:

- Secretless authentication
- Reduced credential management overhead
- Improved security posture

### Role-Based Access Control (RBAC)

The Logic App Managed Identity receives only the permissions required to perform its tasks.

Example:

| Role | Scope |
|--------|--------|
| Storage Blob Data Contributor | Landing Storage Account |

This allows the Logic App to upload files while adhering to the principle of least privilege.

---

## Example Data Flow

```text
Outlook Mailbox
      │
      ▼
Azure Logic App
      │
      │ Managed Identity
      ▼
Landing Storage Account
      │
      ▼
Future Data Processing
```

---

## Deployment

The Terraform configuration deploys:

- Resource Group
- Virtual Network
- Subnets
- Logic App Standard
- User Assigned Managed Identity
- Backend Storage Account
- Landing Storage Account
- Azure Key Vault
- Private Endpoints
- Private DNS Zones
- RBAC Assignments

### Initialize Terraform

```bash
terraform init
```

### Review Planned Changes

```bash
terraform plan
```

### Deploy Infrastructure

```bash
terraform apply
```

---

## Future Enhancements

Potential platform extensions include:

- Azure Functions for data transformation
- Azure Data Factory pipelines
- Event Grid integration
- Azure Service Bus integration
- Microsoft Fabric connectivity
- Azure Monitor and Application Insights
- CI/CD using GitHub Actions
- Data Lake Gen2 processing patterns

---

## Design Principles

- Secure by default
- Private network access
- Identity-based authentication
- Least privilege authorization
- Infrastructure as Code
- Modular Terraform design
- Cloud-native architecture

---

## Repository Purpose

This project serves as a portfolio example demonstrating:

- Azure networking fundamentals
- Private Endpoint architecture
- Private DNS integration
- Managed Identity authentication
- Azure RBAC authorization
- Secure serverless data ingestion patterns
- Terraform-based infrastructure provisioning

The implementation reflects common enterprise cloud design patterns and can be extended into a production-grade data platform.
# 🔷 Microsoft Graph PowerShell Toolkit

A professional, production-ready collection of **PowerShell automation scripts** built around the [Microsoft Graph API](https://learn.microsoft.com/en-us/graph/overview). Designed to support scalable management and auditing across **Microsoft 365**, **Azure**, and **security & compliance services**.

> Maintained by [Krystian Wojno](https://github.com/267Abra) — with a mission to simplify Graph scripting, auditing, and automation.

---

## 🧭 Overview

Microsoft Graph is the unified API surface for managing Microsoft cloud services. This repository provides ready-to-use, extensible PowerShell tools leveraging the [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview).

These scripts are focused on **real-world automation, auditing, and access analysis** — ideal for enterprise administrators, security analysts, and DevOps engineers working across Microsoft 365 workloads.

---

## 📦 Supported Workloads

The toolkit includes (or plans to include) support for:

| Category                  | Description                                                              |
|---------------------------|--------------------------------------------------------------------------|
| **Microsoft Entra ID**    | User/group management, role assignments, policies, conditional access    |
| **Microsoft Intune**      | Device inventory, app policies, compliance status                        |
| **Microsoft Defender**    | Alerts, incidents, secure score, endpoint protection                     |
| **Microsoft Purview**     | Audit logs, eDiscovery, data lifecycle policies                          |
| **Exchange Online**       | Mailbox rules, calendar settings, message tracing                        |
| **Microsoft Teams**       | Teams, channels, members, chat & call logs                               |
| **SharePoint/OneDrive**   | Document libraries, file metadata, site enumeration                      |

> Scripts are modular and purpose-built to work in both **interactive** and **automation (CI/CD)** contexts.

---

## 🧰 Featured Tools

### 🔍 `Find-MGgraphPermission.ps1.ps1`
An interactive search tool for discovering Graph PowerShell commands.

- Search by keyword
- View associated URI, API version, HTTP method
- Automatically shows required **Graph permissions**
- Supports refining results interactively

### 🔒 `Entra-RoleAudit.ps1` *(coming soon)*
- List all users assigned to privileged roles
- Evaluate least-privilege and RBAC adherence
- Identify inactive or external role holders

### 💻 `Intune-DeviceInventory.ps1` *(coming soon)*
- Export compliant/non-compliant device lists
- Pull key properties: OS, model, ownership, status
- Supports CSV/JSON output for reporting

---

## ✅ Requirements

Ensure the following tools are installed:

- PowerShell 7.x+
- Microsoft Graph PowerShell SDK  
  [Install from PowerShell Gallery](https://www.powershellgallery.com/packages/Microsoft.Graph)

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes "User.Read.All", "Device.Read.All", "RoleManagement.Read.Directory", ...

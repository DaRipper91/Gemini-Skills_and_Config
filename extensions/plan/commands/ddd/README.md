# Legacy SQL to DDD Refactoring Pipeline

**Architecture:** .NET 10, C# 14, MediatR (CQRS), EF Core (Code-First), Google Cloud Run.
**Methodology:** Domain-Driven Design (DDD) via Test-Driven Development (TDD).

## 📋 Prerequisites

1.  **Command Setup:** Save the 7 prompts into your Gemini CLI configuration folder under a `ddd` directory (e.g., `~/.gemini/commands/ddd/`).
    *   `analyze.toml` (SQL Analysis)
    *   `logical.toml` (Logical Arch)
    *   `physical.toml` (Physical Arch)
    *   `plan.toml` (Implementation Plan)
    *   `implement.toml` (Build Agent)
    *   `review.toml` (Quality Gate)
    *   `fix.toml` (Remediation)
2.  **Target Environment:** .NET 10 SDK, Docker, VS Code/Rider.

## 🔄 The Workflow Overview

**CRITICAL:** This pipeline is state-sensitive. After every step, review the output artifact, then type `/clear` to reset the context window. This prevents "Context Pollution."

---

### Step 1: Deep Analysis
*Extracts business rules and test cases from the legacy Stored Procedure.*

*   **Command:** `/ddd:analyze {{path/to/legacy_proc.sql}}`
*   **Input:** Raw SQL file.
*   **Output:** `ANALYSIS_[ProcName].md`
*   **Human Action:** Review the "Data Dictionary" and "Verification/Test Cases" sections. Ensure no business logic was missed.
*   **Reset:** `/clear`

### Step 2: Logical Architecture
*Transforms the Analysis into a pure Domain Model (Aggregates, Entities, Rules).*

*   **Command:** `/ddd:logical {{ANALYSIS_[ProcName].md}}`
*   **Input:** The Analysis Markdown file.
*   **Output:** `LOGICAL_ARCHITECTURE.md`
*   **Human Action:** Check the **Traceability Matrix**. Ensure every `BR-###` from Step 1 has a home in the new design.
*   **Reset:** `/clear`

### Step 3: Physical Architecture
*Maps the Domain Model to .NET 10, MediatR, and EF Core patterns.*

*   **Command:** `/ddd:physical {{LOGICAL_ARCHITECTURE.md}}`
*   **Input:** Logical Architecture Markdown.
*   **Output:** `PHYSICAL_ARCHITECTURE.md`
*   **Human Action:** Verify the **Solution Tree** and **EF Core Code-First** strategy.
*   **Reset:** `/clear`

### Step 4: Implementation Planning
*Generates a step-by-step TDD execution plan with hygiene checks.*

*   **Command:** `/ddd:plan {{PHYSICAL_ARCHITECTURE.md}}`
*   **Input:** Physical & Logical Architectures.
*   **Output:** `IMPLEMENTATION_PLAN.md`
*   **Human Action:** Ensure "Phase 1" includes steps to delete `Class1.cs` and boilerplate.
*   **Reset:** `/clear`

### Step 5: Build & Implementation
*Executes the plan using strict Red-Green-Refactor TDD.*

*   **Command:** `/ddd:implement {{IMPLEMENTATION_PLAN.md}}`
*   **Input:** The Plan, plus read-access to all 3 Architecture/Analysis docs.
*   **Output:** Actual C# code in `src/` and tests in `tests/`.
*   **Human Action:** Monitor the TDD loop. The agent should output "Tests Passed" after every task.
*   **Reset:** `/clear`

---

## 🛡️ The Quality Assurance Loop

Once the code is built, do not ship it. Enter the **Review/Fix Loop**.

### Step 6: Code Review (Quality Gate)
*Audits the code for "Laziness", Stubbing, and missing Business Rules.*

*   **Command:** `/ddd:review`
*   **Input:** The full codebase + `ANALYSIS.md`.
*   **Output:** `REVIEW_REPORT.md`
*   **Status:** Look for `🔴 REJECT` or `🟢 PASS`.
*   **Reset:** `/clear`

### Step 7: Remediation (Self-Healing)
*If Step 6 failed, this agent fixes the specific issues listed in the report.*

*   **Command:** `/ddd:fix {{REVIEW_REPORT.md}}`
*   **Input:** The Review Report.
*   **Output:** Modified C# code.
*   **Next Step:** Go back to **Step 6** (`/ddd:review`) and run the Review again. Repeat until **PASS**.
*   **Reset:** `/clear`

---

## 📂 Artifacts Reference

| File | Purpose | Source of Truth For... |
| :--- | :--- | :--- |
| `ANALYSIS_*.md` | Legacy Deconstruction | **Test Data** (Inputs/Outputs) |
| `LOGICAL_*.md` | Domain Design | **Business Rules** (Invariants) |
| `PHYSICAL_*.md` | Tech Spec | **Structure** (Classes, MediatR) |
| `IMPLEMENTATION_*.md` | Task List | **Sequence** (What to do next) |
| `REVIEW_REPORT.md` | Audit Log | **Defects** (What to fix) |

## 💡 Pro Tips for Best Results
1.  **Read the Analysis:** The quality of the entire build depends on Step 1. If the Analysis misses a rule, the code will miss it too.
2.  **Don't Combine Contexts:** Always `/clear`. If you feed the Implementation Agent (`/ddd:implement`) the raw SQL from Step 1, it might hallucinate legacy patterns (like `DataSet`) into your clean .NET 10 code.
3.  **Code-First:** If the agent tries to write SQL scripts, stop it. Point to the `PHYSICAL_ARCHITECTURE.md` which mandates `IEntityTypeConfiguration`.
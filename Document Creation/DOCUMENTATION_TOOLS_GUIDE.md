# Comprehensive Documentation Guide

This guide outlines the best extensions and workflows for creating detailed documentation, user manuals, and step-by-step guides within the Gemini CLI environment.

## Recommended Extensions

### 1. Gemini Deep Research
**Best For:** Deeply detailed content, comprehensive user manuals, white papers, and complex "step-by-step" guides.

*   **Capabilities:** Analyzes entire codebases or external topics to generate extensive reports.
*   **Usage Example:**
    ```bash
    /research "Analyze the current codebase and write a comprehensive User Manual for the application, including installation, configuration, and usage examples."
    ```
    *   *Tip:* Specify `report_format` as "User Manual" or "Technical Guide".

### 2. Gemini Prompt Library
**Best For:** Standard project files like `README.md`, `CONTRIBUTING.md`, API documentation, and Changelogs.

*   **Capabilities:** Provides professionally crafted templates for documentation standards.
*   **Key Prompts:**
    *   `/prompts:write-readme`: Generates a standard, high-quality README.
    *   `/prompts:write-api-docs`: Creates structured API references.
    *   `/prompts:write-contributing`: Generates contribution guidelines.
    *   `/prompts:explain-concept`: Breaks down complex topics clearly.

### 3. Pickle Rick (Engineering Focus)
**Best For:** Product Requirement Documents (PRDs), Technical Specifications, and Architectural Overviews.

*   **Capabilities:** Focuses on *how* something works or *should* work from an engineering perspective.
*   **Relevant Skills:**
    *   `prd-drafter`: Creates detailed requirements documentation.
    *   `research-reviewer`: Ensures documentation objectivity and accuracy.

## Recommended Workflow for a "Perfect" User Manual

1.  **Investigate:**
    Use `gemini-deep-research` to fully analyze the project and generate a "Raw Knowledge Report".
    *   *Command:* `/research "Analyze the 'src' directory and explain every feature in detail for a user manual."`

2.  **Draft:**
    Ask the main agent to use that research to write specific `.md` files, adhering to your preferred style.
    *   *Command:* "Using the research report, write a `USER_MANUAL.md` aimed at non-technical users."

3.  **Standardize:**
    Use `/prompts:write-readme` to ensure your repository's entry point (`README.md`) is polished and links to your new deep documentation.

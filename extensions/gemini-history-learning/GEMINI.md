# Gemini History Learning Extension

## Overview
This extension helps users manage and learn from their Gemini session history. It provides tools to locate history files, export them for external use, and analyze them for process improvements.

## Core Concepts

### Project Hash
Session history is stored in a directory named after the SHA256 hash of the project's absolute path.
- **Storage Path:** `~/.gemini/tmp/<PROJECT_HASH>/chats/`
- **Calculation:** `echo -n "<ABSOLUTE_PROJECT_PATH>" | shasum -a 256`

## Command Protocols

### 1. Export Protocol (`/history:export`)

**Objective:** specific session data to a usable format in the current directory.

**Steps:**
1.  **Identify Project:** Calculate the SHA256 hash of the current working directory.
2.  **Locate History:** List files in `~/.gemini/tmp/<HASH>/chats/`.
3.  **Select Session:** Pick the most recent session file (`session-<timestamp>-<id>.json`) unless a specific one is requested.
4.  **Transform & Save:**
    *   **JSON:** Copy the file directly.
    *   **Markdown:** Convert to a readable transcript (User > ... 
 Gemini > ...).
    *   **CSV:** Create columns: `Timestamp`, `Type` (User/Gemini), `Message`.
5.  **Output:** Save as `export-<timestamp>.<ext>` in the current directory.

### 2. Analysis Protocol (`/history:analyze`)

**Objective:** Review interactions to improve the AI agent's configuration.

**Analysis Criteria:**
*   **Friction Points:** Look for user messages starting with "No", "Incorrect", "Stop", or clarifying instructions. These indicate the System Prompt (`GEMINI.md`) needs better definitions.
*   **Tool Failures:** Identify `toolCalls` with error statuses. Suggest logic fixes.
*   **Efficiency:** Identify tasks that took too many turns. Suggest a new custom command or improved prompt to handle it in one go.

**Output Format:**
Produce a structured report:
```markdown
# Session Analysis Report

## Key Insights
- [Insight 1]
- [Insight 2]

## Recommended Actions
1. Update `GEMINI.md` to include...
2. Modify command X to handle...
```

### 3. Hash Protocol (`/history:hash`)

**Objective:** Quickly verify where data is being stored.
**Action:** Execute the shell command to verify and display the hash and the full path to the history directory.

```
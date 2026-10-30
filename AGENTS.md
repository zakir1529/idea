# Zyro Inventory Engineering Rules & Quality Standards

## 1. Zero-Regression & Holistic Implementation
- **Never Break Existing Features**: Adding or updating any functionality must NEVER break, regress, or degrade existing working features (e.g., two-way sync between Store and WooCommerce, search retention, POS checkout, local storage persistence, database triggers, or webhooks).
- **Comprehensive Impact Analysis**: Before making changes, analyze all callers, listeners (`window.addEventListener`), event dispatches (`inventoryUpdate`, `attributesUpdate`), and data layers.
- **Holistic Alignment**: If adding a feature impacts other components, proactively update, adjust, and correctly implement all affected parts together so the entire application functions reliably.
- **End-to-End Verification**: Always verify that existing core flows (sales, stock deductions, sync, UI rendering) continue to work flawlessly after any modification.

## 2. Lean, Minimal & Optimal Solutions (No Code Bloat)
- **Eliminate Over-Engineering**: Always select the most minimal, optimal, and direct solution. Never write 100-200 lines of bloated code, duplicate helpers, or unnecessary layers of abstraction for simple tasks.
- **Surgical, Non-Invasive Edits**: Keep changes concise, targeted, and clean. Preserve established conventions and avoid modifying unrelated code.
- **Optimal Resource Footprint**: Avoid duplicate network calls, duplicate event listeners, or excessive polling loops.

## 3. Respect User Workflow Control
- **Analyze First, Act Later**: When the user says "analyze", "check", "identify", "diagnose", or "tell me" — ONLY report findings. Do NOT make any code changes, create implementation plans, or execute fixes until the user explicitly says "proceed", "fix it", "do it", or "go ahead".
- **No Unsolicited Execution**: Never auto-execute changes after analysis. Always stop after reporting and wait for the user's explicit green light.
- **Be Fast & Direct**: For simple tasks, get straight to the point. Do not spawn subagents, create unnecessary artifacts, or over-research obvious problems. If a fix is 5 lines, just do it — don't write a 200-line plan first.

## 4. Interactive Workflow Rules (Claude-Code Style)
- **Narrate Before and After Every Action**: Before running a tool, command, or edit, state in one short sentence what you're about to do and why. After it finishes, briefly summarize the result before moving on. Silent multi-step execution is not allowed.
- **Stop at Decision Points — Don't Guess Silently**: Whenever a task has more than one reasonable way to proceed, stop and ask instead of choosing silently.
- **Present Options in a Numbered, Branching Format**: When asking, provide 2–4 concrete, mutually exclusive options (e.g. `1.`, `2.`) that the user can pick by number, plus an open choice.
- **Treat Ambiguity as a Stop Condition**: If a request could reasonably mean two different things, ask before writing code.
- **Checkpoint Before Risky or Destructive Steps**: Before deleting files, overwriting data, running migrations, or any destructive action, describe what will happen and wait for explicit confirmation.
- **Keep Narration Short**: 1–2 sentences per step to ensure visibility without bloat.
- **End with a Plain-Language Summary**: When a task finishes, summarize what changed, which files were touched, and any follow-ups needed.

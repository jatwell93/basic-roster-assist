🤖 Directing Your Agent to a New Task with Beads You're absolutely right! Now
that you've integrated your tasks into Beads, your interaction with the agent
will shift from pointing to static markdown files to directing it to the dynamic
Beads issue tracker. Here’s how you would instruct your agent to start a new
task:

Agent's Primary Task: Your primary instruction to the agent should be to continuously consult Beads for its next task. This makes Beads the central source of truth for all work items.
General Instruction (for AGENTS.md or initial prompt): You should update your AGENTS.md or initial prompt to instruct the agent to regularly check for ready work in Beads.
Example instruction for AGENTS.md:
markdown

```bash
    ### 🚀 Your Workflow with Beads

    1.  **Find Ready Work**:
        -   Start by running `bd ready --json` to identify unblocked tasks. Prioritize issues with higher urgency (e.g., P0, P1).
        -   If `bd ready` is empty, check `bd list --status open --priority-min 0 --priority-max 1 --json` for high-priority open issues that might be blocked, and ask for clarification if needed.
    2.  **Claim a Task**:
        -   Once you've selected a task (e.g., `bd-a1b2`), claim it by updating its status: `bd update bd-a1b2 --status in_progress --json`.
    3.  **Execute Task**:
        -   Work on the task, implementing, testing, and documenting as required.
        -   If you discover new work during this process, **always create a new Beads issue** linked to the current task using `bd create "Discovered bug" --description="Details" -p 1 --deps discovered-from:bd-a1b2 --json`.
    4.  **Complete Task**:
        -   When done, close the issue: `bd close bd-a1b2 --reason "Completed" --json`.
    5.  **Sync**:
        -   **Crucially, at the end of every work session or significant milestone, run `bd sync`** to flush and commit all changes to Git.
```

Specific Direction (for a single task): If you want the agent to work on a particular task immediately, you can combine listing and updating, or directly give the ID:
Option 1: Point to "Ready Work": "Agent, please read AGENTS.md and then find the next ready task using bd ready. Claim it and begin work."
Agent action: bd ready --json, pick an ID, then bd update <id> --status in_progress --json.
Option 2: Assign a Specific ID: "Agent, please start working on issue bd-a1b2. Update its status to in_progress and proceed with the implementation."
Agent action: bd update bd-a1b2 --status in_progress --json, then proceed based on the issue's description.
Option 3: Find a task by keywords: "Agent, I'd like you to work on implementing the user authentication. Use bd list --title-contains "user authentication" --status open --json to find relevant issues, pick the highest priority one, claim it, and begin."
Agent action: bd list with filters, pick ID, then bd update <id> --status in_progress --json.

By shifting your instructions to revolve around bd commands, you enable your
agent to leverage Beads' capabilities for long-term planning, dependency
tracking, and consistent work management across sessions.

## Notes
1. You need to make sure openspec is getting updated at the end of each session with beads. beads only had 7 task out of 22 and might have been missing more. Openspec had not been updated with 0/22 of the tasks done. No change logs were being used. Need to simplify the state machine and add in openspec checkpoints. Implement beads viewer. Remove ubs and just run it here and there.
2. 
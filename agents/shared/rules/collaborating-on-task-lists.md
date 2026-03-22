# Working with Users On a Shared Task List

If a TODO.md file is present in the project root, or the current directory of a monorepo, consider it a shared task list for the project. Most coding agents have internal task management tools, but these are often opaque to the user, only accessible inside of sessions, and rely on natural language descriptions of tasks, rather than directly writing a detailed spec. A TODO.md file is a simple, explicit, and user-friendly way to track tasks and progress on a project. The easiest way to manage this is to define a specific file and syntax for collaborating, so that both users and agents can do whatever they need to do internally to execute, but have a shared surface to manage the project together.

## The POT system

These lists use a hierarchical system composed of Phases, Objectives, and Tasks (POT). The highest level is the Phase, which is a sequential stage of the project. Within each Phase, there is at least one Objective (usually several), these are declarative goals that group tasks based on what they are actually trying to achieve in the output — for example, "Add passkey generation endpoint", "Restructure top nav bar". Lastly, there are the imperative, granular Tasks, the individual steps you will take to complete the Objective. Phases and Objectives are h2s and h3s, respectively, and Tasks are markdown checkboxes. This structure, P > O > T, allows for clear organization, sequencing, and progress tracking.

### Phases

Phases are sequential, numbered sets of tasks, separated by h2 markdown headers in the format `Phase 1: <description>`, `Phase 2: <description>`, etc. These are the largest unit of the TODO.md, and act primarily as a sequencing system. The active phase must be marked with 🌀, and completed phase marked with ✅. **NEVER** continue on to a non-active phase unless discussed with the user. **ALWAYS** mark the phase as active _first_ after approval for kicking off the next phase, then start working.

### Objectives

Group of tasks towards a specific output goal are Objectives. There can be as many objectives in a phase as needed, the only requirement is that they can be executed in parallel. Every objective in a phase should be independent — an agent team should be able to assign an agent to each objective and have them tackle it on their own worktree, then bring it back together to complete the phase. If there is an objective in a phase that blocks another, or is waiting on output from another objective inside the same phase, that should be split out to a different phase.

#### An example using baking

Say you want to make cookies, and write up a task list. Group A is mise-en-place, getting brown butter made, preheating the oven, putting parchment paper on the sheet pan, etc. Group B is mixing the dry ingredients. Group C is mixing the wet ingredients. Group D is mixing the wet and dry together, then chilling the dough. Group E is baking and cooling the cookies.

If we had finished Phase 1 and were getting ready to mix the dough, the TODO.md might look like this:

```markdown
# Cookie Baking Project Task List

## Phase 1: Setup and preparation ✅

### mise-en-place

- [x] Set wet ingredient out on counter, let egg get to room temperature
- [x] Preheat oven to 350 degrees F
- [x] Line sheet pan with parchment paper
- [x] Make brown butter

### Mixing dry ingredients
- [x] Measure out flour, baking soda, salt, and any spices, mix together in a bowl
- [x] Sift together dry ingredients

### Mixing wet ingredients

- [x] Measure out butter, sugars, and any wet spices, mix together in a bowl
- [x] Add egg and vanilla, mix until fully incorporated

## Phase 2: Mixing and chilling 🌀
- [ ] Add dry ingredients to wet, mix until just combined
- [ ] Chill dough for 2 hours in the fridge

## Phase 3: Baking and cooling

- [ ] Bake cookies for 10-12 minutes, until edges are golden brown
- [ ] Let cookies cool on sheet pan for 5 minutes, then transfer to cooling rack
- [ ] Store cooled cookies in an airtight container
```

If you had 3 friends (i.e. an agent team) you could tackle the 3 objectives in Phase 1 in parallel, but you could not move on to Phase 2 until Phase 1 is done, nor Phase 3 until Phase 2 is done. This structure allows for clear sequencing, parallelization, and progress tracking.

If a user says "let's tackle phase 2" you'd look to see if there are multiple objectives, and if so try to handle them in parallel. If a user requests work at the objective-scope, like "can you knock out the passkey generation update", you would look for an h3 referencing passkey generation, confirm it's inside an active phase (if not, double-check with the user before proceeding), and then execute the tasks under that h3. Whether the granular tasks within an objective should be sequential or parallel is up to you, the TODO.md POT system is meant to be a high-level project tool that speeds up collaboration, not something to restrict or micromanage your capabilities, so use your judgement on how to execute the work once you've identified the objective(s) to work on.

## Working with the POT TODO.md system

### Externalizing Plans and Ad Hoc Tasks to the TODO.md

If, at the end of a Plan Mode session, the user asks you to save the plan into a file for the project ("Awesome, let's make this the TODO.md for the project", "Let's add this plan to the task list"), this is the format you should use. If no TODO.md exists, you should create it in this scenario. If there is an existing TODO.md, make sure to consider where to put the output: are their multiple chunks of work that could be executed in parallel in your plan? Make it a phase and group those as objectives. Similarly, if the user asks you to add something from an ad hoc discussion to the task list, this is the file and format you should use. Make sure you consider where it should be placed in the P > O > T hierarchy when you do that.

### User Tasks

Tasks or Objectives tagged with #user can be skipped, they are meant for the user to handle (often things like reorganizing directories, installing dependencies outside of the sandbox, setting up deployments on a cloud platform, etc.) If they are blocking in the POT sequence, **STOP** and alert the user that you're blocked until they complete the task, do not try to complete it yourself or just skip past it.

### Clarifying and Improving Tasks

If a task's (or phase's or objective's) wording feels ambiguous, and there are multiple valid approaches you're considering, it's absolutely fine to pause and ask for clarification. After getting clarification, you should also update the task language to preserve the clarity from the discussion.

You should also feel safe to suggest improvements. If an objective is taking an approach you think could cause problems down the line, is not secure, or is overly complex and could be simplified, it's good to flag that and suggest a new approach. If the user agrees, update the TODO.md to reflect the new approach.

### Capturing Ad Hoc Requests

When the user requests ad hoc objectives and tasks in a project with a TODO.md, after completion you should check to see if there's a good place to record them in the TODO.md. If so, add it as a completed markdown checkbox task in the appropriate section. This enables a better record for future sessions and agents to work with, and also allows the user to keep track of these things in a single place. There's no need to record every little change — changing a button from blue to pink to green and finally to a different shade of blue, does not require recording 3 separate tasks — but if there's an objective called 'Improve colors for interactive UI elements', adding a completed task under that heading that captures the final state is a good idea. It's often a good idea to wait until the end of a session when you're updating docs and memory to add these ad hoc tasks, so you're not accidentally inserting intermediate state thrash into the task log of the project. If a project does not have an ADRs file, the TODO.md is also a good place to add context on decisions related to the phases, objectives, and tasks.

### Completing a Phase

When all tasks in a phase are complete, mark the phase as completed with ✅, and then ask the user if they want to move on to the next phase. If they say yes, mark the next phase as active with 🌀, and start working on it. Before you mark the phase with the completed emoji, do a quick review of the objectives and tasks to make sure they accurately reflect the work that was done. If a different approach than originally planned was taken for some objectives, you should update the tasks and language to reflect that state, rather than leaving completed tasks in the file that don't actually map to existing work. The same is true of objectives and tasks themselves. The best time to update task or objective language is right after completion, as this is when you will have the most context.

---
name: fish-function-error-handling
description: Patterns and best practices for handling errors in fish shell functions or scripts, including status propagation, stderr reporting, pipelines, and composing higher-level error messages (e.g., prefixing curl errors).
compatibility:
    fish: ">=3.0"
allowed-tools:
    - none
---

# Purpose

Provide reliable, idiomatic patterns for handling failures in fish functions:

* Test success/failure of commands
* Preserve and propagate exit codes
* Decide whether to bubble up errors vs emit your own higher-level error
* Capture and reframe underlying stderr (e.g., `ERROR: Not Authorized: [curl error]`)
* Handle pipeline failure semantics using `$pipestatus`

---

## Core concepts

### Exit status

* Every command exits with a numeric status.
* In fish, the last command’s exit status is available as `$status`.
* Convention:
  * `0` = success
  * non-zero = failure

### stderr vs stdout

* Print errors to stderr using `logirl`:
  * `logirl error "message"` — automatically routes to stderr
* Keep stdout for real output that callers might capture or pipe.
* Use `logirl` for all user-facing messages to ensure consistent formatting.

### Functions return statuses

* `return N` sets the function’s exit status to `N`.
* Without an explicit `return`, a fish function typically exits with the status of the last command executed inside it (so be intentional).

---

## Pattern 1: Put a command directly in an `if` condition

```fish
function fetch_data --argument url
    if curl -fsS $url -o data.json
        logirl success "Data fetched successfully"
    else
        logirl error "Failed to fetch $url"
        return 1
    end
end
```

### Why it’s good

* Tight coupling between the command and the branching logic.
* Avoids accidentally overwriting `$status` before checking it.
* Readable for a single “try then branch” step.

### What it does *not* do

* It tests only “exit status == 0”, not output content.
* With pipelines, the “status you see” depends on pipeline semantics (see pipeline section).

---

## Pattern 2: `and` / `or` chaining (idiomatic fish)

### Guard clause: “fail fast”

```fish
function must_exist --argument path
    test -e $path; or begin
        logirl error "Missing path: $path"
        return 2
    end
end
```

### Wrap-and-bubble: propagate underlying status

```fish
some_command; or return $status
```

### Wrap-and-handle with a block

```fish
curl -fsS https://example.com/data -o data.json
and logirl success "Download complete"
or  begin
        logirl error "Download failed"
        return 1
    end
```

### Notes

* `and` runs only if the previous command succeeded.
* `or` runs only if the previous command failed.
* Use `begin ... end` when failure handling needs multiple statements.

---

## Pattern 3: Run a command, then check `$status` (capture immediately)

Use this when you need the status later or want to branch on multiple status values.

```fish
function example_status_capture
    curl -fsS https://example.com/data -o data.json
    set -l st $status

    if test $st -ne 0
        logirl error "curl failed (status $st)"
        return $st
    end

    logirl success "Data retrieved successfully"
end
```

### Key rule

* `$status` can be overwritten by the very next command, so store it immediately:
  * `set -l st $status`

---

## Other useful patterns

### Switch on status for tailored messaging

```fish
some_command
set -l st $status

switch $st
    case 0
        logirl success "Operation complete"
    case 2
        logirl error "Usage problem"
        return $st
    case '*'
        logirl error "Failed with status $st"
        return $st
end
```

---

## Pipelines: status and `$pipestatus`

### The problem

In a pipeline like:

```fish
cmd1 | cmd2
```

the exit status you see as `$status` is typically the pipeline’s overall status behavior (often effectively the last command’s status). This can mask failures in earlier stages.

### The fix: use `$pipestatus`

After running a pipeline, fish provides `$pipestatus`: a list of statuses for each pipeline command, in order.

```fish
cmd1 | cmd2
set -l ps $pipestatus
# ps[1] corresponds to cmd1, ps[2] to cmd2
```

### Practical handling

If pipeline failure matters, explicitly validate all stages:

```fish
cmd1 | cmd2
set -l ps $pipestatus

if contains -- 1 2 3 4 5 6 7 8 9 $ps
    logirl error "Pipeline failed: $ps"
    return 1
end
```

Notes:

* This is a pragmatic “any non-zero” check for common small exit codes.
* For fully general checking, iterate and test each entry for non-zero.

---

## Bubble up errors vs report higher-level errors

### Bubble up (preserve underlying exit code)

Use this when your function is a thin wrapper and callers should see the original failure:

```fish
some_command; or return $status
```

Or with a custom message but same status:

```fish
some_command
set -l st $status

test $st -eq 0; or begin
    logirl error "some_command failed"
    return $st
end
```

### Report your own higher-level error (choose your own status)

Use this when you’re providing a semantic operation and want stable “API-like” behavior:

```fish
if not some_command
    logirl error "Not Authorized"
    return 1
end
```

Guidelines:

* Use `logirl error` for error messages (automatically routes to stderr).
* Use status codes consistently:
  * `1` generic failure
  * `2` usage / bad arguments (common convention)
  * Otherwise bubble up when it's meaningful.

### Combine: own message + preserve underlying status

Often best UX:

```fish
some_command
set -l st $status

if test $st -ne 0
    logirl error "Not Authorized (underlying status $st)"
    return $st
end
```

---

## Composing errors: prefix your own message + include the underlying error text (curl)

Goal:

`ERROR: Not Authorized: [error from curl]`

### Robust approach: capture curl’s stderr and reprint with prefix

```fish
function fetch_protected --argument url
    set -l err (curl -fsS $url -o /dev/null 2>&1)
    set -l st $status

    if test $st -ne 0
        logirl error "Not Authorized: $err"
        return $st
    end
end
```

Notes:

* `2>&1` captures stderr into `err`.
* `-sS` keeps output quiet on success while still emitting errors.
* `-f` makes HTTP 4xx/5xx exit non-zero, which is usually what you want for error handling.

---

## Recommended conventions (quick checklist)

* Use `logirl error "..."` for error messages (automatically routes to stderr).
* Use `logirl warning "..."` for non-fatal issues.
* Use `logirl success "..."` for successful completion messages.
* Use `logirl info "..."` for neutral status updates.
* Prefer guard clauses for preconditions:
  * `test ...; or begin; logirl error "..."; return ...; end`
* If you need the exit status later, capture it immediately:
  * `set -l st $status`
* Decide intentionally whether your function should:
  * bubble up underlying statuses (`return $st`)
  * or map failures to a stable status (`return 1`, `return 2`, etc.)
* Avoid relying on bare `$status` after pipelines; use `$pipestatus` when pipeline correctness matters.

---

## Copy/paste snippets

### Minimal wrapper that bubbles up failures

```fish
function wrap
    some_command $argv; or return $status
end
```

### Guard clause template

```fish
function myfn --argument arg
    test -n "$arg"; or begin
        logirl error "Missing required argument: <arg>"
        logirl info "Usage: myfn <arg>"
        return 2
    end
end
```

### Prefix underlying stderr template

```fish
function myfn
    set -l err (some_command 2>&1)
    set -l st $status

    if test $st -ne 0
        logirl error "myfn failed: $err"
        return $st
    end
end
```

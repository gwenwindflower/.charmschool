---
name: yuzudraw-ascii-diagrams
description: Make clean, creative ASCII diagrams, graphs, and flow charts with YuzuDraw
---

# Create Diagrams in YuzuDraw

YuzuDraw is an ASCII diagramming tool with a custom DSL, a CLI (`yuzudraw-cli`), and a macOS GUI for manual refinement.

## Workflow

1. Classify the request into a diagram family (see below).
2. Open the matching reference file and follow its defaults.
3. Render via CLI using a heredoc with `--dsl-stdin` (see CLI Rules).
4. Display the rendered ASCII in a fenced code block so the user sees it directly.
5. Ask the user if they'd like to save (`create-diagram` or `update-diagram`).

## CLI Rules

Every call MUST start with `yuzudraw-cli` (for allowlisting). Pass DSL inline via heredoc — no temp files, no pipes, no `cat`/`echo`.

```bash
yuzudraw-cli render-ascii --dsl-stdin <<'EOF'
rect "hello" id box at 5,5 size 10x3
EOF
```

```bash
yuzudraw-cli create-diagram --name <name> --dsl-stdin <<'EOF'
...DSL...
EOF
```

```bash
yuzudraw-cli update-diagram --name <name> --dsl-stdin <<'EOF'
...DSL...
EOF
```

## Family Selection

Choose one dominant family per request. If the user names a family explicitly, use it.

| Family | Reference | Use when |
| --- | --- | --- |
| Architecture | [architecture.md](./architecture.md) | System topology, regions, tiers, cross-boundary relationships |
| Components | [components.md](./components.md) | Modules, interfaces, APIs, ownership boundaries |
| Flow | [flow.md](./flow.md) | Workflows, pipelines, ordered steps, branching, state transitions |
| Bar chart | [bar-chart.md](./bar-chart.md) | Comparisons, ranked values, before/after metrics, stacked bars |
| ASCII art | [ascii-art.md](./ascii-art.md) | Illustrations, icons, scenes, mascots, decorative callouts |

**Mixed requests:** architecture wins if structure matters most, components if internal parts matter most, flow if order matters most, bar-chart if comparison matters most, ascii-art if illustration is the deliverable.

## Composition Rules

- Start around `col 2-4`, `row 1-2` to leave a buffer.
- Use groups (framed regions with `style double` or `style heavy`) whenever there are 2+ logical categories.
- Use shading semantically, not decoratively. Use `pencil` sparingly unless the reference calls for it.
- Match an existing diagram's composition first when asked for "a diagram like X."

## DSL Quick Start

The family references contain enough DSL examples to build most diagrams. For full syntax details (all properties, reference coordinates, element IDs, auto-sizing rules), see [dsl-reference.md](./dsl-reference.md).

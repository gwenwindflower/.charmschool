# YuzuDraw DSL Reference

Load this when you need specifics on DSL syntax beyond what the family references demonstrate.

## Document Structure

```bash
layer "Layer Name" visible|hidden [locked]
  [group "Group Name"]
    <shapes...>
```

- One or more layers; each layer has shapes and optional groups
- Indentation is 2 spaces per level
- Rects must be defined before arrows that reference them

## Rectangle (`rect`)

```bash
rect "Label" [id NAME] [at col,row] [size WxH] [POSITION] [PROPERTIES...]
```

Also accepts `rectangle` and `box` as aliases.

**Positioning** (pick one):

- `at col,row` — absolute position
- `at REF.SIDE+colOffset,rowOffset` — reference coordinates (see below)
- `right-of REF [gap N]` — to the right of another rect (default gap: 4)
- `below REF [gap N]` — below another rect (default gap: 2)
- `left-of REF [gap N]` — to the left (accounts for self width)
- `above REF [gap N]` — above (accounts for self height)
- Omitted → defaults to `0,0`

**Auto-sizing** (when `size` is omitted):

- `width = max(longestLine + 4, 10)`
- `height = lineCount + 2`
- Use `\n` for multiline labels

**Properties** (all optional, defaults shown):

| Property | Default | Syntax |
| --- | --- | --- |
| style | single | `style single\|double\|rounded\|heavy` |
| fill | transparent | `fill solid char "x"` |
| border | visible | `noborder` to hide |
| borders | all | `borders top,bottom,left,right` |
| line | solid | `line dashed dash N gap N` |
| halign | center | `halign left\|center\|right` |
| valign | middle | `valign top\|middle\|bottom` |
| textOnBorder | false | `textOnBorder` (bare flag = true) |
| padding | 0,0,0,0 | `padding L,R,T,B` |
| shadow | none | `shadow light\|medium\|dark\|full x N y N` |
| borderColor | none | `borderColor #RRGGBB` |
| fillColor | none | `fillColor #RRGGBB` |
| textColor | none | `textColor #RRGGBB` |
| float | false | `float` |

## Arrow

```bash
arrow from ENDPOINT to ENDPOINT [style single|double|heavy] [label "text"] [strokeColor #RRGGBB] [labelColor #RRGGBB] [float]
```

**Endpoint formats:**

- `"Label".side` — named attachment (side: left, right, top, bottom)
- `"Label"` — auto-infers side from relative position
- `col,row` — absolute coordinates
- `ID.side` or bare `ID` — reference by element ID

Arrow style defaults to `single` (omitted in serialized output).

### Side Inference

When endpoints omit `.side`, sides are auto-inferred by comparing center points. Dominant axis wins (larger absolute delta). Each endpoint uses the side facing the other rect. Tied → prefer horizontal.

## Text

```bash
text "content" at col,row [textColor #RRGGBB]
```

Use `\n` for newlines. Supports reference coordinates in `at`.

## Pencil

```bash
pencil at col,row cells [col,row,"char";col,row,"char",#color;...]
```

Freeform characters at relative offsets. Supports reference coordinates in `at`.

## Element IDs

Optional `id` keyword for naming elements:

```bash
rect "Server" id srv1 at 0,0 size 14x3
rect "Server" id srv2 at 20,0 size 14x3
```

- Format: `[a-zA-Z_][a-zA-Z0-9_]*` (no keywords like `at`, `size`, `style`, etc.)
- Unquoted reference = ID lookup: `at srv1.right+4,0`
- Quoted reference = label lookup: `at "Server".right+4,0`
- Required for: empty labels, duplicate labels
- Optional for: unique non-empty labels

## Reference Coordinates

Position any element relative to a rect's edges:

```bash
at REF.SIDE+colOffset,rowOffset
```

**Edge reference points:**

- `.right` → `(ref.col + ref.width, ref.row)`
- `.bottom` → `(ref.col, ref.row + ref.height)`
- `.left` → `(ref.col, ref.row)` (same as origin, for readability)
- `.top` → `(ref.col, ref.row)` (same as origin, for readability)

Offset defaults to `+0,0` when omitted. Negative offsets supported (e.g., `"A".right-4,0`).

## Serialization Defaults

Properties at default values are omitted from serialized output:

| Property | Default |
| --- | --- |
| `style` | single |
| `fill` | transparent |
| `border` | visible |
| `halign` | center |
| `valign` | middle |
| `textOnBorder` | false |
| `padding` | 0,0,0,0 |
| arrow `style` | single |

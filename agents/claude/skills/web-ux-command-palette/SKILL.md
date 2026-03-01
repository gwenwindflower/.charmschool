---
name: web-ux-command-palette
description: "Build keyboard-driven command palettes using cmdk + shadcn/ui. Use when: (1) Adding command palette to web apps, (2) Implementing keyboard navigation, (3) Building spotlight-style search, (4) Setting up cmdk with shadcn components."
---

# Command Palette Pattern

## Overview

Build performant, keyboard-first command palettes using cmdk (the industry standard) with shadcn/ui components.

**Why cmdk + shadcn:**

- De facto standard (Vercel, Linear, Raycast-style UIs)
- Built-in fuzzy search
- Accessible (Radix Dialog primitives)
- Keyboard-first design

## Core Components

| Component | Purpose |
| --- | --- |
| `CommandDialog` | Modal wrapper (Dialog + Command) |
| `CommandInput` | Search input with icon |
| `CommandList` | Scrollable results container |
| `CommandEmpty` | "No results" state |
| `CommandGroup` | Categorized sections with headings |
| `CommandItem` | Individual selectable items |
| `CommandSeparator` | Visual divider between groups |
| `CommandShortcut` | Keyboard shortcut hint display |

## Basic Structure

```tsx
<CommandDialog open={open} onOpenChange={setOpen}>
  <CommandInput placeholder="Type a command..." />
  <CommandList>
    <CommandEmpty>No results found.</CommandEmpty>
    <CommandGroup heading="Navigation">
      <CommandItem onSelect={() => navigate('/home')}>
        <HomeIcon /> Home
      </CommandItem>
    </CommandGroup>
  </CommandList>
</CommandDialog>
```

## Keyboard Shortcuts

**Standard bindings:**

- `Cmd+K` / `Ctrl+K` - Open/close (standard convention)
- `/` - Open (when not in input field)
- `Escape` - Close
- Arrow keys - Navigate
- `Enter` - Select

**Implementation:**

```tsx
useEffect(() => {
  const handler = (e: KeyboardEvent) => {
    if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
      e.preventDefault();
      setOpen(prev => !prev);
    }
    if (e.key === '/' && !isInputFocused(e.target)) {
      e.preventDefault();
      setOpen(true);
    }
  };
  document.addEventListener('keydown', handler);
  return () => document.removeEventListener('keydown', handler);
}, []);

function isInputFocused(target: EventTarget | null): boolean {
  return target instanceof HTMLElement &&
    ['INPUT', 'TEXTAREA', 'SELECT'].includes(target.tagName);
}
```

## Search Index Patterns

**Static sites:**

- Build index at compile time
- Pass as props to component

**Dynamic:**

- Fetch on mount or use server action

**Structure:**

```typescript
interface SearchItem {
  title: string;
  description?: string;
  href: string;
  type: string;  // e.g., "page", "blog", "command"
  keywords?: string[];
}
```

**cmdk search:**

- Searches the `value` prop on `CommandItem`
- Include searchable text in value: `value={title + ' ' + keywords?.join(' ')}`

## Styling Customization

**Height:**

```tsx
<CommandList className="max-h-[300px]">
```

**Dialog position:**

- Centered by default via `DialogContent`

**Item states:**

```tsx
<CommandItem className="data-[selected=true]:bg-accent">
```

## Accessibility

**Built-in:**

- Focus trap (Radix Dialog)
- Escape/click-outside handling
- Arrow navigation (cmdk)
- Screen reader announcements

**Ensure:**

- Visible focus indicators
- Meaningful item labels
- Icon-only items have aria-label

## External Resources

- cmdk docs: <https://cmdk.paco.me/>
- shadcn Command: <https://ui.shadcn.com/docs/components/command>
- Radix Dialog: <https://www.radix-ui.com/primitives/docs/components/dialog>

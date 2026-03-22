---
name: shadcn-ui
description: "Guide for working with shadcn/ui components in any project. Use when: (1) Adding shadcn components, (2) Customizing components with variants or styles, (3) Understanding the shadcn system architecture, (4) Troubleshooting shadcn setup or styling issues."
---

# shadcn/ui Components

## Overview

shadcn/ui is a collection of copy-paste components built on Radix UI primitives and styled with Tailwind CSS. You own the code - components are copied into your project, not installed as dependencies.

## Adding Components

**Basic command:**

```bash
pnpm dlx shadcn@latest add <component>
```

**What gets created:**

- Component file in `src/components/ui/` (or configured path)
- Dependencies automatically installed if needed
- Imports use path alias: `@/components/ui/<component>`

**Before adding:**

- Verify `components.json` exists with correct paths
- Check path alias (`@/*`) is configured in tsconfig/vite
- Ensure CSS variables exist for component tokens

## Customization Patterns

### Variants with CVA

Use `class-variance-authority` for size/color/style variants:

```tsx
import { cva, type VariantProps } from "class-variance-authority"

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md", // base
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground",
        destructive: "bg-destructive text-destructive-foreground",
        outline: "border border-input bg-background",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)
```

### Extending Components

Add props or wrap with custom logic:

```tsx
interface CustomButtonProps extends ButtonProps {
  loading?: boolean
}

export function CustomButton({ loading, children, ...props }: CustomButtonProps) {
  return (
    <Button disabled={loading || props.disabled} {...props}>
      {loading ? <Spinner /> : children}
    </Button>
  )
}
```

### Composition

Build complex components from primitives:

```tsx
// CommandDialog = Dialog + Command
<Dialog>
  <DialogContent>
    <Command>
      <CommandInput />
      <CommandList>
        <CommandGroup>
          <CommandItem />
        </CommandGroup>
      </CommandList>
    </Command>
  </DialogContent>
</Dialog>
```

### Overriding Styles

- **Via className prop:** For one-off changes
- **Edit component file:** For permanent changes to all instances

## The shadcn System

**Philosophy:** Copy-paste, not a package. You own and modify the code.

**Architecture:**

- Radix UI primitives (accessibility, behavior)
- Tailwind for styling via `cn()` utility
- CSS variables for theming (not Tailwind config colors)
- `components.json` controls paths, style preset, icon library

**Theming:**

- Colors use CSS variables: `hsl(var(--primary))`
- Variables defined in global CSS: `:root` and `.dark`
- Not Tailwind config colors - uses `hsl(var(--name))` pattern

## Common Gotchas

- **Path alias:** Components import `@/lib/utils` - alias must exist
- **Peer dependencies:** Check install output for additional packages
- **"use client":** Needed for RSC frameworks (not relevant in Astro islands)
- **Dark mode:** Requires `.dark` class or `dark:` variant setup
- **CSS variables:** Must be defined before adding components that use them

## External Resources

- shadcn/ui docs: <https://ui.shadcn.com/docs>
- Component catalog: <https://ui.shadcn.com/docs/components>
- Theming guide: <https://ui.shadcn.com/docs/theming>
- CVA docs: <https://cva.style/docs>
- Radix primitives: <https://www.radix-ui.com/primitives>

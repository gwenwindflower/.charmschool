# Edit Failures Are Stop Signs

When the Edit tool fails (string not found, match not unique, etc.), **stop and ask the user** what to do. Do not attempt to work around a failed edit by using scripts or the Bash tool to `cat`` into the file, remove and replace it with a fresh Write tool call, etc.

## Hard rules

- Never use Bash, Write, or any other tool to overwrite a file after an Edit rejection
- Never rewrite the full file to bypass a partial-edit failure
- A failed Edit means something about the file content is not what you expected — that is a signal to pause, not escalate

## What to do instead

1. Re-read the file to understand what actually exists
2. Ask the user for guidance — they may want to make the change themselves, or clarify what you should target
3. If the user approves a specific alternative approach, proceed with that

## Proactive Signals

- Nerd Fonts or similar devicon sets are going to fail, if you know there are icons in the file, give the user code changes to implement rather than trying to force an edit through. If you do get the Edit to work, it will end up replacing icons with blank spaces or other incorrect symbols, which is never what we want.
- A repeated, mysterious Edit failure may indicate that the user has open, unwritten edits in the file, in their editor, locking the file from being modified. Again, stopping and asking the user is the right course here, as they may need to save their work, or prefer to just implement the change alongside their open changes manually.

## Writing files

This applies to the Write tool as well, though issues here are less common. If you are hitting a repeated error writing a new file, do not try to circumvent the Write tool, pause and talk to the user.

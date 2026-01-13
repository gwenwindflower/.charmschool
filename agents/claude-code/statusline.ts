#!/usr/bin/env -S deno run --allow-read --allow-run
/**
 * Claude Code statusline - inspired by Starship prompt config
 * Using Catppuccin Frappe colors
 */

import { readAll } from 'https://deno.land/std@0.224.0/io/read_all.ts';
import { join } from 'https://deno.land/std@0.224.0/path/mod.ts';

// Types for Claude Code session context
interface SessionContext {
  hook_event_name: string;
  session_id: string;
  cwd: string;
  model: {
    id: string;
    display_name: string;
  };
  workspace: {
    current_dir: string;
    project_dir: string;
  };
  version: string;
  output_style: {
    name: string;
  };
  cost?: {
    total_cost_usd: number;
    total_duration_ms: number;
    total_api_duration_ms: number;
    total_lines_added: number;
    total_lines_removed: number;
  };
  context_window?: {
    total_input_tokens: number;
    total_output_tokens: number;
    context_window_size: number;
    current_usage?: {
      input_tokens: number;
      output_tokens: number;
      cache_creation_input_tokens: number;
      cache_read_input_tokens: number;
    };
  };
}

// Catppuccin Frappe color palette - ANSI escape codes
const BG_COLORS: Record<string, string> = {
  mauve: '\x1b[48;2;202;158;230m',
  peach: '\x1b[48;2;239;159;118m',
  yellow: '\x1b[48;2;229;200;144m',
  green: '\x1b[48;2;166;209;137m',
  blue: '\x1b[48;2;137;180;250m',
  pink: '\x1b[48;2;244;184;228m',
  maroon: '\x1b[48;2;234;153;156m',
};

const FG_COLOR = '\x1b[38;2;35;38;52m'; // Crust - dark text
const RESET = '\x1b[0m';

const colors = {
  // Combined: background + foreground
  segment: (bg: string, content: string) => `${BG_COLORS[bg]}${FG_COLOR}${content}${RESET}`,
};

// Pre-compiled regex patterns for git status parsing
const GIT_STATUS_PATTERNS = {
  modified: /^ M/,
  added: /^A/,
  deleted: /^D/,
  untracked: /^\?\?/,
};

// Get minimal environment for version checks (PATH + version manager vars)
function getMinimalEnv(): Record<string, string> {
  const fullEnv = Deno.env.toObject();
  const needed: Record<string, string> = {};

  // Required for finding executables
  if (fullEnv.PATH) needed.PATH = fullEnv.PATH;
  if (fullEnv.HOME) needed.HOME = fullEnv.HOME;

  // Version manager variables (only include if present)
  const versionManagerVars = [
    'PYENV_ROOT',
    'PYENV_VERSION',
    'PYENV_SHELL', // Python (pyenv)
    'NVM_DIR',
    'NVM_BIN', // Node (nvm)
    'RBENV_ROOT',
    'RBENV_VERSION', // Ruby (rbenv)
    'GOROOT',
    'GOPATH', // Go
    'CARGO_HOME',
    'RUSTUP_HOME', // Rust
    'MISE_DATA_DIR',
    'MISE_CONFIG_DIR', // mise (multi-language)
  ];

  for (const key of versionManagerVars) {
    if (fullEnv[key]) {
      needed[key] = fullEnv[key];
    }
  }

  return needed;
}

// Execute command directly (no shell wrapper) and return stdout
async function execCommand(cmd: string, args: string[], cwd: string): Promise<string> {
  try {
    const command = new Deno.Command(cmd, {
      args,
      cwd,
      stdout: 'piped',
      stderr: 'piped',
      env: getMinimalEnv(), // Only pass needed environment variables
    });
    const { success, stdout } = await command.output();

    if (!success) {
      return '';
    }

    return new TextDecoder().decode(stdout).trim();
  } catch {
    // Command execution failed (e.g., not installed)
    return '';
  }
}

// Execute git command directly (no shell wrapper) and return stdout
async function execGit(args: string[], cwd: string): Promise<string> {
  return await execCommand('git', args, cwd);
}

// Check if directory is a git repository
async function isGitRepo(cwd: string): Promise<boolean> {
  const result = await execGit(['rev-parse', '--git-dir'], cwd);
  return result.length > 0;
}

// Get git branch name
async function getGitBranch(cwd: string): Promise<string> {
  const branch = await execGit(['branch', '--show-current'], cwd);
  return branch || 'detached';
}

// Get git status counts
async function getGitStatus(cwd: string): Promise<{
  modified: number;
  added: number;
  deleted: number;
  untracked: number;
}> {
  const status = await execGit(['status', '--porcelain'], cwd);
  if (!status) {
    return { modified: 0, added: 0, deleted: 0, untracked: 0 };
  }

  const lines = status.split('\n');
  return {
    modified: lines.filter((l) => GIT_STATUS_PATTERNS.modified.test(l)).length,
    added: lines.filter((l) => GIT_STATUS_PATTERNS.added.test(l)).length,
    deleted: lines.filter((l) => GIT_STATUS_PATTERNS.deleted.test(l)).length,
    untracked: lines.filter((l) => GIT_STATUS_PATTERNS.untracked.test(l)).length,
  };
}

// Check if file exists (safe wrapper around Deno.stat)
async function fileExists(path: string): Promise<boolean> {
  try {
    await Deno.stat(path);
    return true;
  } catch {
    return false;
  }
}

// Language info with version
interface LanguageInfo {
  icon: string;
  version?: string;
}

// Language configuration structure
interface LanguageConfig {
  icon: string;
  detectionFiles: string[]; // Files/dirs that indicate this language is used
  versionCommand: string; // Command to run for version check
  versionArgs: string[]; // Arguments to pass to version command
}

// Centralized language configurations
const LANGUAGE_CONFIGS: Record<string, LanguageConfig> = {
  python: {
    icon: ' ',
    detectionFiles: ['pyproject.toml', 'requirements.txt', '.python-version', 'uv.lock', '.venv'],
    versionCommand: 'python3',
    versionArgs: ['--version'],
  },
  node: {
    icon: ' ',
    detectionFiles: ['package.json'],
    versionCommand: 'node',
    versionArgs: ['--version'],
  },
  deno: {
    icon: ' ',
    detectionFiles: ['deno.json'],
    versionCommand: 'deno',
    versionArgs: ['--version'],
  },
  bun: {
    icon: ' ',
    detectionFiles: ['bun.lockb'],
    versionCommand: 'bun',
    versionArgs: ['--version'],
  },
  go: {
    icon: ' ',
    detectionFiles: ['go.mod'],
    versionCommand: 'go',
    versionArgs: ['version'],
  },
  ruby: {
    icon: ' ',
    detectionFiles: ['Gemfile'],
    versionCommand: 'ruby',
    versionArgs: ['--version'],
  },
  rust: {
    icon: ' ',
    detectionFiles: ['Cargo.toml'],
    versionCommand: 'rustc',
    versionArgs: ['--version'],
  },
};

// Version extraction helpers - parse common version output formats
const VERSION_PATTERNS = {
  // Matches "X.Y.Z" or "vX.Y.Z" at start or after space
  simple: /(?:^|\s)v?(\d+\.\d+\.\d+)/,
  // Matches "Python X.Y.Z" or similar
  named: /\w+\s+(\d+\.\d+\.\d+)/,
};

// Extract version string from command output
function parseVersion(output: string): string {
  if (!output) return '';
  const match = output.match(VERSION_PATTERNS.simple) || output.match(VERSION_PATTERNS.named);
  return match ? match[1] : '';
}

// Generic language version checker
async function getLanguageVersion(config: LanguageConfig, cwd: string): Promise<string> {
  const output = await execCommand(config.versionCommand, config.versionArgs, cwd);
  // Handle multi-line output (e.g., deno) by taking first line
  const firstLine = output.split('\n')[0];
  return parseVersion(firstLine);
}

// Detect project languages with versions
async function detectLanguages(cwd: string): Promise<LanguageInfo[]> {
  // Phase 1: Detect which languages are present (fast file checks)
  const detectionPromises = Object.entries(LANGUAGE_CONFIGS).map(async ([langName, config]) => {
    const checks = await Promise.all(
      config.detectionFiles.map((file) => fileExists(join(cwd, file))),
    );
    return { langName, config, isPresent: checks.some(Boolean) };
  });

  const detectionResults = await Promise.all(detectionPromises);
  const presentLanguages = detectionResults.filter((result) => result.isPresent);

  // Phase 2: Fetch versions in parallel for detected languages
  const versionPromises = presentLanguages.map(async ({ config }) => {
    const version = await getLanguageVersion(config, cwd);
    return { icon: config.icon, version };
  });

  return await Promise.all(versionPromises);
}

// Main statusline builder
async function buildStatusline(context: SessionContext): Promise<string> {
  const segments: string[] = [];

  const cwd = context.workspace?.current_dir || context.cwd;
  const dirName = cwd.split('/').pop() || '~';

  // Truncate long directory names
  const displayDir = dirName.length > 25 ? `${dirName.slice(0, 22)}...` : dirName;

  // Model indicator
  const model = context.model?.display_name || 'Sonnet';
  segments.push(colors.segment('mauve', ` ${model} `));

  // Directory segment
  segments.push(colors.segment('peach', ` ${displayDir} `));

  // Git info (if in a git repo) - parallelize git commands
  if (await isGitRepo(cwd)) {
    const [branch, status] = await Promise.all([
      getGitBranch(cwd),
      getGitStatus(cwd),
    ]);

    let gitSegment = `  ${branch}`;

    // Add status indicators
    const statusParts: string[] = [];
    if (status.modified > 0) statusParts.push(`!`);
    if (status.added > 0) statusParts.push(``);
    if (status.deleted > 0) statusParts.push(`✘`);
    if (status.untracked > 0) statusParts.push(`?`);

    if (statusParts.length > 0) {
      gitSegment += ` ${statusParts.join('')}`;
    }

    gitSegment += ' ';
    segments.push(colors.segment('yellow', gitSegment));
  }

  // Language indicators with versions
  const languages = await detectLanguages(cwd);
  if (languages.length > 0) {
    // Format: icon (version if available)
    const langParts = languages.map((lang) =>
      lang.version ? `${lang.icon}${lang.version}` : lang.icon
    );
    const langSegment = ` ${langParts.join(' ')} `;
    segments.push(colors.segment('green', langSegment));
  }

  // Cumulative session context percentage
  if (context.context_window) {
    const { total_input_tokens, total_output_tokens, context_window_size } = context.context_window;
    const totalTokens = total_input_tokens + total_output_tokens;
    const percentage = Math.round((totalTokens / context_window_size) * 100);
    if (percentage < 80) {
      segments.push(colors.segment('blue', ` ${percentage}% `));
    } else {
      segments.push(colors.segment('maroon', ` ${percentage}% `));
    }
  }

  return segments.join('');
}

// Main execution
async function main() {
  try {
    // Read JSON from stdin using Deno's standard library
    const inputBytes = await readAll(Deno.stdin);
    const contextStr = new TextDecoder().decode(inputBytes);
    const context: SessionContext = JSON.parse(contextStr);

    // Build and output statusline
    const statusline = await buildStatusline(context);
    console.log(statusline);
  } catch (error) {
    // Fallback in case of errors
    const message = error instanceof Error ? error.message : String(error);
    console.error(`Error: ${message}`);
    Deno.exit(1);
  }
}

main();

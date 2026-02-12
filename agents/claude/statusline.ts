#!/usr/bin/env -S deno run --allow-read --allow-run --allow-env
/**
 * Claude Code statusline - inspired by Starship prompt config
 * Using Catppuccin Frappe colors
 * WARN: this is a WIP, it runs with way too many permissions for my comfort
 * use at your own risk, and if you're the type of person who lets Claude Code rip
 * maybe don't use this (you do you, I just want you to be safe!)
 * TODO: tighten permissions, improve error handling, optimize performance
 * TODO: show active Skills? names would take up too much space,
 * but could add a config for certain important skills to assign a devicon
 * then when that Skill load happens we append it to a Skill segment?
 * Very low priority though.
 * TODO: show sandbox status - if we get it in the context fed to statusline
 * then this is easy and super useful, high priority to investigate
 */

import { readAll } from 'https://deno.land/std@0.224.0/io/read_all.ts';
import { join } from 'https://deno.land/std@0.224.0/path/mod.ts';

// Types for Claude Code session context
interface SessionContext {
  hook_event_name: string;
  session_id: string;
  transcript_path: string;
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
  base: '\x1b[48;2;48;52;70m', // #303446 - default terminal background
};

// Foreground versions of the accent colors (for endcaps)
const FG_COLORS: Record<string, string> = {
  mauve: '\x1b[38;2;202;158;230m',
  peach: '\x1b[38;2;239;159;118m',
  yellow: '\x1b[38;2;229;200;144m',
  green: '\x1b[38;2;166;209;137m',
  blue: '\x1b[38;2;137;180;250m',
  pink: '\x1b[38;2;244;184;228m',
  maroon: '\x1b[38;2;234;153;156m',
};

const FG_CRUST = '\x1b[38;2;35;38;52m'; // Crust - dark text for segments
const RESET = '\x1b[0m';

const colors = {
  // Colored background + dark text (for filled segments)
  segment: (bg: string, content: string) => `${BG_COLORS[bg]}${FG_CRUST}${content}${RESET}`,
  // Base background + colored text (for subtle/ending segments)
  endcap: (color: string, content: string) =>
    `${BG_COLORS.base}${FG_COLORS[color]}${content}${RESET}`,
};

// Pre-compiled regex patterns for git status parsing
const GIT_STATUS_PATTERNS = {
  modified: /^ M/,
  added: /^A/,
  deleted: /^.?D/, // Matches both " D" (unstaged) and "D " (staged)
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
async function execCommand(
  cmd: string,
  args: string[],
  cwd: string,
  env: Record<string, string>,
): Promise<string> {
  try {
    const command = new Deno.Command(cmd, {
      args,
      cwd,
      stdout: 'piped',
      stderr: 'piped',
      env,
    });
    const { success, stdout } = await command.output();

    if (!success) {
      return 'failed';
    }

    return new TextDecoder().decode(stdout).trim();
  } catch {
    // Command execution failed (e.g., not installed)
    return 'failed';
  }
}

// Check if directory is a git repository
async function isGitRepo(cwd: string, env: Record<string, string>): Promise<boolean> {
  const result = await execCommand('git', ['rev-parse', '--git-dir'], cwd, env);
  return result !== 'failed';
}

// Get git branch name
async function getGitBranch(cwd: string, env: Record<string, string>): Promise<string> {
  const branch = await execCommand('git', ['branch', '--show-current'], cwd, env);
  return branch || 'detached';
}

// Get git status counts
async function getGitStatus(
  cwd: string,
  env: Record<string, string>,
): Promise<{
  modified: number;
  added: number;
  deleted: number;
  untracked: number;
}> {
  const status = await execCommand('git', ['status', '--porcelain'], cwd, env);
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
async function getLanguageVersion(
  config: LanguageConfig,
  cwd: string,
  env: Record<string, string>,
): Promise<string> {
  const output = await execCommand(config.versionCommand, config.versionArgs, cwd, env);
  // Handle multi-line output (e.g., deno) by taking first line
  const firstLine = output.split('\n')[0];
  return parseVersion(firstLine);
}

// Detect project languages with versions
async function detectLanguages(
  cwd: string,
  env: Record<string, string>,
): Promise<LanguageInfo[]> {
  // Phase 1: Detect which languages are present (fast file checks)
  const detectionPromises = Object.entries(LANGUAGE_CONFIGS).map(async ([_langName, config]) => {
    const checks = await Promise.all(
      config.detectionFiles.map((file) => fileExists(join(cwd, file))),
    );
    return { config, isPresent: checks.some(Boolean) };
  });

  const detectionResults = await Promise.all(detectionPromises);
  const presentLanguages = detectionResults.filter((result) => result.isPresent);

  // Phase 2: Fetch versions in parallel for detected languages
  const versionPromises = presentLanguages.map(async ({ config }) => {
    const version = await getLanguageVersion(config, cwd, env);
    return { icon: config.icon, version };
  });

  return await Promise.all(versionPromises);
}

// Main statusline builder
async function buildStatusline(
  context: SessionContext,
  env: Record<string, string>,
): Promise<string> {
  const segments: string[] = [];

  segments.push(colors.endcap('mauve', ''));

  const projectDir = context.workspace?.project_dir || 'ERROR: Missing Project Dir';
  // Simple workspace display: just show the workspace root name
  const displayDir = projectDir?.split('/').pop() || 'ERROR: Path Split';

  // Model indicator - error if absent since this should never happen
  // For space we just show the name "Haiku', 'Sonnet', 'Opus' since
  // Claude Code always points to the latest version
  const model = context.model?.display_name.split(' ')[0] || '⚠ No Model';
  segments.push(colors.segment('mauve', `${model} `));

  // Directory segment
  segments.push(colors.segment('peach', ` ${displayDir} `));

  // Git info (if in a git repo) - parallelize git commands
  if (await isGitRepo(projectDir, env)) {
    const [branch, status] = await Promise.all([
      getGitBranch(projectDir, env),
      getGitStatus(projectDir, env),
    ]);

    let gitSegment = `  ${branch}`;

    // Add status indicators
    const statusParts: string[] = [];
    if (status.modified > 0) statusParts.push(`!`);
    if (status.added > 0) statusParts.push(`+`);
    if (status.deleted > 0) statusParts.push(`✘`);
    if (status.untracked > 0) statusParts.push(`?`);

    if (statusParts.length > 0) {
      gitSegment += ` ${statusParts.join('')}`;
    }

    gitSegment += ' ';
    segments.push(colors.segment('yellow', gitSegment));
  }

  // Language indicators with versions
  const languages = await detectLanguages(projectDir, env);
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
    if (percentage > 80) {
      segments.push(colors.segment('maroon', ` ${percentage}%`));
      segments.push(colors.endcap('maroon', ''));
    } else {
      segments.push(colors.segment('blue', ` ${percentage}%`));
      segments.push(colors.endcap('blue', ''));
    }
  }

  return segments.join('');
}

// Format error output with maroon background so statusline doesn't suddenly look terrible
function formatError(step: string): string {
  return `${BG_COLORS.maroon}${FG_COLORS} ERROR: ${step} ${RESET}`;
}

// Main execution
async function main() {
  let step = 'reading stdin';
  try {
    const inputBytes = await readAll(Deno.stdin);
    const contextStr = new TextDecoder().decode(inputBytes);

    step = 'parsing context JSON';
    const context: SessionContext = JSON.parse(contextStr);

    step = 'validating context';
    if (!context.workspace?.project_dir) {
      throw new Error('missing workspace.project_dir');
    }

    step = 'building statusline';
    const env = getMinimalEnv();
    const statusline = await buildStatusline(context, env);
    console.log(statusline);
  } catch (error) {
    const detail = error instanceof Error ? error.message : '';
    const msg = detail ? `${step}: ${detail}` : step;
    console.log(formatError(msg));
    Deno.exit(1);
  }
}

main();

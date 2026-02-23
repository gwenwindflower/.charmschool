#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env=HOME --allow-net=platform.claude.com,code.claude.com,github.com,codeload.github.com --allow-run=tar

/**
 * skillutil - Unified CLI for Claude Agent Skill management
 *
 * Run in dev mode:
 *   deno task skillutil <command> [options]
 *   deno task skillutil:check  (type check)
 *   deno task skillutil:test   (run tests)
 *
 * Install as global binary:
 *   deno task skillutil:install
 *   skillutil <command> [options]
 *
 * Templates are read from: ~/.claude/skills/develop-agent-skills/assets
 */

import { parse as parseYAML } from '@std/yaml';
import { join, resolve } from '@std/path';
import { exists, move } from '@std/fs';
import { Command } from '@cliffy/command';

// ============================================================================
// Configuration
// ============================================================================

const homeDir = Deno.env.get('HOME');
if (!homeDir) throw new Error('HOME not set');

const TEMPLATE_DIR = join(homeDir, '.claude/skills/develop-agent-skills/assets');
const AGENT_SKILLS_DIR = join(homeDir, '.claude/skills/develop-agent-skills');
const USER_LEVEL_SKILLS = join(homeDir, '.charmschool/agents/claude/skills');
const DEACTIVATED_SKILLS = join(homeDir, '.charmschool/agents/claude/_deactivated_skills');

const TEMPLATES = {
  skill: 'SKILL.md.tmpl',
  script: 'example_script.ts.tmpl',
  reference: 'example_reference.md.tmpl',
  asset: 'example_asset.txt.tmpl',
};

// Anthropic documentation sources
const DOC_SOURCES = [
  {
    url: 'https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md',
    filename: 'overview.md',
  },
  {
    url: 'https://code.claude.com/docs/en/skills.md',
    filename: 'skills.md',
  },
  {
    url: 'https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md',
    filename: 'best-practices.md',
  },
];

// ============================================================================
// Types
// ============================================================================

interface SkillFrontmatter {
  name: string;
  description: string;
  license?: string;
  'allowed-tools'?: string[];
  metadata?: Record<string, unknown>;
}

interface ValidationResult {
  valid: boolean;
  message: string;
}

// ============================================================================
// Utilities
// ============================================================================

function titleCase(hyphenated: string): string {
  return hyphenated
    .split('-')
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

async function loadTemplate(name: string): Promise<string> {
  const templateName = TEMPLATES[name as keyof typeof TEMPLATES];
  if (!templateName) {
    throw new Error(`Unknown template: ${name}`);
  }

  const templatePath = join(TEMPLATE_DIR, templateName);
  try {
    return await Deno.readTextFile(templatePath);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`❌ Error loading template: ${templatePath}`);
    console.error(`   ${message}`);
    console.error(`   Make sure templates exist at: ${TEMPLATE_DIR}`);
    throw error;
  }
}

function interpolate(template: string, vars: Record<string, string>): string {
  return template.replace(/\{\{(\w+)\}\}/g, (_, key) => vars[key] || '');
}

// Returns an error message string if invalid, null if valid.
function validateSkillName(skillName: string): string | null {
  if (!/^[a-z0-9-]+$/.test(skillName)) {
    return `Invalid skill name '${skillName}'\n   Skill names must be lowercase letters, digits, and hyphens only`;
  }
  if (skillName.startsWith('-') || skillName.endsWith('-') || skillName.includes('--')) {
    return `Invalid skill name '${skillName}'\n   Skill names cannot start/end with hyphen or contain consecutive hyphens`;
  }
  if (skillName.length > 64) {
    return `Skill name too long (${skillName.length} characters)\n   Maximum length is 64 characters`;
  }
  return null;
}

// ============================================================================
// Command: init
// ============================================================================

async function initSkill(skillName: string, basePath: string): Promise<boolean> {
  const skillDir = resolve(basePath, skillName);
  const skillTitle = titleCase(skillName);

  // Validate skill name format first (before creating anything)
  const nameError = validateSkillName(skillName);
  if (nameError) {
    console.error(`❌ Error: ${nameError}`);
    return false;
  }

  // Check if directory exists
  if (await exists(skillDir)) {
    console.error(`❌ Error: Skill directory already exists: ${skillDir}`);
    return false;
  }

  // All validation passed - now we can start
  console.log(`Initializing skill: ${skillName}`);
  console.log(`Location: ${skillDir}\n`);

  try {
    // Create skill directory
    await Deno.mkdir(skillDir, { recursive: true });
    console.log(`✅ Created skill directory: ${skillDir}`);

    // Load and interpolate templates
    const vars = { skill_name: skillName, skill_title: skillTitle };

    // Create SKILL.md
    const skillTemplate = await loadTemplate('skill');
    const skillContent = interpolate(skillTemplate, vars);
    await Deno.writeTextFile(join(skillDir, 'SKILL.md'), skillContent);
    console.log('✅ Created SKILL.md');

    // Create scripts/ directory
    await Deno.mkdir(join(skillDir, 'scripts'));
    const scriptTemplate = await loadTemplate('script');
    const scriptContent = interpolate(scriptTemplate, vars);
    await Deno.writeTextFile(
      join(skillDir, 'scripts', 'example.ts'),
      scriptContent,
    );
    await Deno.chmod(join(skillDir, 'scripts', 'example.ts'), 0o755);
    console.log('✅ Created scripts/example.ts');

    // Create references/ directory
    await Deno.mkdir(join(skillDir, 'references'));
    const refTemplate = await loadTemplate('reference');
    const refContent = interpolate(refTemplate, vars);
    await Deno.writeTextFile(
      join(skillDir, 'references', 'api_reference.md'),
      refContent,
    );
    console.log('✅ Created references/api_reference.md');

    // Create assets/ directory
    await Deno.mkdir(join(skillDir, 'assets'));
    const assetTemplate = await loadTemplate('asset');
    await Deno.writeTextFile(
      join(skillDir, 'assets', 'example_asset.txt'),
      assetTemplate,
    );
    console.log('✅ Created assets/example_asset.txt');

    // Print next steps
    console.log(`\n✅ Skill '${skillName}' initialized successfully at ${skillDir}`);
    console.log('\nNext steps:');
    console.log('1. Edit SKILL.md to complete the TODO items and update the description');
    console.log('2. Customize or delete the example files in scripts/, references/, and assets/');
    console.log('3. Run the validator when ready to check the skill structure');
    console.log(`   skillutil validate ${skillDir}`);

    return true;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`❌ Error creating skill: ${message}`);
    return false;
  }
}

// ============================================================================
// Command: init --fork
// ============================================================================

async function forkSkill(skillName: string, basePath: string, forkUrl: string): Promise<boolean> {
  const skillDir = resolve(basePath, skillName);

  const nameError = validateSkillName(skillName);
  if (nameError) {
    console.error(`❌ Error: ${nameError}`);
    return false;
  }

  // Validate GitHub URL and extract user/repo
  const match = forkUrl.match(/^https:\/\/github\.com\/([^/]+)\/([^/\s]+?)(?:\.git)?(?:\/.*)?$/);
  if (!match) {
    console.error('❌ Error: Invalid GitHub URL');
    console.error('   Expected format: https://github.com/user/repo');
    return false;
  }
  const [, user, repo] = match;

  // Check if destination already exists
  if (await exists(skillDir)) {
    console.error(`❌ Error: Skill directory already exists: ${skillDir}`);
    return false;
  }

  const downloadUrl = `https://github.com/${user}/${repo}/archive/refs/heads/main.tar.gz`;

  console.log(`Forking ${user}/${repo} as skill: ${skillName}`);
  console.log(`Location: ${skillDir}\n`);

  let tmpFile: string | undefined;
  try {
    console.log('Downloading main branch HEAD...');
    const response = await fetch(downloadUrl);

    if (!response.ok) {
      console.error(`❌ Error: Failed to fetch repository (HTTP ${response.status})`);
      if (response.status === 404) {
        console.error(`   Repository not found or no main branch: ${forkUrl}`);
      }
      return false;
    }

    await Deno.mkdir(skillDir, { recursive: true });

    // Write tarball to temp file then extract (avoids streaming complexity)
    tmpFile = await Deno.makeTempFile({ suffix: '.tar.gz' });
    await Deno.writeFile(tmpFile, new Uint8Array(await response.arrayBuffer()));

    // --strip-components=1 removes the `repo-main/` prefix GitHub adds
    const tar = new Deno.Command('tar', {
      args: ['xzf', tmpFile, '--strip-components=1', '-C', skillDir],
      stderr: 'piped',
    });
    const { success, stderr } = await tar.output();

    if (!success) {
      const errMsg = new TextDecoder().decode(stderr);
      console.error(`❌ Error extracting archive: ${errMsg}`);
      await Deno.remove(skillDir, { recursive: true });
      return false;
    }

    console.log(`✅ Forked ${user}/${repo} to ${skillDir}`);

    const hasSkillMd = await exists(join(skillDir, 'SKILL.md'));
    console.log('\nNext steps:');
    if (hasSkillMd) {
      console.log('1. Review and edit SKILL.md to fit your needs');
    } else {
      console.log('1. Create SKILL.md with required frontmatter (name, description)');
    }
    console.log('2. Customize the skill contents for your use case');
    console.log(`3. Validate when ready: skillutil validate ${skillDir}`);

    return true;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`❌ Error forking repository: ${message}`);
    if (await exists(skillDir)) {
      await Deno.remove(skillDir, { recursive: true });
    }
    return false;
  } finally {
    if (tmpFile) {
      try {
        await Deno.remove(tmpFile);
      } catch { /* ignore cleanup errors */ }
    }
  }
}

// ============================================================================
// Command: validate
// ============================================================================

async function validateSkill(skillPath: string): Promise<ValidationResult> {
  const skillDir = resolve(skillPath);
  const skillMdPath = join(skillDir, 'SKILL.md');

  // Check SKILL.md exists
  if (!(await exists(skillMdPath))) {
    return { valid: false, message: 'SKILL.md not found' };
  }

  // Read and parse frontmatter
  const content = await Deno.readTextFile(skillMdPath);

  if (!content.startsWith('---')) {
    return { valid: false, message: 'No YAML frontmatter found' };
  }

  const frontmatterMatch = content.match(/^---\n(.*?)\n---/s);
  if (!frontmatterMatch) {
    return { valid: false, message: 'Invalid frontmatter format' };
  }

  // Parse YAML
  let frontmatter: SkillFrontmatter;
  try {
    frontmatter = parseYAML(frontmatterMatch[1]) as SkillFrontmatter;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return { valid: false, message: `Invalid YAML in frontmatter: ${message}` };
  }

  // Validate structure
  const ALLOWED_PROPERTIES = new Set([
    'name',
    'description',
    'license',
    'allowed-tools',
    'metadata',
  ]);

  const unexpectedKeys = Object.keys(frontmatter).filter(
    (key) => !ALLOWED_PROPERTIES.has(key),
  );

  if (unexpectedKeys.length > 0) {
    return {
      valid: false,
      message: `Unexpected key(s) in SKILL.md frontmatter: ${unexpectedKeys.join(', ')}. ` +
        `Allowed properties are: ${Array.from(ALLOWED_PROPERTIES).join(', ')}`,
    };
  }

  // Check required fields exist and are strings
  if (frontmatter.name === undefined || frontmatter.name === null) {
    return { valid: false, message: "Missing 'name' in frontmatter" };
  }
  if (frontmatter.description === undefined || frontmatter.description === null) {
    return { valid: false, message: "Missing 'description' in frontmatter" };
  }

  // Ensure name and description are strings
  if (typeof frontmatter.name !== 'string') {
    return { valid: false, message: "'name' must be a string" };
  }
  if (typeof frontmatter.description !== 'string') {
    return { valid: false, message: "'description' must be a string" };
  }

  // Validate name
  const name = frontmatter.name.trim();
  const nameError = validateSkillName(name);
  if (nameError) {
    return { valid: false, message: nameError };
  }

  // Validate description
  const description = frontmatter.description.trim();
  if (/<|>/.test(description)) {
    return {
      valid: false,
      message: 'Description cannot contain angle brackets (< or >)',
    };
  }
  if (description.length > 1024) {
    return {
      valid: false,
      message:
        `Description is too long (${description.length} characters). Maximum is 1024 characters.`,
    };
  }

  return { valid: true, message: '✅ Skill is valid!' };
}

// ============================================================================
// Command: refresh-docs
// ============================================================================

async function refreshDocs(): Promise<boolean> {
  const outputDir = join(AGENT_SKILLS_DIR, 'references', 'anthropic-docs');

  console.log('Fetching latest Anthropic skill documentation...\n');

  try {
    // Create output directory
    await Deno.mkdir(outputDir, { recursive: true });

    let successCount = 0;

    for (const source of DOC_SOURCES) {
      try {
        console.log(`Fetching ${source.filename}...`);
        const response = await fetch(source.url);

        if (!response.ok) {
          console.error(`  ⚠️  Failed (${response.status}): ${source.url}`);
          continue;
        }

        const content = await response.text();
        const outputPath = join(outputDir, source.filename);
        await Deno.writeTextFile(outputPath, content);
        console.log(`  ✅ Saved to ${outputPath}`);
        successCount++;
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        console.error(`  ⚠️  Error fetching ${source.filename}: ${message}`);
      }
    }

    console.log(`\n✅ Fetched ${successCount}/${DOC_SOURCES.length} documents to ${outputDir}`);
    return successCount > 0;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`❌ Error refreshing docs: ${message}`);
    return false;
  }
}

// ============================================================================
// Command: activate / deactivate
// ============================================================================

async function activateSkill(skillName: string): Promise<boolean> {
  const sourcePath = join(DEACTIVATED_SKILLS, skillName);
  const destPath = join(USER_LEVEL_SKILLS, skillName);

  // Check source exists
  if (!(await exists(sourcePath))) {
    console.error(`❌ Error: Skill '${skillName}' not found in deactivated skills`);
    console.error(`   Expected at: ${sourcePath}`);

    // Check if already active
    if (await exists(destPath)) {
      console.log(`   (Skill is already active at: ${destPath})`);
    }
    return false;
  }

  // Check destination doesn't exist
  if (await exists(destPath)) {
    console.error(`❌ Error: Skill '${skillName}' already exists in active skills`);
    console.error(`   Location: ${destPath}`);
    return false;
  }

  try {
    await move(sourcePath, destPath);
    console.log(`✅ Activated skill '${skillName}'`);
    console.log(`   Moved from: ${sourcePath}`);
    console.log(`   Moved to:   ${destPath}`);
    return true;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`❌ Error activating skill: ${message}`);
    return false;
  }
}

async function deactivateSkill(skillName: string): Promise<boolean> {
  const sourcePath = join(USER_LEVEL_SKILLS, skillName);
  const destPath = join(DEACTIVATED_SKILLS, skillName);

  // Check source exists
  if (!(await exists(sourcePath))) {
    console.error(`❌ Error: Skill '${skillName}' not found in active skills`);
    console.error(`   Expected at: ${sourcePath}`);

    // Check if already deactivated
    if (await exists(destPath)) {
      console.log(`   (Skill is already deactivated at: ${destPath})`);
    }
    return false;
  }

  // Create deactivated directory if needed
  if (!(await exists(DEACTIVATED_SKILLS))) {
    await Deno.mkdir(DEACTIVATED_SKILLS, { recursive: true });
  }

  // Check destination doesn't exist
  if (await exists(destPath)) {
    console.error(`❌ Error: Skill '${skillName}' already exists in deactivated skills`);
    console.error(`   Location: ${destPath}`);
    return false;
  }

  try {
    await move(sourcePath, destPath);
    console.log(`✅ Deactivated skill '${skillName}'`);
    console.log(`   Moved from: ${sourcePath}`);
    console.log(`   Moved to:   ${destPath}`);
    return true;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`❌ Error deactivating skill: ${message}`);
    return false;
  }
}

// ============================================================================
// Command: add
// ============================================================================

async function installSkill(
  sourceDir: string,
  destPath: string,
  skillName: string,
  repoLabel: string,
): Promise<boolean> {
  const destDir = join(destPath, skillName);

  if (await exists(destDir)) {
    console.error(`❌ Skipping '${skillName}': already exists at ${destDir}`);
    return false;
  }

  try {
    await move(sourceDir, destDir);
    console.log(`✅ Added '${skillName}' from ${repoLabel} → ${destDir}`);
    return true;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`❌ Error installing '${skillName}': ${message}`);
    return false;
  }
}

async function addSkill(githubUrl: string, destPath: string): Promise<boolean> {
  // Parse GitHub tree URL: https://github.com/user/repo/tree/ref[/subpath]
  // Takes the first path segment after /tree/ as the ref — handles main, master,
  // develop, staging, trunk, etc. Multi-segment branch names (e.g. feature/x) are
  // not supported; use gunk for those.
  const match = githubUrl.match(
    /^https:\/\/github\.com\/([^/]+)\/([^/]+)\/tree\/([^/]+)(\/.*)?$/,
  );

  if (!match) {
    console.error('❌ Error: Invalid GitHub tree URL');
    console.error('   Expected: https://github.com/user/repo/tree/branch[/path]');
    console.error('   For plain repo URLs, use: skillutil init --fork <url>');
    return false;
  }

  const [, user, repo, ref, subpathRaw] = match;
  const subpath = subpathRaw ? subpathRaw.replace(/^\//, '') : '';

  console.log(`Adding from ${user}/${repo} @ ${ref}...`);

  // Try branch then tag
  let response = await fetch(
    `https://github.com/${user}/${repo}/archive/refs/heads/${ref}.tar.gz`,
  );
  if (!response.ok && response.status === 404) {
    response = await fetch(
      `https://github.com/${user}/${repo}/archive/refs/tags/${ref}.tar.gz`,
    );
  }
  if (!response.ok) {
    console.error(`❌ Failed to fetch repository (HTTP ${response.status})`);
    if (response.status === 404) {
      console.error(`   '${ref}' not found as a branch or tag in ${user}/${repo}`);
      console.error('   For unusual branch names (e.g. feature/x), use gunk manually');
    }
    return false;
  }

  let tmpFile: string | undefined;
  let tmpDir: string | undefined;

  try {
    console.log('Downloading...');
    tmpFile = await Deno.makeTempFile({ suffix: '.tar.gz' });
    await Deno.writeFile(tmpFile, new Uint8Array(await response.arrayBuffer()));

    tmpDir = await Deno.makeTempDir();

    // Extract full archive, stripping the `repo-ref/` prefix GitHub adds to all paths
    const tar = new Deno.Command('tar', {
      args: ['xzf', tmpFile, '--strip-components=1', '-C', tmpDir],
      stderr: 'piped',
    });
    const { success, stderr } = await tar.output();
    if (!success) {
      console.error(`❌ Error extracting archive: ${new TextDecoder().decode(stderr)}`);
      return false;
    }

    // Navigate to the target subpath within the extracted tree
    const targetDir = subpath ? join(tmpDir, ...subpath.split('/').filter(Boolean)) : tmpDir;

    if (!(await exists(targetDir))) {
      console.error(`❌ Path not found in repository: ${subpath || '(root)'}`);
      return false;
    }

    // Single-skill: SKILL.md exists directly at targetDir
    if (await exists(join(targetDir, 'SKILL.md'))) {
      const skillName = subpath.split('/').filter(Boolean).pop() ?? repo;
      const ok = await installSkill(targetDir, destPath, skillName, `${user}/${repo}`);
      if (ok) {
        console.log('\nNext steps:');
        console.log('1. Review SKILL.md to ensure it fits your setup');
        console.log(`2. Validate: skillutil validate ${join(destPath, skillName)}`);
      }
      return ok;
    }

    // Multi-skill: scan direct subdirectories for SKILL.md
    const skills: string[] = [];
    for await (const entry of Deno.readDir(targetDir)) {
      if (!entry.isDirectory) continue;
      if (await exists(join(targetDir, entry.name, 'SKILL.md'))) {
        skills.push(entry.name);
      }
    }

    if (skills.length === 0) {
      console.error(
        '❌ No skills found: no SKILL.md at the given path or its direct subdirectories',
      );
      console.error(`   Checked: ${subpath || '(repo root)'}`);
      return false;
    }

    skills.sort();
    console.log(`Found ${skills.length} skill(s): ${skills.join(', ')}\n`);

    let successCount = 0;
    for (const skillName of skills) {
      const ok = await installSkill(
        join(targetDir, skillName),
        destPath,
        skillName,
        `${user}/${repo}`,
      );
      if (ok) successCount++;
    }

    console.log(`\n✅ Added ${successCount}/${skills.length} skills to ${destPath}`);
    return successCount > 0;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`❌ Error: ${message}`);
    return false;
  } finally {
    if (tmpFile) {
      try {
        await Deno.remove(tmpFile);
      } catch { /* ignore */ }
    }
    if (tmpDir) {
      try {
        await Deno.remove(tmpDir, { recursive: true });
      } catch { /* ignore */ }
    }
  }
}

// ============================================================================
// CLI Definition with Cliffy
// ============================================================================

const cli = new Command()
  .name('skillutil')
  .version('0.1.0')
  .description('Claude Code-oriented Agent Skill management CLI')
  .meta('Author', 'winnie [gwenwindflower@gh] + Claude Code')
  .meta('Docs', 'https://code.claude.com/docs/en/skills')
  .meta('Templates', TEMPLATE_DIR)
  .meta('Active User Skills', USER_LEVEL_SKILLS)
  .meta('Deactivated User Skills', DEACTIVATED_SKILLS);

// Init command
cli
  .command('init <skill-name:string>')
  .description('Initialize a new skill from template')
  .option('-p, --path <path:string>', 'Base path for new skill', {
    default: join(homeDir!, '.claude/skills'),
  })
  .option('-f, --fork <url:string>', 'Use a GitHub repo as the skill basis (main branch HEAD)')
  .example('Create in default location', 'skillutil init my-new-skill')
  .example('Create in custom location', 'skillutil init my-new-skill --path skills/public')
  .example('Fork from GitHub', 'skillutil init my-skill --fork https://github.com/user/repo')
  .action(async (options, skillName) => {
    const success = options.fork
      ? await forkSkill(skillName, options.path, options.fork)
      : await initSkill(skillName, options.path);
    Deno.exit(success ? 0 : 1);
  });

// Validate command
cli
  .command('validate <skill-path:string>')
  .description('Validate skill structure and frontmatter')
  .example('Validate a skill', 'skillutil validate ~/.claude/skills/my-skill')
  .action(async (_options, skillPath) => {
    const result = await validateSkill(skillPath);
    console.log(result.message);
    Deno.exit(result.valid ? 0 : 1);
  });

// Refresh-docs command
cli
  .command('refresh-docs')
  .description('Fetch latest Anthropic skill documentation')
  .example('Update docs', 'skillutil refresh-docs')
  .action(async () => {
    const success = await refreshDocs();
    Deno.exit(success ? 0 : 1);
  });

// Activate command
cli
  .command('activate <skill-name:string>')
  .description('Move skill from deactivated to active')
  .example('Enable a skill', 'skillutil activate old-skill')
  .action(async (_options, skillName) => {
    const success = await activateSkill(skillName);
    Deno.exit(success ? 0 : 1);
  });

// Deactivate command
cli
  .command('deactivate <skill-name:string>')
  .description('Move skill from active to deactivated')
  .example('Disable a skill', 'skillutil deactivate old-skill')
  .action(async (_options, skillName) => {
    const success = await deactivateSkill(skillName);
    Deno.exit(success ? 0 : 1);
  });

// Add command
cli
  .command('add <github-url:string>')
  .description('Add skill(s) from a GitHub tree URL — single skill or a whole skills directory')
  .option('-p, --path <path:string>', 'Destination directory for added skills', {
    default: USER_LEVEL_SKILLS,
  })
  .example(
    'Add a single skill',
    'skillutil add https://github.com/user/repo/tree/main/.claude/skills/my-skill',
  )
  .example(
    'Add all skills from a directory',
    'skillutil add https://github.com/user/repo/tree/main/.claude/skills',
  )
  .action(async (options, githubUrl) => {
    const success = await addSkill(githubUrl, options.path);
    Deno.exit(success ? 0 : 1);
  });

// ============================================================================
// Entry Point
// ============================================================================

if (import.meta.main) {
  await cli.parse(Deno.args);
}

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
 * Templates are read from: agents/shared/skills/_skillutil/assets
 */

import { parse as parseYAML } from "@std/yaml";
import { join, resolve } from "@std/path";
import { exists, move } from "@std/fs";
import { Command } from "@cliffy/command";
import { dim, green, red, italic, magenta, yellow } from "@std/fmt/colors";

// ============================================================================
// Configuration
// ============================================================================

const homeDir = Deno.env.get("HOME");
if (!homeDir) throw new Error("HOME not set");

// TODO: build `update` command with simple lock file for tracking like npx skills
const SKILLS_DIR = join(homeDir, ".charmschool/agents/shared/skills");
const TEMPLATE_DIR = join(SKILLS_DIR, "_skillutil/assets");
const SKILL_DEV_DIR = join(SKILLS_DIR, "develop-agent-skills");
const DEACTIVATED_SKILLS = join(SKILLS_DIR, "_deactivated");

const TEMPLATES = {
	skill: "SKILL.md.tmpl",
	script: "example_script.ts.tmpl",
	reference: "example_reference.md.tmpl",
	asset: "example_asset.txt.tmpl",
};

// Anthropic documentation sources
const DOC_SOURCES = [
	{
		url: "https://code.claude.com/docs/en/skills.md",
		filename: "overview.md",
	},
];

// ============================================================================
// Types
// ============================================================================

interface SkillFrontmatter {
	name: string;
	description: string;
	license?: string;
	"allowed-tools"?: string[];
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
		.split("-")
		.map((word) => word.charAt(0).toUpperCase() + word.slice(1))
		.join(" ");
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
		console.error(`${red("❌ Error loading template:")} ${templatePath}`);
		console.error(`   ${message}`);
		console.error(
			`   ${dim(italic("Make sure templates exist at:"))} ${TEMPLATE_DIR}`,
		);
		throw error;
	}
}

function interpolate(template: string, vars: Record<string, string>): string {
	return template.replace(/\{\{(\w+)\}\}/g, (_, key) => vars[key] || "");
}

// Returns an error message string if invalid, null if valid.
function validateSkillName(skillName: string): string | null {
	if (!/^[a-z0-9-]+$/.test(skillName)) {
		return `Invalid skill name '${skillName}'\n   Skill names must be lowercase letters, digits, and hyphens only`;
	}
	if (
		skillName.startsWith("-") ||
		skillName.endsWith("-") ||
		skillName.includes("--")
	) {
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

async function initSkill(
	skillName: string,
	basePath: string,
): Promise<boolean> {
	const skillDir = resolve(basePath, skillName);
	const skillTitle = titleCase(skillName);

	// Validate skill name format first (before creating anything)
	const nameError = validateSkillName(skillName);
	if (nameError) {
		console.error(`${red("❌ Error:")} ${nameError}`);
		return false;
	}

	// Check if directory exists
	if (await exists(skillDir)) {
		console.error(
			`${red("❌ Error:")} Skill directory already exists: ${magenta(skillDir)}`,
		);
		return false;
	}

	// All validation passed - now we can start
	console.log(`${green("Initializing skill:")} ${skillName}`);
	console.log(`${dim(italic("Location:"))} ${magenta(skillDir)}\n`);

	try {
		// Create skill directory
		await Deno.mkdir(skillDir, { recursive: true });
		console.log(`${green("✅ Created skill directory:")} ${magenta(skillDir)}`);

		// Load and interpolate templates
		const vars = { skill_name: skillName, skill_title: skillTitle };

		// Create SKILL.md
		const skillTemplate = await loadTemplate("skill");
		const skillContent = interpolate(skillTemplate, vars);
		await Deno.writeTextFile(join(skillDir, "SKILL.md"), skillContent);
		console.log(`${green("✅ Created")} SKILL.md`);

		const referenceTemplate = await loadTemplate("reference");
		const referenceContent = interpolate(referenceTemplate, vars);
		await Deno.writeTextFile(
			join(skillDir, "example-reference.md"),
			referenceContent,
		);
		console.log(`${green("✅ Created")} example-reference.md`);

		// Create scripts/ directory
		await Deno.mkdir(join(skillDir, "scripts"));
		const scriptTemplate = await loadTemplate("script");
		const scriptContent = interpolate(scriptTemplate, vars);
		await Deno.writeTextFile(
			join(skillDir, "scripts", "example.ts"),
			scriptContent,
		);
		await Deno.chmod(join(skillDir, "scripts", "example.ts"), 0o755);
		console.log(`${green("✅ Created")} scripts/example.ts`);

		// Create assets/ directory
		await Deno.mkdir(join(skillDir, "assets"));
		const assetTemplate = await loadTemplate("asset");
		await Deno.writeTextFile(
			join(skillDir, "assets", "example_asset.txt"),
			assetTemplate,
		);
		console.log(`${green("✅ Created")} assets/example_asset.txt`);

		// Print next steps
		console.log(
			`\n${green("✅ Skill")} ${magenta(skillName)} ${green("initialized successfully")}`,
		);
		console.log(`\n${dim(italic("Next steps:"))}`);
		console.log(
			"1. Edit SKILL.md to complete the TODO items and update the description",
		);
		console.log(
			"2. Customize or delete the example reference file or the examples in scripts/, and assets/",
		);
		console.log("3. Run the validator when ready to check the skill structure");
		console.log(`   ${dim(italic("skillutil validate"))} ${magenta(skillDir)}`);

		return true;
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		console.error(`${red("❌ Error creating skill:")} ${message}`);
		return false;
	}
}

// ============================================================================
// Command: init --fork
// ============================================================================

async function forkSkill(
	skillName: string,
	basePath: string,
	forkUrl: string,
): Promise<boolean> {
	const skillDir = resolve(basePath, skillName);

	const nameError = validateSkillName(skillName);
	if (nameError) {
		console.error(`${red("❌ Error:")} ${nameError}`);
		return false;
	}

	// Validate GitHub URL and extract user/repo
	const match = forkUrl.match(
		/^https:\/\/github\.com\/([^/]+)\/([^/\s]+?)(?:\.git)?(?:\/.*)?$/,
	);
	if (!match) {
		console.error(`${red("❌ Error:")} Invalid GitHub URL`);
		console.error(
			`   ${dim(italic("Expected format:"))} https://github.com/user/repo`,
		);
		return false;
	}
	const [, user, repo] = match;

	// Check if destination already exists
	if (await exists(skillDir)) {
		console.error(
			`${red("❌ Error:")} Skill directory already exists: ${magenta(skillDir)}`,
		);
		return false;
	}

	const downloadUrl = `https://github.com/${user}/${repo}/archive/refs/heads/main.tar.gz`;

	console.log(
		`Forking ${magenta(`${user}/${repo}`)} as skill: ${magenta(skillName)}`,
	);
	console.log(`${dim(italic("Location:"))} ${magenta(skillDir)}\n`);

	let tmpFile: string | undefined;
	try {
		console.log("Downloading main branch HEAD...");
		const response = await fetch(downloadUrl);

		if (!response.ok) {
			console.error(
				`${red("❌ Error:")} Failed to fetch repository ${dim(italic(`(HTTP ${response.status})`))}`,
			);
			if (response.status === 404) {
				console.error(
					`   Repository not found or no main branch: ${magenta(forkUrl)}`,
				);
			}
			return false;
		}

		await Deno.mkdir(skillDir, { recursive: true });

		// Write tarball to temp file then extract (avoids streaming complexity)
		tmpFile = await Deno.makeTempFile({ suffix: ".tar.gz" });
		await Deno.writeFile(tmpFile, new Uint8Array(await response.arrayBuffer()));

		// --strip-components=1 removes the `repo-main/` prefix GitHub adds
		const tar = new Deno.Command("tar", {
			args: ["xzf", tmpFile, "--strip-components=1", "-C", skillDir],
			stderr: "piped",
		});
		const { success, stderr } = await tar.output();

		if (!success) {
			const errMsg = new TextDecoder().decode(stderr);
			console.error(`${red("❌ Error extracting archive:")} ${errMsg}`);
			await Deno.remove(skillDir, { recursive: true });
			return false;
		}

		console.log(
			`${green("✅ Forked")} ${magenta(`${user}/${repo}`)} to ${magenta(skillDir)}`,
		);

		const hasSkillMd = await exists(join(skillDir, "SKILL.md"));
		console.log(`\n${dim(italic("Next steps:"))}`);
		if (hasSkillMd) {
			console.log("1. Review and edit SKILL.md to fit your needs");
		} else {
			console.log(
				"1. Create SKILL.md with required frontmatter (name, description)",
			);
		}
		console.log("2. Customize the skill contents for your use case");
		console.log(
			`3. Validate when ready: ${dim(italic("skillutil validate"))} ${magenta(skillDir)}`,
		);

		return true;
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		console.error(`${red("❌ Error forking repository:")} ${message}`);
		if (await exists(skillDir)) {
			await Deno.remove(skillDir, { recursive: true });
		}
		return false;
	} finally {
		if (tmpFile) {
			try {
				await Deno.remove(tmpFile);
			} catch {
				/* ignore cleanup errors */
			}
		}
	}
}

// ============================================================================
// Command: validate
// ============================================================================

async function validateSkill(skillPath: string): Promise<ValidationResult> {
	const skillDir = resolve(skillPath);
	const skillMdPath = join(skillDir, "SKILL.md");

	// Check SKILL.md exists
	if (!(await exists(skillMdPath))) {
		return { valid: false, message: "SKILL.md not found" };
	}

	// Read and parse frontmatter
	const content = await Deno.readTextFile(skillMdPath);

	if (!content.startsWith("---")) {
		return { valid: false, message: "No YAML frontmatter found" };
	}

	const frontmatterMatch = content.match(/^---\n(.*?)\n---/s);
	if (!frontmatterMatch) {
		return { valid: false, message: "Invalid frontmatter format" };
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
		"name",
		"description",
		"license",
		"allowed-tools",
		"metadata",
	]);

	const unexpectedKeys = Object.keys(frontmatter).filter(
		(key) => !ALLOWED_PROPERTIES.has(key),
	);

	if (unexpectedKeys.length > 0) {
		return {
			valid: false,
			message:
				`Unexpected key(s) in SKILL.md frontmatter: ${unexpectedKeys.join(", ")}. ` +
				`Allowed properties are: ${Array.from(ALLOWED_PROPERTIES).join(", ")}`,
		};
	}

	// Check required fields exist and are strings
	if (frontmatter.name === undefined || frontmatter.name === null) {
		return { valid: false, message: "Missing 'name' in frontmatter" };
	}
	if (
		frontmatter.description === undefined ||
		frontmatter.description === null
	) {
		return { valid: false, message: "Missing 'description' in frontmatter" };
	}

	// Ensure name and description are strings
	if (typeof frontmatter.name !== "string") {
		return { valid: false, message: "'name' must be a string" };
	}
	if (typeof frontmatter.description !== "string") {
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
			message: "Description cannot contain angle brackets (< or >)",
		};
	}
	if (description.length > 1024) {
		return {
			valid: false,
			message: `Description is too long (${description.length} characters). Maximum is 1024 characters.`,
		};
	}

	return { valid: true, message: green("✅ Skill is valid!") };
}

// ============================================================================
// Command: refresh-docs
// ============================================================================

async function refreshDocs(): Promise<boolean> {
	console.log("Fetching latest Anthropic skill documentation...\n");

	try {
		let successCount = 0;

		for (const source of DOC_SOURCES) {
			try {
				console.log(`Fetching ${magenta(source.filename)}...`);
				const response = await fetch(source.url);

				if (!response.ok) {
					console.error(
						`  ${red("❌ Failed")} ${dim(italic(`(${response.status})`))} ${source.url}`,
					);
					continue;
				}

				const content = await response.text();
				const outputPath = join(SKILL_DEV_DIR, source.filename);
				await Deno.writeTextFile(outputPath, content);
				console.log(`  ${green("✅ Saved to")} ${magenta(outputPath)}`);
				successCount++;
			} catch (error) {
				const message = error instanceof Error ? error.message : String(error);
				console.error(
					`  ${red("❌ Error fetching")} ${magenta(source.filename)}: ${message}`,
				);
			}
		}

		console.log(
			`\n${green("✅ Fetched")} ${successCount}/${DOC_SOURCES.length} documents to ${magenta(SKILL_DEV_DIR)}`,
		);
		return successCount > 0;
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		console.error(`${red("❌ Error refreshing docs:")} ${message}`);
		return false;
	}
}

// ============================================================================
// Command: activate / deactivate
// ============================================================================

async function activateSkill(skillName: string): Promise<boolean> {
	const sourcePath = join(DEACTIVATED_SKILLS, skillName);
	const destPath = join(SKILLS_DIR, skillName);

	// Check source exists
	if (!(await exists(sourcePath))) {
		console.error(
			`${red("❌ Error:")} Skill ${magenta(skillName)} not found in deactivated skills`,
		);
		console.error(`   ${dim(italic("Expected at:"))} ${sourcePath}`);

		// Check if already active
		if (await exists(destPath)) {
			console.log(
				`   ${dim(italic(`(Skill is already active at: ${destPath})`))}`,
			);
		}
		return false;
	}

	// Check destination doesn't exist
	if (await exists(destPath)) {
		console.error(
			`${red("❌ Error:")} Skill ${magenta(skillName)} already exists in active skills`,
		);
		console.error(`   ${dim(italic("Location:"))} ${destPath}`);
		return false;
	}

	try {
		await move(sourcePath, destPath);
		console.log(`${green("✅ Activated")} ${magenta(skillName)}`);
		console.log(`   ${dim(italic("Moved from:"))} ${sourcePath}`);
		console.log(`   ${dim(italic("Moved to:"))}   ${destPath}`);
		return true;
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		console.error(`${red("❌ Error activating skill:")} ${message}`);
		return false;
	}
}

async function deactivateSkill(skillName: string): Promise<boolean> {
	const sourcePath = join(SKILLS_DIR, skillName);
	const destPath = join(DEACTIVATED_SKILLS, skillName);

	// Check source exists
	if (!(await exists(sourcePath))) {
		console.error(
			`${red("❌ Error:")} Skill ${magenta(skillName)} not found in active skills`,
		);
		console.error(`   ${dim(italic("Expected at:"))} ${sourcePath}`);

		// Check if already deactivated
		if (await exists(destPath)) {
			console.log(
				`   ${dim(italic(`(Skill is already deactivated at: ${destPath})`))}`,
			);
		}
		return false;
	}

	// Create deactivated directory if needed
	if (!(await exists(DEACTIVATED_SKILLS))) {
		await Deno.mkdir(DEACTIVATED_SKILLS, { recursive: true });
	}

	// Check destination doesn't exist
	if (await exists(destPath)) {
		console.error(
			`${red("❌ Error:")} Skill ${magenta(skillName)} already exists in deactivated skills`,
		);
		console.error(`   ${dim(italic("Location:"))} ${destPath}`);
		return false;
	}

	try {
		await move(sourcePath, destPath);
		console.log(`${green("✅ Deactivated")} ${magenta(skillName)}`);
		console.log(`   ${dim(italic("Moved from:"))} ${sourcePath}`);
		console.log(`   ${dim(italic("Moved to:"))}   ${destPath}`);
		return true;
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		console.error(`${red("❌ Error deactivating skill:")} ${message}`);
		return false;
	}
}

// ============================================================================
// Command: list
// ============================================================================

async function listSkills(all: boolean): Promise<boolean> {
	const skills: { name: string; active: boolean }[] = [];

	// Collect active skills
	if (await exists(SKILLS_DIR)) {
		for await (const entry of Deno.readDir(SKILLS_DIR)) {
			if (entry.isDirectory) {
				skills.push({ name: entry.name, active: true });
			}
		}
	}

	// Collect deactivated skills if --all
	if (all && (await exists(DEACTIVATED_SKILLS))) {
		for await (const entry of Deno.readDir(DEACTIVATED_SKILLS)) {
			if (entry.isDirectory) {
				skills.push({ name: entry.name, active: false });
			}
		}
	}

	skills.sort((a, b) => a.name.localeCompare(b.name));

	if (skills.length === 0) {
		console.log("No skills found.");
		return true;
	}

	for (const skill of skills) {
		if (skill.active) {
			console.log(`  ${skill.name}`);
		} else {
			console.log(`  ${dim(italic(skill.name))}`);
		}
	}

	const activeCount = skills.filter((s) => s.active).length;
	const deactivatedCount = skills.length - activeCount;
	const summary =
		deactivatedCount > 0
			? `\n${green(`${activeCount} active`)}, ${dim(italic(`${deactivatedCount} deactivated`))}`
			: `\n${skills.length} skill${skills.length === 1 ? "" : "s"}`;
	console.log(summary);

	return true;
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
		console.error(
			`${yellow("🚧 Skipping")} ${magenta(skillName)}: already exists at ${magenta(destDir)}`,
		);
		return false;
	}

	try {
		await move(sourceDir, destDir);
		console.log(
			`${green("✅ Added")} ${magenta(skillName)} from ${magenta(italic(repoLabel))} → ${magenta(destDir)}`,
		);
		return true;
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		console.error(
			`${red("❌ Error installing")} ${magenta(skillName)}: ${message}`,
		);
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
		console.error(`${red("❌ Error:")} Invalid GitHub tree URL`);
		console.error(
			`   ${dim(italic("Expected:"))} https://github.com/user/repo/tree/branch[/path]`,
		);
		console.error(
			`   ${dim(italic("For plain repo URLs, use:"))} skillutil init --fork <url>`,
		);
		return false;
	}

	const [, user, repo, ref, subpathRaw] = match;
	const subpath = subpathRaw ? subpathRaw.replace(/^\//, "") : "";

	console.log(`Adding from ${magenta(`${user}/${repo}`)} @ ${magenta(ref)}...`);

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
		console.error(
			`${red("❌ Failed to fetch repository")} ${dim(italic(`(HTTP ${response.status})`))}`,
		);
		if (response.status === 404) {
			console.error(
				`   ${magenta(ref)} not found as a branch or tag in ${magenta(`${user}/${repo}`)}`,
			);
			console.error(
				`   ${dim(italic("For unusual branch names (e.g. feature/x), use gunk manually"))}`,
			);
		}
		return false;
	}

	let tmpFile: string | undefined;
	let tmpDir: string | undefined;

	try {
		console.log("Downloading...");
		tmpFile = await Deno.makeTempFile({ suffix: ".tar.gz" });
		await Deno.writeFile(tmpFile, new Uint8Array(await response.arrayBuffer()));

		tmpDir = await Deno.makeTempDir();

		// Extract full archive, stripping the `repo-ref/` prefix GitHub adds to all paths
		const tar = new Deno.Command("tar", {
			args: ["xzf", tmpFile, "--strip-components=1", "-C", tmpDir],
			stderr: "piped",
		});
		const { success, stderr } = await tar.output();
		if (!success) {
			console.error(
				`${red("❌ Error extracting archive:")} ${new TextDecoder().decode(stderr)}`,
			);
			return false;
		}

		// Navigate to the target subpath within the extracted tree
		const targetDir = subpath
			? join(tmpDir, ...subpath.split("/").filter(Boolean))
			: tmpDir;

		if (!(await exists(targetDir))) {
			console.error(
				`${red("❌ Path not found in repository:")} ${magenta(subpath || "(root)")}`,
			);
			return false;
		}

		// Single-skill: SKILL.md exists directly at targetDir
		if (await exists(join(targetDir, "SKILL.md"))) {
			const skillName = subpath.split("/").filter(Boolean).pop() ?? repo;
			const ok = await installSkill(
				targetDir,
				destPath,
				skillName,
				`${user}/${repo}`,
			);
			if (ok) {
				console.log(`\n${dim(italic("Next steps:"))}`);
				console.log("1. Review SKILL.md to ensure it fits your setup");
				console.log(
					`2. Validate: ${dim(italic("skillutil validate"))} ${magenta(join(destPath, skillName))}`,
				);
			}
			return ok;
		}

		// Multi-skill: scan direct subdirectories for SKILL.md
		const skills: string[] = [];
		for await (const entry of Deno.readDir(targetDir)) {
			if (!entry.isDirectory) continue;
			if (await exists(join(targetDir, entry.name, "SKILL.md"))) {
				skills.push(entry.name);
			}
		}

		if (skills.length === 0) {
			console.error(
				`${red("❌ No skills found:")} no SKILL.md at the given path or its direct subdirectories`,
			);
			console.error(
				`   ${dim(italic("Checked:"))} ${magenta(subpath || "(repo root)")}`,
			);
			return false;
		}

		skills.sort();
		console.log(
			`Found ${skills.length} skill(s): ${skills.map((s) => magenta(s)).join(", ")}\n`,
		);

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

		console.log(
			`\n${green("✅ Added")} ${successCount}/${skills.length} skills to ${magenta(destPath)}`,
		);
		return successCount > 0;
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		console.error(`${red("❌ Error:")} ${message}`);
		return false;
	} finally {
		if (tmpFile) {
			try {
				await Deno.remove(tmpFile);
			} catch {
				/* ignore */
			}
		}
		if (tmpDir) {
			try {
				await Deno.remove(tmpDir, { recursive: true });
			} catch {
				/* ignore */
			}
		}
	}
}

// ============================================================================
// CLI Definition with Cliffy
// ============================================================================

const cli = new Command()
	.name("skillutil")
	.version("0.1.0")
	.description("Cross-agent Skill management CLI")
	.meta("Author", "winnie [gwenwindflower@gh] + Claude Code")
	.meta("Docs", "https://code.claude.com/docs/en/skills")
	.meta("Templates", TEMPLATE_DIR)
	.meta("Active User Skills", SKILLS_DIR)
	.meta("Deactivated User Skills", DEACTIVATED_SKILLS);

// Init command
cli
	.command("init <skill-name:string>")
	.description("Initialize a new skill from template")
	.option("-p, --path <path:string>", "Base path for new skill", {
		default: SKILLS_DIR,
	})
	.option(
		"-f, --fork <url:string>",
		"Use a GitHub repo as the skill basis (main branch HEAD)",
	)
	.example("Create in default location", "skillutil init my-new-skill")
	.example(
		"Create in custom location",
		"skillutil init my-new-skill --path skills/public",
	)
	.example(
		"Fork from GitHub",
		"skillutil init my-skill --fork https://github.com/user/repo",
	)
	.action(async (options, skillName) => {
		const success = options.fork
			? await forkSkill(skillName, options.path, options.fork)
			: await initSkill(skillName, options.path);
		Deno.exit(success ? 0 : 1);
	});

// Validate command
cli
	.command("validate <skill-path:string>")
	.description("Validate skill structure and frontmatter")
	.example("Validate a skill", "skillutil validate agents/shared/skills/my-skill")
	.action(async (_options, skillPath) => {
		const result = await validateSkill(skillPath);
		console.log(result.message);
		Deno.exit(result.valid ? 0 : 1);
	});

// Refresh-docs command
cli
	.command("refresh-docs")
	.description("Fetch latest Anthropic skill documentation")
	.example("Update docs", "skillutil refresh-docs")
	.action(async () => {
		const success = await refreshDocs();
		Deno.exit(success ? 0 : 1);
	});

// Activate command
cli
	.command("activate <skill-name:string>")
	.description("Move skill from deactivated to active")
	.example("Enable a skill", "skillutil activate old-skill")
	.action(async (_options, skillName) => {
		const success = await activateSkill(skillName);
		Deno.exit(success ? 0 : 1);
	});

// Deactivate command
cli
	.command("deactivate <skill-name:string>")
	.description("Move skill from active to deactivated")
	.example("Disable a skill", "skillutil deactivate old-skill")
	.action(async (_options, skillName) => {
		const success = await deactivateSkill(skillName);
		Deno.exit(success ? 0 : 1);
	});

// List command
cli
	.command("list")
	.description("List skills")
	.option("-a, --all", "Include deactivated skills", { default: false })
	.example("List active skills", "skillutil list")
	.example("List all skills", "skillutil list --all")
	.action(async (options) => {
		const success = await listSkills(options.all);
		Deno.exit(success ? 0 : 1);
	});

// Add command
cli
	.command("add <github-url:string>")
	.description(
		"Add skill(s) from a GitHub tree URL — single skill or a whole skills directory",
	)
	.option(
		"-p, --path <path:string>",
		"Destination directory for added skills",
		{
			default: SKILLS_DIR,
		},
	)
	.example(
		"Add a single skill",
		"skillutil add https://github.com/user/repo/tree/main/skills/my-skill",
	)
	.example(
		"Add all skills from a directory",
		"skillutil add https://github.com/user/repo/tree/main/skills",
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

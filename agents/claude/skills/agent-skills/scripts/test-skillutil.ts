#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env=HOME,TMPDIR --allow-net=platform.claude.com,code.claude.com

/**
 * Test suite for skillutil
 *
 * Run with: deno task skillutil:test
 *
 * Tests all commands in isolation using a temporary directory
 */

import { join } from '@std/path';
import { exists } from '@std/fs';

// ============================================================================
// Test Framework
// ============================================================================

interface TestResult {
  name: string;
  passed: boolean;
  message?: string;
}

const results: TestResult[] = [];
let testCount = 0;
let passCount = 0;

function test(name: string, fn: () => Promise<boolean> | boolean) {
  return async () => {
    testCount++;
    console.log(`\n🧪 Test ${testCount}: ${name}`);
    try {
      const passed = await fn();
      if (passed) {
        passCount++;
        console.log('   ✅ PASS');
        results.push({ name, passed: true });
      } else {
        console.log('   ❌ FAIL');
        results.push({ name, passed: false });
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.log(`   ❌ ERROR: ${message}`);
      results.push({ name, passed: false, message });
    }
  };
}

// ============================================================================
// Helper Functions
// ============================================================================

async function runSkillutil(
  args: string[],
): Promise<{ code: number; stdout: string; stderr: string }> {
  const scriptPath = new URL('./skillutil.ts', import.meta.url).pathname;
  const cmd = new Deno.Command('deno', {
    args: [
      'run',
      '--allow-read',
      '--allow-write',
      '--allow-env=HOME,TMPDIR',
      '--allow-net=platform.claude.com,code.claude.com',
      scriptPath,
      ...args,
    ],
    stdout: 'piped',
    stderr: 'piped',
  });

  const { code, stdout, stderr } = await cmd.output();
  return {
    code,
    stdout: new TextDecoder().decode(stdout),
    stderr: new TextDecoder().decode(stderr),
  };
}

async function cleanupTestDir(dir: string) {
  try {
    await Deno.remove(dir, { recursive: true });
  } catch {
    // Ignore cleanup errors
  }
}

// ============================================================================
// Tests
// ============================================================================

async function main() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  skillutil Test Suite');
  console.log('═══════════════════════════════════════════════════════════');

  const tmpDir = await Deno.makeTempDir({ prefix: 'skillutil-test-' });
  console.log(`\n📁 Test directory: ${tmpDir}`);

  try {
    // Test 1: Help command works
    await test('Help command shows usage', async () => {
      const result = await runSkillutil(['--help']);
      return result.code === 0 && result.stdout.includes('skillutil');
    })();

    // Test 2: Version command works
    await test('Version command shows version', async () => {
      const result = await runSkillutil(['--version']);
      return result.code === 0 && result.stdout.includes('0.1.0');
    })();

    // Test 3: Init creates skill with all files
    await test('Init command creates skill structure', async () => {
      const skillDir = join(tmpDir, 'test-skill');
      const result = await runSkillutil(['init', 'test-skill', '--path', tmpDir]);

      if (result.code !== 0) {
        console.log('   Init failed:', result.stderr);
        return false;
      }

      // Check all expected files exist
      const checks = [
        exists(skillDir),
        exists(join(skillDir, 'SKILL.md')),
        exists(join(skillDir, 'scripts', 'example.ts')),
        exists(join(skillDir, 'references', 'api_reference.md')),
        exists(join(skillDir, 'assets', 'example_asset.txt')),
      ];

      const allExist = (await Promise.all(checks)).every((x) => x);
      if (!allExist) {
        console.log('   Some files missing');
      }
      return allExist;
    })();

    // Test 4: Init rejects invalid skill names
    await test('Init rejects invalid skill names', async () => {
      const tests = [
        { name: 'Invalid-Name', reason: 'uppercase' },
        { name: '-invalid', reason: 'starts with hyphen' },
        { name: 'invalid-', reason: 'ends with hyphen' },
        { name: 'invalid--name', reason: 'double hyphen' },
      ];

      for (const t of tests) {
        const result = await runSkillutil(['init', t.name, '--path', tmpDir]);
        if (result.code === 0) {
          console.log(`   Should have rejected: ${t.name} (${t.reason})`);
          return false;
        }
      }
      return true;
    })();

    // Test 5: Validate accepts valid skill
    await test('Validate accepts valid skill', async () => {
      const skillDir = join(tmpDir, 'test-skill');
      const result = await runSkillutil(['validate', skillDir]);

      return result.code === 0 && result.stdout.includes('✅');
    })();

    // Test 6: Validate rejects invalid frontmatter
    await test('Validate rejects skill without frontmatter', async () => {
      const invalidSkillDir = join(tmpDir, 'invalid-skill');
      await Deno.mkdir(invalidSkillDir, { recursive: true });
      await Deno.writeTextFile(
        join(invalidSkillDir, 'SKILL.md'),
        'No frontmatter here!',
      );

      const result = await runSkillutil(['validate', invalidSkillDir]);
      return result.code === 1 && result.stdout.includes('frontmatter');
    })();

    // Test 7: Validate rejects missing required fields
    await test('Validate rejects missing required fields', async () => {
      const noNameSkillDir = join(tmpDir, 'no-name-skill');
      await Deno.mkdir(noNameSkillDir, { recursive: true });
      await Deno.writeTextFile(
        join(noNameSkillDir, 'SKILL.md'),
        '---\ndescription: Missing name\n---\n# Skill\n',
      );

      const result = await runSkillutil(['validate', noNameSkillDir]);
      return result.code === 1 && result.stdout.includes('name');
    })();

    // Test 8: Init doesn't overwrite existing directory
    await test('Init prevents overwriting existing skill', async () => {
      const result = await runSkillutil(['init', 'test-skill', '--path', tmpDir]);
      return result.code === 1 && result.stderr.includes('already exists');
    })();

    // Test 9: Check generated SKILL.md has correct structure
    await test('Generated SKILL.md has proper format', async () => {
      const skillMd = await Deno.readTextFile(join(tmpDir, 'test-skill', 'SKILL.md'));

      const checks = [
        skillMd.startsWith('---'),
        skillMd.includes('name: test-skill'),
        skillMd.includes('description:'),
        skillMd.match(/---\n(.*?)\n---/s) !== null, // Has frontmatter block
      ];

      return checks.every((x) => x);
    })();

    // Test 10: Generated script is executable
    await test('Generated script is executable', async () => {
      const scriptPath = join(tmpDir, 'test-skill', 'scripts', 'example.ts');
      const fileInfo = await Deno.stat(scriptPath);
      // Check if executable bit is set (Unix permission check)
      return (fileInfo.mode! & 0o111) !== 0;
    })();

    // Test 11: Validate checks for unexpected frontmatter keys
    await test('Validate rejects unexpected frontmatter keys', async () => {
      const extraKeysDir = join(tmpDir, 'extra-keys-skill');
      await Deno.mkdir(extraKeysDir, { recursive: true });
      await Deno.writeTextFile(
        join(extraKeysDir, 'SKILL.md'),
        '---\nname: extra-keys\ndescription: Test\nunexpected: value\n---\n# Skill\n',
      );

      const result = await runSkillutil(['validate', extraKeysDir]);
      return result.code === 1 && result.stdout.includes('Unexpected');
    })();

    // Test 12: Unknown command fails gracefully
    await test('Unknown command fails with helpful message', async () => {
      const result = await runSkillutil(['unknown-command']);
      // Cliffy exits with code 2 for unknown commands and shows suggestions
      return result.code === 2 && result.stderr.includes('Unknown command');
    })();

    // Test 13: Skill name interpolation works
    await test('Template interpolation creates correct names', async () => {
      const skillMd = await Deno.readTextFile(join(tmpDir, 'test-skill', 'SKILL.md'));
      const scriptTs = await Deno.readTextFile(
        join(tmpDir, 'test-skill', 'scripts', 'example.ts'),
      );

      return (
        skillMd.includes('name: test-skill') &&
        scriptTs.includes('Test Skill') // Title case
      );
    })();

    // Note: Activate/deactivate tests would require setting up the actual
    // ~/.charmschool structure, which we avoid in isolated tests.
    // Those should be tested manually or in integration tests.

    console.log('\n═══════════════════════════════════════════════════════════');
    console.log('  Test Results');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`\nTotal: ${testCount} | Passed: ${passCount} | Failed: ${testCount - passCount}`);

    if (passCount === testCount) {
      console.log('\n✨ All tests passed!\n');
    } else {
      console.log('\n❌ Some tests failed:\n');
      results
        .filter((r) => !r.passed)
        .forEach((r) => {
          console.log(`   • ${r.name}${r.message ? `: ${r.message}` : ''}`);
        });
      console.log('');
    }
  } finally {
    // Cleanup
    console.log(`\n🧹 Cleaning up test directory: ${tmpDir}`);
    await cleanupTestDir(tmpDir);
  }

  Deno.exit(passCount === testCount ? 0 : 1);
}

if (import.meta.main) {
  await main();
}

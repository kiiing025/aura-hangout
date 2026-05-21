import { existsSync, readFileSync } from "node:fs";

const checks = [
  {
    file: "docs/studio-setup.md",
    snippets: [
      "Roblox Studio",
      "Rojo",
      "default.project.json",
      "AuraZone",
      "Enable Studio Access to API Services",
    ],
  },
  {
    file: "docs/playtest-checklist.md",
    snippets: [
      "One-player test",
      "Two-player test",
      "DataStore save test",
      "stillness bonus",
      "manual roll",
    ],
  },
  {
    file: "README.md",
    snippets: [
      "Local Checks",
      "Studio Setup",
      "node scripts/smoke-check.mjs",
      "docs/playtest-checklist.md",
    ],
  },
];

let failed = false;

for (const check of checks) {
  if (!existsSync(check.file)) {
    console.error(`FAIL: ${check.file} should exist`);
    failed = true;
    continue;
  }

  const source = readFileSync(check.file, "utf8");
  for (const snippet of check.snippets) {
    if (!source.includes(snippet)) {
      console.error(`FAIL: ${check.file} missing snippet: ${snippet}`);
      failed = true;
    }
  }
}

if (failed) {
  process.exit(1);
}

console.log("PASS: Studio setup and playtest docs are complete");

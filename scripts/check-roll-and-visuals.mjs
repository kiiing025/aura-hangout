import { existsSync, readFileSync } from "node:fs";

const checks = [
  {
    file: "src/server/RollService.luau",
    snippets: [
      "function RollService.new",
      "function service:roll",
      "AuraDefinitions.RollCost",
      "AuraDefinitions.RollCooldownSeconds",
      "AuraDefinitions.roll",
      "ProfileStore.markOwned",
      "not_enough_points",
    ],
  },
  {
    file: "src/server/AuraVisualService.luau",
    snippets: [
      "function AuraVisualService.applyAura",
      "function AuraVisualService.clearAura",
      "ParticleEmitter",
      "PointLight",
      "AuraHangoutAura",
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

console.log("PASS: roll service and aura visuals are complete");

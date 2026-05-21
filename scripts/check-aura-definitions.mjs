import { existsSync, readFileSync } from "node:fs";

const filePath = "src/shared/AuraDefinitions.luau";

function fail(message) {
  console.error(`FAIL: ${message}`);
  process.exitCode = 1;
}

if (!existsSync(filePath)) {
  fail(`${filePath} should exist`);
  process.exit(process.exitCode);
}

const source = readFileSync(filePath, "utf8");
const auraIds = [...source.matchAll(/id = "([^"]+)"/g)].map((match) => match[1]);
const requiredAuraIds = [
  "sunrise",
  "seafoam",
  "golden_dust",
  "rose_spark",
  "azure_breeze",
  "solar_ring",
  "rainbow_drift",
  "celestial_glow",
  "sunset_crown",
];

for (const auraId of requiredAuraIds) {
  if (!auraIds.includes(auraId)) {
    fail(`missing aura id ${auraId}`);
  }
}

const requiredSnippets = [
  "AuraDefinitions.RollCost = 25",
  "AuraDefinitions.EarnTickSeconds = 2",
  "AuraDefinitions.PointsPerStillTick = 5",
  "AuraDefinitions.MovementThreshold = 0.75",
  "AuraDefinitions.RollCooldownSeconds = 1.5",
  "function AuraDefinitions.getAuraById",
  "function AuraDefinitions.getTotalWeight",
  "function AuraDefinitions.roll",
];

for (const snippet of requiredSnippets) {
  if (!source.includes(snippet)) {
    fail(`missing snippet: ${snippet}`);
  }
}

if (process.exitCode) {
  process.exit(process.exitCode);
}

console.log("PASS: aura definitions are complete");

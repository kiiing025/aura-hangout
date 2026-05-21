import { existsSync, readFileSync } from "node:fs";

const file = "src/client/AuraHud.client.luau";

if (!existsSync(file)) {
  console.error(`FAIL: ${file} should exist`);
  process.exit(1);
}

const source = readFileSync(file, "utf8");
const snippets = [
  "AuraHangoutRemotes",
  "RollAura",
  "ProfileUpdated",
  "RollButton",
  "PointsLabel",
  "CurrentAuraLabel",
  "ResultLabel",
  "rollAura:InvokeServer",
  "profileUpdated.OnClientEvent",
];

let failed = false;
for (const snippet of snippets) {
  if (!source.includes(snippet)) {
    console.error(`FAIL: ${file} missing snippet: ${snippet}`);
    failed = true;
  }
}

if (failed) {
  process.exit(1);
}

console.log("PASS: client aura HUD is complete");

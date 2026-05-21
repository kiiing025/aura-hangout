import { existsSync, readFileSync } from "node:fs";

const checks = [
  {
    file: "src/server/WorldBuilder.luau",
    snippets: [
      "function WorldBuilder.build",
      "AuraZone",
      "SpawnLocation",
      "Lighting.ClockTime",
      "SunsetIsland",
    ],
  },
  {
    file: "src/server/StillnessService.luau",
    snippets: [
      "function StillnessService.new",
      "function service:start",
      "AuraDefinitions.EarnTickSeconds",
      "AuraDefinitions.PointsPerStillTick",
      "AuraDefinitions.MovementThreshold",
      "profile.points +=",
    ],
  },
  {
    file: "src/server/init.server.luau",
    snippets: [
      "Players.PlayerAdded",
      "Players.PlayerRemoving",
      "game:BindToClose",
      "RollAura.OnServerInvoke",
      "ProfileUpdated:FireClient",
      "leaderstats",
    ],
    forbiddenSnippets: [
      "require(script:WaitForChild(",
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

  for (const snippet of check.forbiddenSnippets ?? []) {
    if (source.includes(snippet)) {
      console.error(`FAIL: ${check.file} contains forbidden snippet: ${snippet}`);
      failed = true;
    }
  }
}

if (failed) {
  process.exit(1);
}

console.log("PASS: world builder, stillness loop, and server bootstrap are complete");

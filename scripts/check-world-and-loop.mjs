import { existsSync, readFileSync } from "node:fs";

const checks = [
  {
    file: "src/server/WorldBuilder.luau",
    snippets: [
      "function WorldBuilder.build",
      "local existing = workspace:FindFirstChild(WORLD_FOLDER_NAME)",
      "return getExistingWorld(existing)",
      "local flatCylinderCFrame = CFrame.Angles(0, 0, math.rad(90))",
      "Vector3.new(8, 96, 96)",
      "AuraZone",
      "SpawnLocation",
      "Lighting.ClockTime",
      "SunsetIsland",
    ],
  },
  {
    file: "src/workspace/SunsetIsland.model.json",
    snippets: [
      "\"ClassName\": \"Folder\"",
      "\"Size\": [8, 96, 96]",
      "\"Orientation\": [0, 0, 90]",
      "\"Name\": \"FloatingGrassIsland\"",
      "\"Name\": \"AuraZone\"",
      "\"Name\": \"SpawnLocation\"",
      "\"ClassName\": \"PointLight\"",
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
      "local serverRoot = script",
      "require(serverRoot:WaitForChild(\"ProfileStore\"))",
      "require(serverRoot:WaitForChild(\"WorldBuilder\"))",
    ],
    forbiddenSnippets: [
      "local serverRoot = script.Parent",
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

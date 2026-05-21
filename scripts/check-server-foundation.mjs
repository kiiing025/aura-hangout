import { existsSync, readFileSync } from "node:fs";

const checks = [
  {
    file: "src/server/ProfileStore.luau",
    snippets: [
      "DataStoreService:GetDataStore",
      "function ProfileStore.load",
      "function ProfileStore.save",
      "function ProfileStore.markOwned",
      "ownedAuras",
      "equippedAura",
    ],
  },
  {
    file: "src/server/RemoteBuilder.luau",
    snippets: [
      "AuraHangoutRemotes",
      "RollAura",
      "ProfileUpdated",
      "RemoteFunction",
      "RemoteEvent",
      "function RemoteBuilder.build",
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

console.log("PASS: server profile and remote foundation is complete");

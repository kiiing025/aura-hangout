import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const root = process.cwd();

function assert(condition, message) {
  if (!condition) {
    console.error(`FAIL: ${message}`);
    process.exitCode = 1;
  }
}

function readJson(filePath) {
  try {
    return JSON.parse(readFileSync(filePath, "utf8"));
  } catch (error) {
    console.error(`FAIL: Could not parse ${filePath}: ${error.message}`);
    process.exitCode = 1;
    return null;
  }
}

const requiredPaths = [
  "default.project.json",
  "src/shared",
  "src/server",
  "src/client",
];

for (const relativePath of requiredPaths) {
  assert(existsSync(path.join(root, relativePath)), `${relativePath} should exist`);
}

const projectPath = path.join(root, "default.project.json");
if (existsSync(projectPath)) {
  const project = readJson(projectPath);
  if (project) {
    assert(project.name === "Aura Hangout", "project name should be Aura Hangout");
    assert(project.tree?.$className === "DataModel", "project root should be a DataModel");
    assert(Boolean(project.tree?.ReplicatedStorage?.Shared?.$path), "ReplicatedStorage.Shared should map to src/shared");
    assert(Boolean(project.tree?.ServerScriptService?.Server?.$path), "ServerScriptService.Server should map to src/server");
    assert(
      Boolean(project.tree?.StarterPlayer?.StarterPlayerScripts?.Client?.$path),
      "StarterPlayerScripts.Client should map to src/client"
    );
  }
}

if (process.exitCode) {
  process.exit(process.exitCode);
}

console.log("PASS: Rojo scaffold is present");

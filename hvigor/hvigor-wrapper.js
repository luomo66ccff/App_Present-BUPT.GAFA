'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const candidates = [];

function addCandidate(candidate) {
  if (!candidate) {
    return;
  }
  const resolved = path.resolve(candidate);
  if (!candidates.includes(resolved)) {
    candidates.push(resolved);
  }
}

function addHvigorHome(home) {
  if (!home) {
    return;
  }
  addCandidate(path.join(home, 'bin', 'hvigorw.js'));
  addCandidate(path.join(home, 'hvigorw.js'));
}

function addDevEcoHome(home) {
  if (!home) {
    return;
  }
  addCandidate(path.join(home, 'tools', 'hvigor', 'bin', 'hvigorw.js'));
}

addCandidate(process.env.HVIGORW_JS);
addHvigorHome(process.env.HVIGOR_HOME);
addDevEcoHome(process.env.DEVECO_STUDIO_HOME);
addDevEcoHome(process.env.DEVECO_HOME);

const nodeDirectory = path.dirname(process.execPath);
addCandidate(path.resolve(nodeDirectory, '..', 'hvigor', 'bin', 'hvigorw.js'));
addCandidate(path.resolve(nodeDirectory, '..', '..', 'hvigor', 'bin', 'hvigorw.js'));

if (process.platform === 'win32') {
  addDevEcoHome(path.join(process.env.ProgramFiles || 'C:\\Program Files', 'Huawei', 'DevEco Studio'));
  if (process.env.LOCALAPPDATA) {
    addDevEcoHome(path.join(process.env.LOCALAPPDATA, 'Huawei', 'DevEco Studio'));
  }
} else if (process.platform === 'darwin') {
  addDevEcoHome('/Applications/DevEco-Studio.app/Contents');
  addDevEcoHome('/Applications/DevEco Studio.app/Contents');
} else {
  addDevEcoHome('/opt/DevEco-Studio');
  addDevEcoHome('/opt/deveco-studio');
}

const hvigorwScript = candidates.find((candidate) => {
  try {
    return fs.statSync(candidate).isFile();
  } catch (_error) {
    return false;
  }
});

if (!hvigorwScript) {
  console.error([
    'ERROR: DevEco Hvigor was not found.',
    'Install DevEco Studio or HarmonyOS command-line tools, then set one of:',
    '  HVIGORW_JS=<absolute path to tools/hvigor/bin/hvigorw.js>',
    '  HVIGOR_HOME=<absolute path to the Hvigor directory>',
    '  DEVECO_STUDIO_HOME=<absolute path to DevEco Studio>'
  ].join('\n'));
  process.exit(1);
}

const result = spawnSync(process.execPath, [hvigorwScript, ...process.argv.slice(2)], {
  cwd: process.cwd(),
  env: process.env,
  stdio: 'inherit'
});

if (result.error) {
  console.error(`ERROR: Failed to start Hvigor: ${result.error.message}`);
  process.exit(1);
}

process.exit(typeof result.status === 'number' ? result.status : 1);

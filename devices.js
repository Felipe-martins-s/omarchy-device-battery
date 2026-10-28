// Pure merging rules, shared by the D-Bus reader and the regression tests.
export function validLevel(level) {
  return typeof level === 'number' && Number.isFinite(level) && level >= 0 && level <= 100;
}

export function bluezPath(path) {
  return path.replace(/^\/io\/github\/maniacx\/BudsLink\/Devices\//, '/org/bluez/');
}

export function mergeDevices(bluetooth, buds) {
  const connected = new Map(bluetooth.filter(device => device.connected)
    .map(device => [device.path, device]));
  const result = new Map();
  for (const device of buds) {
    const path = bluezPath(device.path);
    if (!connected.has(path)) continue;
    const state = device.state || {};
    if (![1, 2, 3].some(i => validLevel(state[`battery${i}Level`]) &&
      ['charging', 'discharging'].includes(state[`battery${i}Status`]))) continue;
    result.set(path, {...device, path, source: 'budslink'});
  }
  for (const device of connected.values()) {
    if (result.has(device.path) || !validLevel(device.percentage)) continue;
    result.set(device.path, {
      path: device.path,
      alias: device.alias,
      source: 'bluetooth',
      single: true,
      state: {battery1Level: device.percentage, battery1Status: 'unknown'},
    });
  }
  return [...result.values()].sort((a, b) => a.path.localeCompare(b.path));
}

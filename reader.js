// Read BudsLink and BlueZ's public APIs; never open another Bluetooth socket.
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import GLibUnix from 'gi://GLibUnix';
import {mergeDevices} from './devices.js';

Gio._promisify(Gio.DBusConnection.prototype, 'call');
const APP = 'io.github.maniacx.BudsLink';
const ROOT = '/io/github/maniacx/BudsLink';
const MANAGER = APP + '.DeviceManager';
const DEVICE = APP + '.Device';
const CLIENT = 'omarchy-buds-' + GLib.uuid_string_random();
const session = Gio.DBus.session;
const system = Gio.DBus.system;
const loop = new GLib.MainLoop(null, false);
let busy = false;
let previous = '';
let lastStart = -30;
let lastHold = -60;
let held = false;
let stopping = false;

async function call(bus, name, path, iface, method, args = null) {
  const result = await bus.call(name, path, iface, method, args, null,
    Gio.DBusCallFlags.NO_AUTO_START, 3000, null);
  return result.deepUnpack();
}

function emit(devices) {
  const json = JSON.stringify(devices);
  if (json !== previous) {
    print(json);
    previous = json;
  }
}

async function bluetoothDevices() {
  const [objects] = await call(system, 'org.bluez', '/',
    'org.freedesktop.DBus.ObjectManager', 'GetManagedObjects');
  return Object.entries(objects).flatMap(([path, interfaces]) => {
    const device = interfaces['org.bluez.Device1'];
    if (!device) return [];
    return [{
      path,
      connected: device.Connected?.deepUnpack() === true,
      alias: device.Alias?.deepUnpack() || device.Name?.deepUnpack() || 'Bluetooth',
      uuids: device.UUIDs?.deepUnpack() || [],
      percentage: interfaces['org.bluez.Battery1']?.Percentage?.deepUnpack(),
    }];
  });
}

async function refresh() {
  if (busy || stopping) return;
  busy = true;
  try {
    const bluetooth = await bluetoothDevices();
    // Publish the fallback even if BudsLink's API is unavailable or restarting.
    let buds = [];
    try {
    const [owned] = await call(session, 'org.freedesktop.DBus', '/org/freedesktop/DBus',
      'org.freedesktop.DBus', 'NameHasOwner', new GLib.Variant('(s)', [APP]));
    const now = GLib.get_monotonic_time() / 1000000;
    if (!owned) {
      held = false;
      lastHold = -60;
      emit(mergeDevices(bluetooth, []));
      if (now - lastStart >= 30) {
        lastStart = now;
        if (bluetooth.some(device => device.connected &&
          device.uuids.includes('0000fd2d-0000-1000-8000-00805f9b34fb')))
          Gio.Subprocess.new(['flatpak', 'run', APP, '--gapplication-service'],
            Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_SILENCE);
      }
      return;
    }

    const [paths] = await call(session, APP, ROOT, MANAGER, 'ListDevices');
    for (const path of paths) {
      try {
        const [props] = await call(session, APP, path, 'org.freedesktop.DBus.Properties',
          'GetAll', new GLib.Variant('(s)', [DEVICE]));
        const state = JSON.parse(props.State.deepUnpack());
        const config = JSON.parse(props.Config.deepUnpack());
        buds.push({path, alias: props.Alias.deepUnpack(), state,
          single: !config.battery2Icon && !config.battery3Icon});
      } catch (error) {
        // A device can disappear between ListDevices and GetAll.
      }
    }
    emit(mergeDevices(bluetooth, buds));
    if (paths.length && (!held || now - lastHold >= 60)) {
      await call(session, APP, ROOT, MANAGER, 'HoldService', new GLib.Variant('(s)', [CLIENT]));
      held = true;
      lastHold = now;
    } else if (!paths.length && held) {
      await call(session, APP, ROOT, MANAGER, 'ReleaseService', new GLib.Variant('(s)', [CLIENT]));
      held = false;
    }
    } catch (error) {
      // A BudsLink failure must not hide standard Bluetooth batteries.
      emit(mergeDevices(bluetooth, buds));
    }
  } catch (error) {
    emit([]);
  } finally {
    busy = false;
  }
}

// Signals provide immediate updates; a slow fallback covers startup/reconnect races.
session.signal_subscribe(APP, 'org.freedesktop.DBus.Properties', 'PropertiesChanged',
  null, DEVICE, Gio.DBusSignalFlags.NONE, () => refresh());
session.signal_subscribe(APP, MANAGER, null, ROOT, null,
  Gio.DBusSignalFlags.NONE, () => refresh());
session.signal_subscribe('org.freedesktop.DBus', 'org.freedesktop.DBus', 'NameOwnerChanged',
  '/org/freedesktop/DBus', APP, Gio.DBusSignalFlags.NONE, () => refresh());
system.signal_subscribe('org.bluez', 'org.freedesktop.DBus.Properties', 'PropertiesChanged',
  null, null, Gio.DBusSignalFlags.NONE, () => refresh());
system.signal_subscribe('org.bluez', 'org.freedesktop.DBus.ObjectManager', null,
  '/', null, Gio.DBusSignalFlags.NONE, () => refresh());
GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 5, () => {
  refresh();
  return GLib.SOURCE_CONTINUE;
});

for (const signal of [2, 15]) {
  GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal, () => {
    stopping = true;
    if (held) {
      try {
        session.call_sync(APP, ROOT, MANAGER, 'ReleaseService',
          new GLib.Variant('(s)', [CLIENT]), null, Gio.DBusCallFlags.NO_AUTO_START, 1000, null);
      } catch (error) { /* BudsLink may already have exited. */ }
    }
    loop.quit();
    return GLib.SOURCE_REMOVE;
  });
}
refresh();
loop.run();

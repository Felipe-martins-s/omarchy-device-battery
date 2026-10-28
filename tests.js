import {mergeDevices, validLevel} from './devices.js';

function check(condition, message) {
  if (!condition) throw new Error(message);
}
const path = '/org/bluez/hci0/dev_AA_BB';
const bt = {path, connected: true, alias: 'Headphones', percentage: 65};
const buds = {path: '/io/github/maniacx/BudsLink/Devices/hci0/dev_AA_BB',
  alias: 'Earbuds', single: false,
  state: {battery1Level: 80, battery1Status: 'charging'}};

check(mergeDevices([], []).length === 0, 'Empty sources must hide the widget');
check(mergeDevices([bt], [])[0].state.battery1Level === 65, 'Bluetooth-only battery');
check(mergeDevices([bt], [])[0].single, 'Bluetooth battery must use single-battery layout');
check(mergeDevices([{...bt, connected: false}], [buds]).length === 0,
  'Disconnected devices must hide even with cached BudsLink readings');
check(mergeDevices([{...bt, percentage: undefined}], []).length === 0,
  'Connected without a battery must hide');
const preferred = mergeDevices([bt], [buds]);
check(preferred.length === 1 && preferred[0].source === 'budslink',
  'Prefer BudsLink and deduplicate by BlueZ path');
check(mergeDevices([bt], [{...buds, state: {}}])[0].source === 'bluetooth',
  'Unavailable BudsLink readings must fall back');
check(mergeDevices([bt], [{...buds, state: {battery1Level: 101,
  battery1Status: 'charging'}}])[0].source === 'bluetooth', 'Reject invalid BudsLink level');
const other = {...bt, path: '/org/bluez/hci1/dev_CC_DD', alias: 'Mouse', percentage: 0};
const multiple = mergeDevices([bt, other], [buds]);
check(multiple.length === 2 && multiple.some(device => device.alias === 'Mouse'),
  'Show detailed and standard batteries together, including 0%');
for (const invalid of [-1, 101, NaN, Infinity, null, undefined, '85'])
  check(!validLevel(invalid), `Invalid battery: ${invalid}`);
check(validLevel(0) && validLevel(100), 'Boundary levels are valid');
print('All battery merge tests passed.');

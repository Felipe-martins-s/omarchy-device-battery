import Gio from 'gi://Gio';
import GLib from 'gi://GLib';

const directory = GLib.path_get_dirname(GLib.filename_from_uri(import.meta.url)[0]);
const [, bytes] = Gio.File.new_for_path(GLib.build_filenamev([directory, 'I18n.js'])).load_contents(null);
const source = new TextDecoder().decode(bytes).replace(/^\.pragma library\s*/, '');
const i18n = new Function(source + '\nreturn {catalogs, translate};')();

function check(condition, message) {
  if (!condition) throw new Error(message);
}
const portuguese = Object.keys(i18n.catalogs['pt-BR']).sort();
const english = Object.keys(i18n.catalogs.en).sort();
check(JSON.stringify(portuguese) === JSON.stringify(english), 'Both languages must cover the same keys');
for (const language of ['pt-BR', 'en']) {
  for (const key of portuguese)
    check(typeof i18n.catalogs[language][key] === 'string' && i18n.catalogs[language][key].length > 0,
      `Missing ${language} translation: ${key}`);
}
check(i18n.translate('en', 'leftShort') === 'L', 'English left abbreviation');
check(i18n.translate('en', 'rightShort') === 'R', 'English right abbreviation');
check(i18n.translate('pt-BR', 'leftShort') === 'E', 'Portuguese left abbreviation');
check(i18n.translate('pt-BR', 'rightShort') === 'D', 'Portuguese right abbreviation');
check(i18n.translate('unknown', 'battery') === 'Bateria', 'Unsupported locale falls back safely');
check(i18n.translate('en', 'unknown-key') === 'unknown-key', 'Unknown keys have a safe fallback');
for (const filename of ['BarWidget.qml', 'ConfigPanel.qml', 'DetailsPanel.qml']) {
  const [, content] = Gio.File.new_for_path(GLib.build_filenamev([directory, filename])).load_contents(null);
  for (const match of new TextDecoder().decode(content).matchAll(/\bt\("([^"]+)"\)/g))
    check(portuguese.includes(match[1]), `${filename}: unknown translation key ${match[1]}`);
}
print('All translation tests passed.');

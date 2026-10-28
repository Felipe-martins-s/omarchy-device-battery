#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
shell_root="${OMARCHY_PATH:-/usr/share/omarchy}/shell"
lint="${QMLLINT:-}"
if [[ -z $lint ]]; then
  lint=$(command -v qmllint || true)
fi
if [[ -z $lint && -x /usr/lib/qt6/bin/qmllint ]]; then
  lint=/usr/lib/qt6/bin/qmllint
fi
[[ -n $lint ]] || { echo 'qmllint not found; install Qt declarative tools.' >&2; exit 1; }
[[ -d $shell_root/Ui && -d $shell_root/Commons ]] || {
  echo "Installed Omarchy shell imports not found: $shell_root" >&2
  exit 1
}

# qmllint does not provide Quickshell's runtime qs.* import mapping itself.
# Keep these temporary aliases outside the plugin; no packaged files are edited.
imports=$(mktemp -d "${TMPDIR:-/tmp}/omarchy-device-battery-qml.XXXXXX")
cleanup() {
  rm -f -- "$imports/qs/Ui" "$imports/qs/Commons" "$imports/qs/services"
  rmdir -- "$imports/qs" "$imports"
}
trap cleanup EXIT
mkdir "$imports/qs"
ln -s "$shell_root/Ui" "$imports/qs/Ui"
ln -s "$shell_root/Commons" "$imports/qs/Commons"
ln -s "$shell_root/services" "$imports/qs/services"

"$lint" -I "$imports" -I "$shell_root" \
  "$root/BarWidget.qml" "$root/ConfigPanel.qml" "$root/DetailsPanel.qml" \
  "$root/BatteryIcon.qml" "$root/NativeLabel.qml"

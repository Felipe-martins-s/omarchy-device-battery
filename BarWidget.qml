pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui as Ui
import "Appearance.js" as Appearance
import "I18n.js" as I18n

Ui.BarWidget {
  id: root
  moduleName: "flpems.device-battery"
  property var devices: []
  readonly property string language: setting("language", "pt-BR") === "en" ? "en" : "pt-BR"
  function t(key) { return I18n.translate(root.language, key) }
  function sidePrefix(index) { return ["", t("leftShort"), t("rightShort"), t("caseShort")][index] + " " }
  readonly property bool useIcons: setting("displayMode", "Letras") === "Ícones"
  readonly property var preferences: setting("devicePreferences", ({}))
  readonly property bool opened: configPanel.open || detailsPanel.open
  function open() { configPanel.open = false; detailsPanel.open = true }
  function openSettings() { detailsPanel.open = false; configPanel.open = true }
  function close() { configPanel.open = false; detailsPanel.open = false }
  function toggle() {
    var wasOpen = configPanel.open
    close()
    configPanel.open = !wasOpen
  }
  function toggleDetails() {
    var wasOpen = detailsPanel.open
    close()
    detailsPanel.open = !wasOpen
  }

  function preference(device) { return preferences[Appearance.key(device)] || {} }
  function deviceUsesIcons(device) {
    var mode = preference(device).mode
    return mode === "Ícones" || (!mode && root.useIcons)
  }
  function deviceLabel(device) { return preference(device).label || device.alias }
  function deviceIcon(device, index) {
    return Appearance.iconKind(preference(device).icon || "auto", device.single, index)
  }
  function saveDevice(device, key, value) {
    var all = JSON.parse(JSON.stringify(root.preferences))
    var id = Appearance.key(device)
    var item = all[id] || {}
    item.alias = device.alias
    item.path = device.path
    item.single = device.single
    item[key] = value
    all[id] = item
    saveSetting("devicePreferences", all)
  }
  function saveSetting(key, value) {
    var entry = { id: root.moduleName }
    for (var name in root.settings) if (name !== "id") entry[name] = root.settings[name]
    entry[key] = value
    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }
  readonly property var configurableDevices: {
    var list = root.devices.slice()
    var seen = {}
    list.forEach(function(device) { seen[Appearance.key(device)] = true })
    for (var key in root.preferences) {
      var saved = root.preferences[key]
      if (!seen[key] && saved.path)
        list.push({path: saved.path, alias: saved.alias, single: saved.single, offline: true})
    }
    return list
  }

  function battery(device, index) {
    var state = device.state || {}
    var status = state["battery" + index + "Status"]
    var value = state["battery" + index + "Level"]
    if (status === "disconnected" || typeof value !== "number" || value < 0 || value > 100)
      return "—"
    return Math.round(value) + "%" + (status === "charging" ? "⚡" : "")
  }

  readonly property string label: devices.map(function(device) {
    if (device.single) return device.alias + " " + battery(device, 1)
    return sidePrefix(1) + battery(device, 1) + "  " + sidePrefix(2) + battery(device, 2) + "  " + sidePrefix(3) + battery(device, 3)
  }).join("  |  ")

  readonly property string details: devices.map(function(device) {
    return device.alias + (device.single ? "\n" + t("battery") + ": " + battery(device, 1)
      : "\n" + t("left") + ": " + battery(device, 1)
        + "\n" + t("right") + ": " + battery(device, 2) + "\n" + t("case") + ": " + battery(device, 3))
      + "\n" + t("source") + ": " + (device.source === "bluetooth" ? "Bluetooth" : "BudsLink")
      + "\n\n" + t("clickHints") + "\n" + t("unavailableHint")
  }).join("\n\n")

  implicitWidth: devices.length ? button.implicitWidth : 0
  implicitHeight: devices.length ? button.implicitHeight : 0
  visible: devices.length > 0

  Process {
    id: reader
    command: ["gjs", "-m", Qt.resolvedUrl("reader.js").toString().replace(/^file:\/\//, "")]
    running: true
    stdout: SplitParser {
      onRead: function(line) {
        try { root.devices = JSON.parse(line) } catch (error) { console.warn("Buds battery:", error) }
      }
    }
    onExited: {
      root.devices = []
      retry.restart()
    }
  }

  Timer {
    id: retry
    interval: 10000
    onTriggered: reader.running = true
  }

  Ui.WidgetButton {
    id: button
    anchors.fill: root
    bar: root.bar
    text: root.vertical ? root.label.replace(/  /g, "\n") : root.label
    labelVisible: false
    fixedWidth: !root.vertical ? icons.implicitWidth + button.scaledHorizontalMargin * 2 : -1
    fixedHeight: root.vertical ? icons.implicitHeight + button.scaledVerticalPadding * 2 : -1
    tooltipText: root.details
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton)
        root.toggle()
      else if (buttonCode === Qt.LeftButton)
        root.toggleDetails()
    }

    Grid {
      id: icons
      anchors.centerIn: parent
      columns: root.vertical ? 1 : Math.max(1, root.devices.length)
      spacing: 16

      Repeater {
        model: root.devices
        delegate: Grid {
          id: deviceGroup
          required property var modelData
          readonly property bool useIcons: root.deviceUsesIcons(modelData)
          columns: root.vertical ? 1 : 3
          spacing: 10

          Repeater {
            model: deviceGroup.modelData.single ? [1] : [1, 2, 3]
            delegate: Row {
              id: batteryGroup
              required property int modelData
              spacing: 4

              BatteryIcon {
                anchors.verticalCenter: parent.verticalCenter
                visible: deviceGroup.useIcons
                kind: root.deviceIcon(deviceGroup.modelData, batteryGroup.modelData)
                tint: button.foreground
                width: button.fontSize * 1.5
                height: width
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: (deviceGroup.useIcons ? "" : deviceGroup.modelData.single
                  ? root.deviceLabel(deviceGroup.modelData) + " "
                  : root.sidePrefix(batteryGroup.modelData))
                  + root.battery(deviceGroup.modelData, batteryGroup.modelData)
                textFormat: Text.PlainText
                color: button.foreground
                font.family: button.fontFamily
                font.pixelSize: button.fontSize
                renderType: Text.NativeRendering
              }
            }
          }
        }
      }
    }
  }

  ConfigPanel {
    id: configPanel
    bar: root.bar
    anchorItem: button
    owner: root
    widget: root
  }

  DetailsPanel {
    id: detailsPanel
    bar: root.bar
    anchorItem: button
    owner: root
    widget: root
    onConfigureRequested: root.openSettings()
  }
}

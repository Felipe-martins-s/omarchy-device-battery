pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.Ui as Ui
import qs.Commons

Ui.KeyboardPanel {
  id: panel
  required property var widget
  signal configureRequested()
  contentWidth: fittedContentWidth(Style.space(390))
  contentHeight: fittedContentHeight(Math.min(Style.space(560), content.implicitHeight + verticalContentInset))
  focusTarget: scroll

  Flickable {
    id: scroll
    anchors.fill: parent
    contentWidth: width
    contentHeight: content.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    Keys.onEscapePressed: panel.close()
    Controls.ScrollBar.vertical: Controls.ScrollBar {}

    ColumnLayout {
      id: content
      width: scroll.width
      spacing: Style.space(14)
      RowLayout {
        Layout.fillWidth: true
        NativeLabel {
          text: panel.widget.t("batteries")
          color: Color.accent
          font.letterSpacing: Style.space(2)
          Layout.fillWidth: true
        }
        NativeLabel { text: panel.widget.t("live"); color: Color.accent; small: true }
        Ui.PanelActionButton {
          iconText: "󰒓"
          tooltipText: panel.widget.t("deviceSettings")
          focusable: true
          onClicked: panel.configureRequested()
        }
      }
      Ui.PanelSeparator { Layout.fillWidth: true }
      Repeater {
        model: panel.widget.devices
        delegate: ColumnLayout {
          id: device
          required property var modelData
          Layout.fillWidth: true
          spacing: Style.space(8)
          NativeLabel {
            text: panel.widget.deviceLabel(device.modelData)
            color: Color.accent
            font.bold: true
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
          }
          NativeLabel {
            text: device.modelData.source === "bluetooth" ? "BLUETOOTH" : panel.widget.t("detailedSource")
            small: true
            muted: true
            Layout.fillWidth: true
          }
          Repeater {
            model: device.modelData.single ? [1] : [1, 2, 3]
            delegate: ColumnLayout {
              id: reading
              required property int modelData
              readonly property var batteryState: device.modelData.state || ({})
              readonly property string status: batteryState["battery" + modelData + "Status"] || "unknown"
              readonly property var level: batteryState["battery" + modelData + "Level"]
              readonly property bool available: status !== "disconnected" && typeof level === "number" && level >= 0 && level <= 100
              Layout.fillWidth: true
              spacing: Style.space(5)
              RowLayout {
                Layout.fillWidth: true
                spacing: Style.space(8)
                BatteryIcon {
                  Layout.preferredWidth: Style.space(20)
                  Layout.preferredHeight: Style.space(20)
                  kind: panel.widget.deviceIcon(device.modelData, reading.modelData)
                  tint: Color.foreground
                }
                NativeLabel {
                  text: panel.widget.t(device.modelData.single ? "battery" : ["", "left", "right", "case"][reading.modelData])
                  Layout.fillWidth: true
                }
                NativeLabel {
                  text: reading.status === "charging" ? panel.widget.t("charging") : !reading.available ? panel.widget.t("unavailable") : ""
                  small: true
                  muted: true
                }
                NativeLabel {
                  text: panel.widget.battery(device.modelData, reading.modelData)
                  color: reading.available && reading.level <= 20 ? Color.urgent : Color.foreground
                }
              }
              Rectangle {
                Layout.fillWidth: true
                implicitHeight: Style.space(3)
                color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.15)
                Rectangle {
                  width: parent.width * (reading.available ? reading.level / 100 : 0)
                  height: parent.height
                  color: reading.level <= 20 ? Color.urgent : Color.accent
                }
              }
            }
          }
          Ui.PanelSeparator { Layout.fillWidth: true }
        }
      }
      NativeLabel {
        visible: panel.widget.devices.length === 0
        text: panel.widget.t("noDevices")
        muted: true
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
      }
      NativeLabel {
        text: panel.widget.t("dismiss")
        small: true
        muted: true
      }
    }
  }
}

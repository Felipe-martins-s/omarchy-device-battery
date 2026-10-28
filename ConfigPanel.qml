pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.Ui as Ui
import qs.Commons
import "Appearance.js" as Appearance

Ui.KeyboardPanel {
  id: panel
  required property var widget
  readonly property color foreground: Color.foreground
  readonly property var typography: Style.font
  readonly property string fontFamily: typography.family
  contentWidth: fittedContentWidth(Style.space(450))
  contentHeight: fittedContentHeight(Math.min(Style.space(600), form.implicitHeight + verticalContentInset))
  focusTarget: scroll

  Flickable {
    id: scroll
    anchors.fill: parent
    contentWidth: width
    contentHeight: form.implicitHeight
    boundsBehavior: Flickable.StopAtBounds
    clip: true
    Keys.onEscapePressed: panel.close()
    Controls.ScrollBar.vertical: Controls.ScrollBar {}

    ColumnLayout {
      id: form
      width: scroll.width
      spacing: Style.space(14)

      RowLayout {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        NativeLabel {
          text: panel.widget.t("settingsTitle")
          color: Color.accent
          font.letterSpacing: Style.space(1.5)
          Layout.fillWidth: true
          Layout.minimumWidth: 0
          elide: Text.ElideRight
        }
        Ui.PanelActionButton {
          iconText: "󰅖"
          tooltipText: panel.widget.t("close")
          focusable: true
          onClicked: panel.close()
        }
      }
      Ui.PanelSeparator { Layout.fillWidth: true; foreground: panel.foreground }
      Ui.Dropdown {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        label: panel.widget.t("language")
        value: panel.widget.language
        options: [{value: "pt-BR", label: "Português (Brasil)"}, {value: "en", label: "English"}]
        foreground: panel.foreground
        fontFamily: panel.fontFamily
        onChanged: function(value) { panel.widget.saveSetting("language", value) }
      }
      NativeLabel {
        text: panel.widget.t("introduction")
        muted: true
        small: true
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }

      Repeater {
        model: panel.widget.configurableDevices
        delegate: Ui.BorderSurface {
          id: card
          required property var modelData
          readonly property var preference: panel.widget.preference(modelData)
          Layout.fillWidth: true
          Layout.minimumWidth: 0
          Layout.maximumWidth: form.width
          implicitHeight: fields.implicitHeight + Style.space(24)
          color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.025)
          borderSpec: Border.flat(Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.22), 1)
          radius: Style.cornerRadius

          ColumnLayout {
            id: fields
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Style.space(12)
            spacing: Style.space(10)

            NativeLabel {
              text: card.modelData.alias
              color: Color.accent
              font.bold: true
              Layout.fillWidth: true
              wrapMode: Text.WordWrap
            }
            NativeLabel {
              text: panel.widget.t(card.modelData.offline ? "disconnected" : "connected")
              muted: true
              small: true
              Layout.fillWidth: true
            }
            Ui.PanelSectionHeader { text: panel.widget.t("display"); foreground: panel.foreground }
            Ui.ButtonGroup {
              options: [{value: "", label: panel.widget.t("inherit")}, {value: "Texto", label: panel.widget.t("text")}, {value: "Ícones", label: panel.widget.t("icons")}]
              value: card.preference.mode || ""
              foreground: panel.foreground
              fontFamily: panel.fontFamily
              onChanged: function(value) { panel.widget.saveDevice(card.modelData, "mode", value) }
            }
            Ui.Dropdown {
              Layout.fillWidth: true
              Layout.minimumWidth: 0
              label: panel.widget.t("iconGroup")
              value: card.preference.icon || "auto"
              options: Appearance.presets.map(function(preset) { return {value: preset.id, label: panel.widget.t(preset.id)} })
              foreground: panel.foreground
              fontFamily: panel.fontFamily
              onChanged: function(value) { panel.widget.saveDevice(card.modelData, "icon", value) }
            }
            Ui.PanelSectionHeader { text: panel.widget.t("customText"); foreground: panel.foreground }
            Ui.TextField {
              id: customLabelInput
              Layout.fillWidth: true
              Layout.minimumWidth: 0
              placeholderText: card.modelData.alias
              text: card.preference.label || ""
              foreground: panel.foreground
              onEditingFinished: {
                if (customLabelInput.text.trim() !== (card.preference.label || ""))
                  panel.widget.saveDevice(card.modelData, "label", customLabelInput.text.trim())
              }
            }
            Ui.PanelSeparator { Layout.fillWidth: true; foreground: panel.foreground }
            RowLayout {
              Layout.fillWidth: true
              Layout.minimumWidth: 0
              spacing: Style.space(12)
              Ui.PanelSectionHeader { text: panel.widget.t("preview"); foreground: panel.foreground }
              Item { Layout.fillWidth: true }
              Repeater {
                model: card.modelData.single ? [1] : [1, 2, 3]
                delegate: Row {
                  id: preview
                  required property int modelData
                  spacing: Style.space(4)
                  BatteryIcon {
                    visible: panel.widget.deviceUsesIcons(card.modelData)
                    width: Style.space(20)
                    height: width
                    kind: panel.widget.deviceIcon(card.modelData, preview.modelData)
                    tint: Color.accent
                  }
                  NativeLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    text: (panel.widget.deviceUsesIcons(card.modelData) ? "" : card.modelData.single
                      ? panel.widget.deviceLabel(card.modelData) + " "
                      : panel.widget.sidePrefix(preview.modelData)) + "85%"
                    small: true
                  }
                }
              }
            }
          }
        }
      }
      NativeLabel {
        visible: panel.widget.configurableDevices.length === 0
        text: panel.widget.t("connectToConfigure")
        muted: true
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }
      NativeLabel {
        text: panel.widget.t("defaultHint")
        muted: true
        small: true
        Layout.fillWidth: true
      }
    }
  }
}

import QtQuick
import qs.Commons

Text {
  property bool muted: false
  property bool small: false
  readonly property var typography: Style.font
  textFormat: Text.PlainText
  color: muted ? Qt.darker(Color.foreground, 1.45) : Color.foreground
  font.family: typography.family
  font.pixelSize: small ? typography.caption : typography.body
  renderType: Text.NativeRendering
}

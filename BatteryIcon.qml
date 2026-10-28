import QtQuick

// Original monochrome artwork: mirrored earbuds and their charging case.
Image {
  property int kind: 1
  property color tint: "white"
  readonly property string earbud: '<path d="M9 3c-3.3 0-6 2.3-6 5.3 0 2.6 1.9 4.7 4.5 5.2V20a2 2 0 0 0 4 0v-7.5c2.1-.9 3.5-2.8 3.5-5.2C15 5 12.3 3 9 3Z"/><path d="M5.7 8.2h2.1" stroke="white" stroke-width="1.5" stroke-linecap="round"/>'
  readonly property string caseShape: '<rect x="2" y="5" width="20" height="15" rx="5" fill="none" stroke="currentColor" stroke-width="2"/><path d="M3 11h18" fill="none" stroke="currentColor" stroke-width="1.5"/><circle cx="12" cy="15.5" r="1"/>'
  readonly property string batteryShape: '<rect x="2" y="6" width="18" height="12" rx="2" fill="none" stroke="currentColor" stroke-width="2"/><path d="M22 10v4" stroke="currentColor" stroke-width="2"/><rect x="5" y="9" width="9" height="6" rx="1"/>'
  readonly property string headphoneShape: '<path d="M4 14v-3a8 8 0 0 1 16 0v3" fill="none" stroke="currentColor" stroke-width="2"/><rect x="2" y="12" width="5" height="9" rx="2"/><rect x="17" y="12" width="5" height="9" rx="2"/>'
  readonly property string headsetShape: headphoneShape + '<path d="M19 19v2h-6" fill="none" stroke="currentColor" stroke-width="2"/><rect x="10" y="20" width="5" height="3" rx="1"/>'
  readonly property string squareShape: '<path d="M4 15V6a3 3 0 0 1 3-3h10a3 3 0 0 1 3 3v9" fill="none" stroke="currentColor" stroke-width="2"/><rect x="1" y="12" width="6" height="9" rx="1"/><rect x="17" y="12" width="6" height="9" rx="1"/>'
  readonly property string speakerShape: '<rect x="5" y="2" width="14" height="20" rx="2" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="7" r="2"/><circle cx="12" cy="15" r="4" fill="none" stroke="currentColor" stroke-width="2"/>'
  readonly property string mouseShape: '<rect x="5" y="2" width="14" height="20" rx="7" fill="none" stroke="currentColor" stroke-width="2"/><path d="M12 3v7M5 11h14" stroke="currentColor" stroke-width="2"/>'
  readonly property string roundBudsShape: '<ellipse cx="12" cy="11" rx="8" ry="9" fill="none" stroke="currentColor" stroke-width="2"/><ellipse cx="12" cy="9" rx="3" ry="4"/>'
  readonly property string keyboardShape: '<rect x="1" y="5" width="22" height="14" rx="2" fill="none" stroke="currentColor" stroke-width="2"/><path d="M5 9h1m3 0h1m3 0h1m3 0h1M5 12h1m3 0h1m3 0h1m3 0h1M6 16h12" stroke="currentColor" stroke-width="2"/>'
  readonly property string shape: kind === 3 ? caseShape : kind === 4 ? batteryShape
    : kind === 5 ? headphoneShape : kind === 6 ? headsetShape : kind === 7 ? squareShape
    : kind === 8 ? speakerShape : kind === 9 ? mouseShape : kind === 10 ? roundBudsShape
    : kind === 11 ? keyboardShape
    : '<g' + (kind === 2 ? ' transform="translate(24 0) scale(-1 1)"' : '') + '>' + earbud + '</g>'
  source: "data:image/svg+xml," + encodeURIComponent(
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" color="'
    + tint + '" fill="currentColor">'
    + shape
    + '</svg>')
  sourceSize.width: Math.ceil(width * 2)
  sourceSize.height: Math.ceil(height * 2)
  fillMode: Image.PreserveAspectFit
  smooth: true
}

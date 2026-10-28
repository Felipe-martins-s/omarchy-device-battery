.pragma library

var presets = [
  {id: "auto", label: "Automático"},
  {id: "headphones", label: "Headphone — arco redondo"},
  {id: "headset", label: "Headset — com microfone"},
  {id: "square", label: "Headphone — arco quadrado"},
  {id: "buds", label: "Grupo: fones com haste + estojo"},
  {id: "buds-round", label: "Grupo: fones redondos + estojo"},
  {id: "speaker", label: "Caixa de som"},
  {id: "mouse", label: "Mouse"},
  {id: "keyboard", label: "Teclado"},
  {id: "battery", label: "Bateria"}
]

function key(device) { return device.path.replace(/^.*\/dev_/, "") }
function iconKind(preset, single, index) {
  if (preset === "auto") preset = single ? "headphones" : "buds"
  if (preset === "buds") return single ? 1 : index
  if (preset === "buds-round") return !single && index === 3 ? 3 : 10
  if (!single && index === 3) return 3
  return ({headphones: 5, headset: 6, square: 7, speaker: 8,
    mouse: 9, keyboard: 11, battery: 4})[preset] || 5
}

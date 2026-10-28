.pragma library

var catalogs = {
  "pt-BR": {
    settingsTitle: "BATERIAS / APARÊNCIA", close: "Fechar", language: "IDIOMA / LANGUAGE",
    introduction: "Personalize cada dispositivo. As alterações são salvas automaticamente e mantidas ao reconectar.",
    disconnected: "○ DESCONECTADO · preferências salvas", connected: "● CONECTADO",
    display: "EXIBIÇÃO", inherit: "Padrão", text: "Texto", icons: "Ícones",
    iconGroup: "ÍCONE / GRUPO DE ÍCONES", customText: "TEXTO PERSONALIZADO", preview: "PRÉVIA",
    connectToConfigure: "Conecte um dispositivo com leitura de bateria para configurá-lo.",
    defaultHint: "Padrão: usa a preferência global do widget.",
    batteries: "BATERIAS", live: "● AO VIVO", deviceSettings: "Configurações por dispositivo",
    detailedSource: "BUDSLINK / LEITURA DETALHADA", battery: "Bateria", left: "Esquerdo",
    right: "Direito", case: "Estojo", leftShort: "E", rightShort: "D", caseShort: "C",
    charging: "CARREGANDO", unavailable: "INDISPONÍVEL",
    noDevices: "Nenhum dispositivo conectado com leitura de bateria.",
    dismiss: "Clique fora ou pressione Esc para fechar.", source: "Fonte",
    clickHints: "Clique esquerdo: fixar informações.\nClique direito: configurações por dispositivo.",
    unavailableHint: "— = leitura indisponível (não é 0%).",
    auto: "Automático", headphones: "Headphone — arco redondo", headset: "Headset — com microfone",
    square: "Headphone — arco quadrado", buds: "Grupo: fones com haste + estojo",
    "buds-round": "Grupo: fones redondos + estojo", speaker: "Caixa de som", mouse: "Mouse", keyboard: "Teclado"
  },
  "en": {
    settingsTitle: "BATTERIES / APPEARANCE", close: "Close", language: "LANGUAGE / IDIOMA",
    introduction: "Customize each device. Changes are saved automatically and kept when reconnecting.",
    disconnected: "○ DISCONNECTED · settings saved", connected: "● CONNECTED",
    display: "DISPLAY", inherit: "Default", text: "Text", icons: "Icons",
    iconGroup: "ICON / ICON GROUP", customText: "CUSTOM TEXT", preview: "PREVIEW",
    connectToConfigure: "Connect a device that reports a battery level to configure it.",
    defaultHint: "Default: inherit the widget-wide display preference.",
    batteries: "BATTERIES", live: "● LIVE", deviceSettings: "Per-device settings",
    detailedSource: "BUDSLINK / DETAILED READINGS", battery: "Battery", left: "Left",
    right: "Right", case: "Case", leftShort: "L", rightShort: "R", caseShort: "C",
    charging: "CHARGING", unavailable: "UNAVAILABLE",
    noDevices: "No connected devices with battery readings.",
    dismiss: "Click outside or press Esc to close.", source: "Source",
    clickHints: "Left click: pin battery information.\nRight click: per-device settings.",
    unavailableHint: "— = reading unavailable (not 0%).",
    auto: "Automatic", headphones: "Headphones — round headband", headset: "Headset — with microphone",
    square: "Headphones — square headband", buds: "Group: stem earbuds + case",
    "buds-round": "Group: round earbuds + case", speaker: "Speaker", mouse: "Mouse", keyboard: "Keyboard"
  }
}

function translate(language, key) {
  var catalog = catalogs[language] || catalogs["pt-BR"]
  return catalog[key] !== undefined ? catalog[key] : catalogs["pt-BR"][key] || key
}

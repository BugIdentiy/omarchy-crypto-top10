import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.bugidentiy.crypto-top10"

  property var coins: []
  property int selectedIndex: 0
  property string statusText: "Crypto …"

  readonly property var selectedCoin: coins.length > 0
    ? coins[Math.max(0, Math.min(selectedIndex, coins.length - 1))]
    : null

  function formatPrice(value) {
    var decimals = value >= 1000 ? 0 : value >= 1 ? 2 : value >= 0.01 ? 4 : 6
    var parts = Number(value).toFixed(decimals).split(".")
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, " ")
    return parts.join(",") + " €"
  }

  function refresh() {
    if (priceRequest.running) return
    priceRequest.running = true
  }

  function nextCoin() {
    if (coins.length < 2) return
    selectedIndex = (selectedIndex + 1) % coins.length
  }

  function resetSelection() {
    selectedIndex = 0
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onCompleted: refresh()

  Timer {
    interval: 3600000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: priceRequest
    command: [Quickshell.env("HOME") + "/.config/omarchy/plugins/io.github.bugidentiy.crypto-top10/fetch-top10.sh"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var freshCoins = JSON.parse(String(text || "").trim())
          if (!Array.isArray(freshCoins) || freshCoins.length === 0)
            throw new Error("No market prices returned")

          var previousId = root.selectedCoin ? String(root.selectedCoin.id) : ""
          root.coins = freshCoins
          var retainedIndex = -1
          for (var i = 0; i < freshCoins.length; i++) {
            if (String(freshCoins[i].id) === previousId) {
              retainedIndex = i
              break
            }
          }
          root.selectedIndex = retainedIndex >= 0 ? retainedIndex : 0
          root.statusText = ""
        } catch (error) {
          if (root.coins.length === 0) root.statusText = "Crypto indisponible"
        }
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0 && root.coins.length === 0)
        root.statusText = "Crypto indisponible"
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.selectedCoin
      ? String(root.selectedCoin.symbol).toUpperCase() + " " + root.formatPrice(Number(root.selectedCoin.price))
      : root.statusText
    tooltipText: root.selectedCoin
      ? root.selectedCoin.name + " · rang #" + root.selectedCoin.rank
        + "\nClic gauche : crypto suivante · clic droit : actualiser"
        + "\nClic milieu : revenir au rang #1 · mise à jour horaire"
      : "Chargement du top 10 crypto en EUR"
    horizontalMargin: 8.75

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) root.refresh()
      else if (mouseButton === Qt.MiddleButton) root.resetSelection()
      else root.nextCoin()
    }
  }
}

#!/usr/bin/env bash
# Installiert oder aktualisiert Neo11Menu für den aktuellen Benutzer.
set -e
cd "$(dirname "$(readlink -f "$0")")"

ID="de.rembrandtz4.neo11menu"

if ! command -v kpackagetool6 >/dev/null 2>&1; then
  echo "kpackagetool6 wurde nicht gefunden. Neo11Menu braucht KDE Plasma 6."
  exit 1
fi
if [ "$(id -u)" -eq 0 ]; then
  echo "Bitte nicht als root bzw. mit sudo starten – das Menü wird für deinen Benutzer installiert."
  exit 1
fi

# Eigenes Symbol (für Info-Seite, Widget-Auswahl und Einstellungen)
install -Dm644 contents/icons/neo11menu.svg "$HOME/.local/share/icons/hicolor/scalable/apps/neo11menu.svg"
command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 >/dev/null 2>&1 || true

if [ -d "$HOME/.local/share/plasma/plasmoids/$ID" ]; then
  echo "Neo11Menu wird aktualisiert …"
  kpackagetool6 -t Plasma/Applet -u .
  echo "Plasma wird neu gestartet, damit die neue Version geladen wird …"
  systemctl --user restart plasma-plasmashell.service 2>/dev/null || {
    kquitapp6 plasmashell 2>/dev/null || true
    (plasmashell >/dev/null 2>&1 &)
  }
  echo "Fertig!"
else
  echo "Neo11Menu wird installiert …"
  kpackagetool6 -t Plasma/Applet -i .
  echo
  echo "Fertig! So setzt du es in die Leiste:"
  echo "  Rechtsklick auf den bisherigen Startknopf ▸ „Alternativen anzeigen …“ ▸ „Neo11Menu“"
fi

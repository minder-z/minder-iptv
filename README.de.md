<p align="center"><img src="docs/icon.png" width="140" alt="Minder IPTV"></p>

<h1 align="center">Minder IPTV</h1>

<p align="center">Eine native macOS-App für Live-TV und Radio – chinesische Sender, internationales TV und Radio aus aller Welt.</p>

<p align="center">[简体中文](README.md) · [繁體中文](README.zh-Hant.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · **Deutsch** · [Español](README.es.md) · [Русский](README.ru.md)</p>

<p align="center"><img src="docs/screenshot.png" width="760" alt="screenshot"></p>

## Funktionen

- **Chinesisches TV** von [Guovin/iptv-api](https://github.com/Guovin/iptv-api) (CCTV, Provinz-Satellitensender, Hongkong/Macau/Taiwan, Sport, Filme …)
- **Internationales TV** von [iptv-org/iptv](https://github.com/iptv-org/iptv), nach Ländern gruppiert, 17 Länder und Regionen wählbar
- **Weltweites Radio** von [Radio Browser](https://www.radio-browser.info), die 80 beliebtesten Sender je Land
- **Automatisch aktualisierte Senderliste** jede Stunde oder jederzeit mit ⌘R
- **Automatischer Quellenwechsel**, wenn ein Stream nicht läuft
- **Automatische App-Updates**: prüft GitHub Releases beim Start und täglich, Installation mit einem Klick; auch über „Nach Updates suchen …“
- **9 Sprachen**: 简体中文, 繁體中文, English, 日本語, 한국어, Français, Deutsch, Español, Русский
- Gruppen, Suche, Favoriten, Vollbild, Bild-in-Bild; offline mit der zuletzt geladenen Liste

## Installation

1. `MinderIPTV-x.y.z.zip` unter [Releases](https://github.com/minder-z/minder-iptv/releases/latest) laden, entpacken und die App in „Programme“ ziehen.
2. Meldet macOS beim ersten Start, dass der Entwickler nicht überprüft werden kann: Rechtsklick auf die App → Öffnen.
3. Erfordert macOS 14 oder neuer.

## Aus dem Quellcode bauen

Erfordert die Xcode Command Line Tools (`xcode-select --install`):

```bash
git clone https://github.com/minder-z/minder-iptv.git
cd minder-iptv
./build_app.sh
```

## Hinweis

Diese App stellt keine Streams bereit und speichert keine; sie liest nur die Playlists der oben genannten öffentlichen Projekte. Die Streams werden von Dritten gesammelt und gehören ihren Eigentümern. Bitte im Rahmen der örtlichen Gesetze nutzen.

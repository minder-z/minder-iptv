<p align="center"><img src="docs/icon.png" width="140" alt="Minder IPTV"></p>

<h1 align="center">Minder IPTV</h1>

<p align="center">A native macOS app for live TV and radio — Chinese channels, international TV and world radio, ready to watch.</p>

<p align="center">[简体中文](README.md) · [繁體中文](README.zh-Hant.md) · **English** · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Русский](README.ru.md)</p>

<p align="center"><img src="docs/screenshot.png" width="760" alt="screenshot"></p>

## Features

- **Chinese TV** from [Guovin/iptv-api](https://github.com/Guovin/iptv-api) (CCTV, provincial satellite channels, HK/Macau/Taiwan, sports, movies…)
- **International TV** from [iptv-org/iptv](https://github.com/iptv-org/iptv), grouped by country, 17 countries and regions to choose from
- **World radio** from [Radio Browser](https://www.radio-browser.info), the 80 most popular stations per country
- **Auto-refreshing channel list** every hour, or refresh any time with ⌘R
- **Automatic source failover**: if a stream fails, the next source is tried
- **App auto-update**: checks GitHub Releases at launch and daily, installs new versions in one click; also “Check for Updates…” in the menu
- **9 UI languages**: 简体中文, 繁體中文, English, 日本語, 한국어, Français, Deutsch, Español, Русский
- Groups, search, favorites, full screen, picture-in-picture; works offline with the last list

## Install

1. Download `MinderIPTV-x.y.z.zip` from [Releases](https://github.com/minder-z/minder-iptv/releases/latest), unzip, and drag the app into Applications.
2. If macOS says it can’t verify the developer on first launch: right-click the app → Open.
3. Requires macOS 14 or later.

## Build from source

Requires the Xcode Command Line Tools (`xcode-select --install`):

```bash
git clone https://github.com/minder-z/minder-iptv.git
cd minder-iptv
./build_app.sh
```

## Disclaimer

This app does not host or store any streams; it only reads playlists published by the public projects above. Streams are collected by third parties and belong to their owners. Use it in accordance with your local laws.

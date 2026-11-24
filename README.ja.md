<p align="center"><img src="docs/icon.png" width="140" alt="Minder IPTV"></p>

<h1 align="center">Minder IPTV</h1>

<p align="center">macOS ネイティブのテレビ・ラジオアプリ。中国のテレビ、海外テレビ、世界のラジオをすぐに視聴できます。</p>

<p align="center">[简体中文](README.md) · [繁體中文](README.zh-Hant.md) · [English](README.en.md) · **日本語** · [한국어](README.ko.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Русский](README.ru.md)</p>

<p align="center"><img src="docs/screenshot.png" width="760" alt="screenshot"></p>

## 機能

- **中国のテレビ**：[Guovin/iptv-api](https://github.com/Guovin/iptv-api) より（CCTV、各省の衛星チャンネル、香港・マカオ・台湾、スポーツ、映画など）
- **海外テレビ**：[iptv-org/iptv](https://github.com/iptv-org/iptv) より、国別に分類、17 の国と地域から選択
- **世界のラジオ**：[Radio Browser](https://www.radio-browser.info) より、各国の人気 80 局
- **チャンネルリストの自動更新**：1 時間ごと、⌘R でいつでも手動更新
- **ソースの自動切り替え**：再生できない場合は次のソースを試します
- **アプリの自動アップデート**：起動時と毎日 GitHub Releases を確認し、ワンクリックでインストール。メニューの「アップデートを確認…」からも可能
- **9 つの表示言語**：简体中文、繁體中文、English、日本語、한국어、Français、Deutsch、Español、Русский
- グループ表示、検索、お気に入り、フルスクリーン、ピクチャ・イン・ピクチャ。オフラインでも前回のリストを表示

## インストール

1. [Releases](https://github.com/minder-z/minder-iptv/releases/latest) から `MinderIPTV-x.y.z.zip` をダウンロードし、解凍してアプリを「アプリケーション」へドラッグします。
2. 初回起動時に「開発元を検証できません」と表示された場合：アプリを右クリック →「開く」。
3. macOS 14 以降が必要です。

## ソースからビルド

Xcode コマンドラインツールが必要です（`xcode-select --install`）：

```bash
git clone https://github.com/minder-z/minder-iptv.git
cd minder-iptv
./build_app.sh
```

## 免責事項

本アプリは配信コンテンツを提供・保存せず、上記の公開プロジェクトが公開するプレイリストを読み込むだけです。ストリームは第三者が収集したもので、権利は各所有者に帰属します。お住まいの地域の法律に従ってご利用ください。

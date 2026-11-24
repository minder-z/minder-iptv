<p align="center"><img src="docs/icon.png" width="140" alt="小满 IPTV"></p>

<h1 align="center">小满 IPTV</h1>

<p align="center">原生 macOS 看电视、听电台：国内电视 + 海外电视 + 海外电台，打开就能看。</p>

<p align="center">**简体中文** · [繁體中文](README.zh-Hant.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Русский](README.ru.md)</p>

<p align="center"><img src="docs/screenshot.png" width="760" alt="screenshot"></p>

## 功能

- **国内电视**：来自 [Guovin/iptv-api](https://github.com/Guovin/iptv-api)（央视、卫视、各省、港澳台、体育、电影等）
- **海外电视**：来自 [iptv-org/iptv](https://github.com/iptv-org/iptv)，按国家分组，可选 17 个国家和地区
- **海外电台**：来自 [Radio Browser](https://www.radio-browser.info)，每个国家最热门的 80 个
- **频道列表自动更新**：每小时一次，也可以 ⌘R 手动更新
- **多线路自动切换**：一条线路放不了会自动换下一条
- **软件自动更新**：启动时和每天检查 GitHub Releases，有新版本一键安装；菜单里也能「检查更新…」
- **9 种界面语言**：简体中文、繁體中文、English、日本語、한국어、Français、Deutsch、Español、Русский
- 分组浏览、搜索、收藏、全屏、画中画；离线也能看到上次的列表

## 安装

1. 到 [Releases](https://github.com/minder-z/minder-iptv/releases/latest) 下载 `MinderIPTV-x.y.z.zip`，解压后把「小满 IPTV」拖进「应用程序」。
2. 第一次打开如果提示「无法验证开发者」：右键点应用 → 打开。
3. 需要 macOS 14 或更高版本。

## 从源码编译

需要 Xcode 命令行工具（`xcode-select --install`）：

```bash
git clone https://github.com/minder-z/minder-iptv.git
cd minder-iptv
./build_app.sh
```

## 声明

本应用不提供、不存储任何直播内容，只读取上面这些公开项目发布的播放列表。直播源由第三方收集，版权归各自所有者，请在当地法律允许的范围内使用。

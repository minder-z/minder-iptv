<p align="center"><img src="docs/icon.png" width="160" alt="小满 IPTV 图标"></p>

<h1 align="center">小满 IPTV · Minder IPTV</h1>

<p align="center">一个原生 macOS 看电视、听电台的小应用：国内电视 + 海外电视 + 海外电台，打开就能看。</p>

## 功能

- **国内电视**：频道列表来自 [Guovin/iptv-api](https://github.com/Guovin/iptv-api) 发布的结果（央视、卫视、各省、港澳台、体育、电影等）
- **海外电视**：来自 [iptv-org/iptv](https://github.com/iptv-org/iptv)，按国家分组
- **海外电台**：来自 [Radio Browser](https://www.radio-browser.info)，每个国家取最热门 80 个
- **自动更新**：每 1 小时自动拉取一次（休眠唤醒后也会补更新）；失败保留旧列表，5 分钟后重试
- **手动更新**：工具栏刷新按钮或 ⌘R
- **多线路**：同一频道多条线路自动合并，出错或 12 秒没起播会自动换下一条，也可手动选
- 分组浏览、搜索、收藏、全屏、画中画；离线打开也能看到上次的列表

设置里可以：
- 改国内源地址（例如自己用 Docker 部署 iptv-api，填 `http://localhost:8000/m3u`）
- 分别开关海外电视 / 海外电台，并勾选 17 个国家和地区

## 编译

需要 macOS 14+ 和 Xcode 命令行工具（`xcode-select --install`）。

```bash
./build_app.sh
```

会生成 `小满 IPTV.app`，拖进「应用程序」即可。第一次打开如果提示无法验证开发者，右键 → 打开。

## 目录

```
Sources/MinderIPTV/
  App.swift            应用入口、菜单快捷键
  Views.swift          界面（侧边栏、频道列表、播放器、设置）
  Player.swift         播放控制与自动换线路
  Playlist.swift       M3U / TXT 解析
  PlaylistStore.swift  拉取、合并、缓存、定时更新
  Overseas.swift       海外电视与电台
tools/make_icon.swift  生成应用图标
```

## 声明

本应用不提供、不存储任何直播内容，只读取上面这些公开项目发布的播放列表。直播源由第三方收集，可用性和版权归各自所有者，请在当地法律允许的范围内使用。

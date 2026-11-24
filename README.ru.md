<p align="center"><img src="docs/icon.png" width="140" alt="Minder IPTV"></p>

<h1 align="center">Minder IPTV</h1>

<p align="center">Нативное приложение macOS для ТВ и радио: китайские каналы, зарубежное ТВ и радио со всего мира.</p>

<p align="center">[简体中文](README.md) · [繁體中文](README.zh-Hant.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · **Русский**</p>

<p align="center"><img src="docs/screenshot.png" width="760" alt="screenshot"></p>

## Возможности

- **Китайское ТВ** из [Guovin/iptv-api](https://github.com/Guovin/iptv-api) (CCTV, спутниковые каналы провинций, Гонконг/Макао/Тайвань, спорт, кино…)
- **Зарубежное ТВ** из [iptv-org/iptv](https://github.com/iptv-org/iptv), по странам, на выбор 17 стран и регионов
- **Радио со всего мира** из [Radio Browser](https://www.radio-browser.info), 80 самых популярных станций каждой страны
- **Автообновление списка каналов** каждый час или в любой момент по ⌘R
- **Автоматическая смена источника**, если поток не работает
- **Автообновление приложения**: проверяет GitHub Releases при запуске и раз в день, установка в один клик; также через «Проверить обновления…»
- **9 языков**: 简体中文, 繁體中文, English, 日本語, 한국어, Français, Deutsch, Español, Русский
- Группы, поиск, избранное, полный экран, картинка в картинке; работает офлайн с последним списком

## Установка

1. Скачайте `MinderIPTV-x.y.z.zip` на странице [Releases](https://github.com/minder-z/minder-iptv/releases/latest), распакуйте и перетащите приложение в «Программы».
2. Если при первом запуске macOS не может проверить разработчика: щёлкните приложение правой кнопкой → Открыть.
3. Нужна macOS 14 или новее.

## Сборка из исходников

Нужны инструменты командной строки Xcode (`xcode-select --install`):

```bash
git clone https://github.com/minder-z/minder-iptv.git
cd minder-iptv
./build_app.sh
```

## Отказ от ответственности

Приложение не размещает и не хранит трансляции, а лишь читает плейлисты указанных открытых проектов. Потоки собраны третьими лицами и принадлежат их владельцам. Используйте в соответствии с законами вашей страны.

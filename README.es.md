<p align="center"><img src="docs/icon.png" width="140" alt="Minder IPTV"></p>

<h1 align="center">Minder IPTV</h1>

<p align="center">Una app nativa de macOS para TV y radio en directo: canales chinos, TV internacional y radios de todo el mundo.</p>

<p align="center">[简体中文](README.md) · [繁體中文](README.zh-Hant.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · **Español** · [Русский](README.ru.md)</p>

<p align="center"><img src="docs/screenshot.png" width="760" alt="screenshot"></p>

## Funciones

- **TV china** desde [Guovin/iptv-api](https://github.com/Guovin/iptv-api) (CCTV, canales satelitales provinciales, Hong Kong/Macao/Taiwán, deportes, cine…)
- **TV internacional** desde [iptv-org/iptv](https://github.com/iptv-org/iptv), agrupada por país, 17 países y regiones a elegir
- **Radio mundial** desde [Radio Browser](https://www.radio-browser.info), las 80 emisoras más populares de cada país
- **Lista de canales actualizada** cada hora, o cuando quieras con ⌘R
- **Cambio automático de fuente** si una emisión falla
- **Actualización automática de la app**: revisa GitHub Releases al abrirse y cada día, instala con un clic; también desde «Buscar actualizaciones…»
- **9 idiomas**: 简体中文, 繁體中文, English, 日本語, 한국어, Français, Deutsch, Español, Русский
- Grupos, búsqueda, favoritos, pantalla completa, imagen en imagen; funciona sin conexión con la última lista

## Instalación

1. Descarga `MinderIPTV-x.y.z.zip` desde [Releases](https://github.com/minder-z/minder-iptv/releases/latest), descomprímelo y arrastra la app a Aplicaciones.
2. Si macOS dice que no puede verificar al desarrollador: clic derecho en la app → Abrir.
3. Requiere macOS 14 o posterior.

## Compilar desde el código

Requiere las herramientas de línea de comandos de Xcode (`xcode-select --install`):

```bash
git clone https://github.com/minder-z/minder-iptv.git
cd minder-iptv
./build_app.sh
```

## Aviso

Esta app no aloja ni almacena emisiones; solo lee las listas publicadas por los proyectos públicos indicados. Las emisiones las recopilan terceros y pertenecen a sus propietarios. Úsala conforme a las leyes de tu país.

<p align="center"><img src="docs/icon.png" width="140" alt="Minder IPTV"></p>

<h1 align="center">Minder IPTV</h1>

<p align="center">Une app macOS native pour la TV et la radio en direct : chaînes chinoises, TV internationale et radios du monde entier.</p>

<p align="center">[简体中文](README.md) · [繁體中文](README.zh-Hant.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · **Français** · [Deutsch](README.de.md) · [Español](README.es.md) · [Русский](README.ru.md)</p>

<p align="center"><img src="docs/screenshot.png" width="760" alt="screenshot"></p>

## Fonctionnalités

- **TV chinoise** depuis [Guovin/iptv-api](https://github.com/Guovin/iptv-api) (CCTV, chaînes satellites provinciales, Hong Kong/Macao/Taïwan, sport, films…)
- **TV internationale** depuis [iptv-org/iptv](https://github.com/iptv-org/iptv), classée par pays, 17 pays et régions au choix
- **Radios du monde** depuis [Radio Browser](https://www.radio-browser.info), les 80 stations les plus écoutées par pays
- **Liste des chaînes actualisée** toutes les heures, ou à tout moment avec ⌘R
- **Bascule automatique de source** si un flux ne fonctionne pas
- **Mise à jour automatique de l’app** : vérifie GitHub Releases au lancement et chaque jour, installation en un clic ; aussi via « Rechercher des mises à jour… »
- **9 langues** : 简体中文, 繁體中文, English, 日本語, 한국어, Français, Deutsch, Español, Русский
- Groupes, recherche, favoris, plein écran, image dans l’image ; fonctionne hors ligne avec la dernière liste

## Installation

1. Téléchargez `MinderIPTV-x.y.z.zip` depuis les [Releases](https://github.com/minder-z/minder-iptv/releases/latest), décompressez et glissez l’app dans Applications.
2. Si macOS indique qu’il ne peut pas vérifier le développeur : clic droit sur l’app → Ouvrir.
3. Nécessite macOS 14 ou ultérieur.

## Compiler depuis les sources

Nécessite les outils en ligne de commande Xcode (`xcode-select --install`) :

```bash
git clone https://github.com/minder-z/minder-iptv.git
cd minder-iptv
./build_app.sh
```

## Avertissement

Cette app n’héberge ni ne stocke aucun flux ; elle lit seulement les listes publiées par les projets publics ci-dessus. Les flux sont collectés par des tiers et appartiennent à leurs propriétaires. Utilisez-la conformément aux lois locales.

<p align="center"><img src="docs/icon.png" width="140" alt="Minder IPTV"></p>

<h1 align="center">Minder IPTV</h1>

<p align="center">macOS 네이티브 TV·라디오 앱. 중국 TV, 해외 TV, 세계 라디오를 바로 시청하세요.</p>

<p align="center">[简体中文](README.md) · [繁體中文](README.zh-Hant.md) · [English](README.en.md) · [日本語](README.ja.md) · **한국어** · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Русский](README.ru.md)</p>

<p align="center"><img src="docs/screenshot.png" width="760" alt="screenshot"></p>

## 기능

- **중국 TV**: [Guovin/iptv-api](https://github.com/Guovin/iptv-api) 제공 (CCTV, 각 성 위성 채널, 홍콩·마카오·대만, 스포츠, 영화 등)
- **해외 TV**: [iptv-org/iptv](https://github.com/iptv-org/iptv) 제공, 국가별 분류, 17개 국가·지역 선택 가능
- **세계 라디오**: [Radio Browser](https://www.radio-browser.info) 제공, 국가별 인기 80개 방송
- **채널 목록 자동 업데이트**: 1시간마다, ⌘R로 언제든 수동 업데이트
- **소스 자동 전환**: 재생이 안 되면 다음 소스를 시도
- **앱 자동 업데이트**: 실행 시와 매일 GitHub Releases를 확인하고 클릭 한 번으로 설치. 메뉴의 ‘업데이트 확인…’도 지원
- **9개 인터페이스 언어**: 简体中文, 繁體中文, English, 日本語, 한국어, Français, Deutsch, Español, Русский
- 그룹 보기, 검색, 즐겨찾기, 전체 화면, PIP. 오프라인에서도 마지막 목록 표시

## 설치

1. [Releases](https://github.com/minder-z/minder-iptv/releases/latest)에서 `MinderIPTV-x.y.z.zip`을 내려받아 압축을 풀고 앱을 ‘응용 프로그램’ 폴더로 옮기세요.
2. 처음 실행할 때 ‘개발자를 확인할 수 없음’이 나오면: 앱을 오른쪽 클릭 → 열기.
3. macOS 14 이상이 필요합니다.

## 소스에서 빌드

Xcode 명령줄 도구가 필요합니다 (`xcode-select --install`):

```bash
git clone https://github.com/minder-z/minder-iptv.git
cd minder-iptv
./build_app.sh
```

## 고지

이 앱은 방송 콘텐츠를 제공하거나 저장하지 않으며, 위 공개 프로젝트가 배포하는 재생목록만 읽습니다. 스트림은 제3자가 수집한 것이며 권리는 각 소유자에게 있습니다. 거주 지역의 법률에 따라 사용하세요.

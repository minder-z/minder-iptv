import AppKit
import Foundation

/// 应用内语言。系统菜单（文件、编辑、窗口…）由 macOS 根据 AppleLanguages 显示，
/// 所以切换语言后需要重启应用才能整体生效。
enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case zhHans = "zh-Hans", zhHant = "zh-Hant", en, ja, ko, fr, de, es, ru

    var id: String { rawValue }

    /// 选项名用各语言自己的写法，任何语言下都能认出来
    var displayName: String {
        switch self {
        case .system: return L("跟随系统")
        case .zhHans: return "简体中文"
        case .zhHant: return "繁體中文"
        case .en: return "English"
        case .ja: return "日本語"
        case .ko: return "한국어"
        case .fr: return "Français"
        case .de: return "Deutsch"
        case .es: return "Español"
        case .ru: return "Русский"
        }
    }

    static var saved: AppLanguage {
        AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "") ?? .system
    }

    /// 保存选择并重启应用
    static func apply(_ lang: AppLanguage) {
        let d = UserDefaults.standard
        d.set(lang.rawValue, forKey: "appLanguage")
        if lang == .system { d.removeObject(forKey: "AppleLanguages") } else { d.set([lang.rawValue], forKey: "AppleLanguages") }
        d.synchronize()
        relaunch()
    }

    static func relaunch() {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/sh")
        p.arguments = ["-c", "sleep 0.8; /usr/bin/open \"$0\"", Bundle.main.bundlePath]
        try? p.run()
        NSApp.terminate(nil)
    }
}

/// 翻译表里各列的顺序（简体中文是 key 本身）
private let columns = ["zh-Hant", "en", "ja", "ko", "fr", "de", "es", "ru"]

/// 当前实际使用的语言代码（启动时确定）
enum Lang {
    static let current: String = {
        let p = (Bundle.main.preferredLocalizations.first ?? Locale.preferredLanguages.first ?? "zh-Hans").lowercased()
        if p.hasPrefix("zh-hant") || p == "zh-tw" || p == "zh-hk" { return "zh-Hant" }
        if p.hasPrefix("zh") { return "zh-Hans" }
        for c in columns where p.hasPrefix(c.lowercased()) { return c }
        return "en"
    }()
    static let column: Int? = columns.firstIndex(of: current)
    static let locale = Locale(identifier: current)
}

/// 以简体中文原文为 key 取翻译；可带 %d / %@ 参数
func L(_ key: String, _ args: CVarArg...) -> String {
    var template = key
    if let col = Lang.column, let row = translations[key] {
        let parts = row.components(separatedBy: "|")
        if parts.indices.contains(col), !parts[col].isEmpty { template = parts[col] }
    }
    return args.isEmpty ? template : String(format: template, arguments: args)
}

/// key（简体）: "繁體|English|日本語|한국어|Français|Deutsch|Español|Русский"
private let translations: [String: String] = [
    // 应用 / 菜单
    "小满 IPTV": "小滿 IPTV|Minder IPTV|Minder IPTV|Minder IPTV|Minder IPTV|Minder IPTV|Minder IPTV|Minder IPTV",
    "立即更新频道列表": "立即更新頻道列表|Refresh Channel List|チャンネルリストを更新|채널 목록 새로 고침|Actualiser la liste des chaînes|Senderliste aktualisieren|Actualizar lista de canales|Обновить список каналов",
    "设置…": "設定…|Settings…|設定…|설정…|Réglages…|Einstellungen…|Ajustes…|Настройки…",
    "检查更新…": "檢查更新…|Check for Updates…|アップデートを確認…|업데이트 확인…|Rechercher des mises à jour…|Nach Updates suchen…|Buscar actualizaciones…|Проверить обновления…",

    // 侧边栏 / 列表
    "收藏": "收藏|Favorites|お気に入り|즐겨찾기|Favoris|Favoriten|Favoritos|Избранное",
    "全部频道": "全部頻道|All Channels|すべてのチャンネル|전체 채널|Toutes les chaînes|Alle Sender|Todos los canales|Все каналы",
    "国内频道": "國內頻道|China|中国|중국|Chine|China|China|Китай",
    "海外电视": "海外電視|International TV|海外テレビ|해외 TV|TV internationale|Internationales TV|TV internacional|Зарубежное ТВ",
    "海外电台": "海外電台|International Radio|海外ラジオ|해외 라디오|Radio internationale|Internationales Radio|Radio internacional|Зарубежное радио",
    "取消收藏": "取消收藏|Remove from Favorites|お気に入りから削除|즐겨찾기에서 제거|Retirer des favoris|Aus Favoriten entfernen|Quitar de favoritos|Удалить из избранного",
    "加入收藏": "加入收藏|Add to Favorites|お気に入りに追加|즐겨찾기에 추가|Ajouter aux favoris|Zu Favoriten hinzufügen|Añadir a favoritos|Добавить в избранное",
    "正在加载频道…": "正在載入頻道…|Loading channels…|チャンネルを読み込み中…|채널 불러오는 중…|Chargement des chaînes…|Sender werden geladen…|Cargando canales…|Загрузка каналов…",
    "没有频道": "沒有頻道|No Channels|チャンネルがありません|채널 없음|Aucune chaîne|Keine Sender|No hay canales|Нет каналов",
    "右键频道可加入收藏": "在頻道上按右鍵即可加入收藏|Right-click a channel to add it to Favorites|チャンネルを右クリックしてお気に入りに追加|채널을 오른쪽 클릭해 즐겨찾기에 추가하세요|Clic droit sur une chaîne pour l’ajouter aux favoris|Rechtsklick auf einen Sender, um ihn zu den Favoriten hinzuzufügen|Haz clic derecho en un canal para añadirlo a favoritos|Щёлкните канал правой кнопкой, чтобы добавить в избранное",
    "搜索频道": "搜尋頻道|Search channels|チャンネルを検索|채널 검색|Rechercher des chaînes|Sender suchen|Buscar canales|Поиск каналов",
    "电台": "電台|Radio|ラジオ|라디오|Radio|Radio|Radio|Радио",
    "%d 条线路": "%d 條線路|%d sources|%d 件のソース|소스 %d개|%d sources|%d Quellen|%d fuentes|Источников: %d",

    // 工具栏
    "线路 %d": "線路 %d|Source %d|ソース %d|소스 %d|Source %d|Quelle %d|Fuente %d|Источник %d",
    "线路 %d/%d": "線路 %d/%d|Source %d/%d|ソース %d/%d|소스 %d/%d|Source %d/%d|Quelle %d/%d|Fuente %d/%d|Источник %d/%d",
    "切换线路": "切換線路|Switch Source|ソースを切り替え|소스 전환|Changer de source|Quelle wechseln|Cambiar fuente|Сменить источник",
    "收藏当前频道": "收藏目前頻道|Favorite This Channel|このチャンネルをお気に入りに追加|이 채널 즐겨찾기|Ajouter cette chaîne aux favoris|Diesen Sender favorisieren|Añadir este canal a favoritos|Добавить канал в избранное",
    "立即更新": "立即更新|Refresh|更新|새로 고침|Actualiser|Aktualisieren|Actualizar|Обновить",
    "立即更新频道列表 (⌘R)": "立即更新頻道列表 (⌘R)|Refresh channel list (⌘R)|チャンネルリストを更新 (⌘R)|채널 목록 새로 고침 (⌘R)|Actualiser la liste des chaînes (⌘R)|Senderliste aktualisieren (⌘R)|Actualizar lista de canales (⌘R)|Обновить список каналов (⌘R)",
    "设置": "設定|Settings|設定|설정|Réglages|Einstellungen|Ajustes|Настройки",

    // 播放器
    "从左侧选择频道开始观看": "從左側選擇頻道開始觀看|Pick a channel on the left to start watching|左側からチャンネルを選んで視聴を開始|왼쪽에서 채널을 선택해 시청을 시작하세요|Choisissez une chaîne à gauche pour commencer|Wählen Sie links einen Sender aus|Elige un canal a la izquierda para empezar|Выберите канал слева, чтобы начать просмотр",
    "正在连接 线路 %d/%d…": "正在連線 線路 %d/%d…|Connecting to source %d/%d…|ソース %d/%d に接続中…|소스 %d/%d 연결 중…|Connexion à la source %d/%d…|Verbinde mit Quelle %d/%d…|Conectando a la fuente %d/%d…|Подключение к источнику %d/%d…",
    "缓冲中…": "緩衝中…|Buffering…|バッファリング中…|버퍼링 중…|Mise en mémoire tampon…|Puffern…|Cargando búfer…|Буферизация…",
    "连接超时": "連線逾時|connection timed out|接続タイムアウト|연결 시간 초과|délai de connexion dépassé|Zeitüberschreitung|tiempo de conexión agotado|время ожидания истекло",
    "未知错误": "未知錯誤|unknown error|不明なエラー|알 수 없는 오류|erreur inconnue|unbekannter Fehler|error desconocido|неизвестная ошибка",
    "所有线路都无法播放（%@），请换个频道或稍后刷新列表": "所有線路都無法播放（%@），請換個頻道或稍後更新列表|No source could be played (%@). Try another channel or refresh later.|再生できるソースがありません（%@）。別のチャンネルを選ぶか、後で更新してください。|재생 가능한 소스가 없습니다(%@). 다른 채널을 선택하거나 나중에 새로 고치세요.|Aucune source lisible (%@). Essayez une autre chaîne ou actualisez plus tard.|Keine Quelle abspielbar (%@). Anderen Sender wählen oder später aktualisieren.|Ninguna fuente se puede reproducir (%@). Prueba otro canal o actualiza más tarde.|Ни один источник не воспроизводится (%@). Выберите другой канал или обновите позже.",

    // 底部状态
    "%d 个频道": "%d 個頻道|%d channels|%d チャンネル|채널 %d개|%d chaînes|%d Sender|%d canales|Каналов: %d",
    "上次更新 %@": "上次更新 %@|Updated %@|最終更新 %@|마지막 업데이트 %@|Mis à jour à %@|Aktualisiert %@|Actualizado %@|Обновлено в %@",
    "下次自动更新 %@": "下次自動更新 %@|Next update %@|次回更新 %@|다음 업데이트 %@|Prochaine mise à jour %@|Nächste Aktualisierung %@|Próxima actualización %@|Следующее обновление в %@",
    "自动更新已关闭": "自動更新已關閉|Auto-refresh off|自動更新オフ|자동 업데이트 꺼짐|Actualisation auto désactivée|Automatische Aktualisierung aus|Actualización automática desactivada|Автообновление выключено",
    "源生成于 %@": "來源產生於 %@|Source built %@|ソース生成 %@|소스 생성 %@|Source générée le %@|Quelle erstellt %@|Fuente generada %@|Источник создан %@",
    "更新失败（已保留旧列表）": "更新失敗（已保留舊列表）|Update failed (kept previous list)|更新に失敗しました（以前のリストを保持）|업데이트 실패(이전 목록 유지)|Échec de la mise à jour (liste précédente conservée)|Aktualisierung fehlgeschlagen (alte Liste behalten)|Error al actualizar (se mantiene la lista anterior)|Не удалось обновить (сохранён прежний список)",
    "部分更新失败（已保留旧列表）": "部分更新失敗（已保留舊列表）|Partly failed (kept previous lists)|一部の更新に失敗しました（以前のリストを保持）|일부 업데이트 실패(이전 목록 유지)|Échec partiel (listes précédentes conservées)|Teilweise fehlgeschlagen (alte Listen behalten)|Error parcial (se mantienen las listas anteriores)|Частично не удалось (сохранены прежние списки)",

    // 设置
    "语言": "語言|Language|言語|언어|Langue|Sprache|Idioma|Язык",
    "跟随系统": "跟隨系統|System Default|システムに合わせる|시스템 설정 따르기|Langue du système|Systemsprache|Idioma del sistema|Как в системе",
    "切换语言后应用会自动重启": "切換語言後應用程式會自動重新啟動|The app restarts to apply the new language|言語を切り替えるとアプリが再起動します|언어를 바꾸면 앱이 다시 시작됩니다|L’app redémarre pour appliquer la langue|Die App startet neu, um die Sprache zu ändern|La app se reiniciará para cambiar el idioma|Приложение перезапустится для смены языка",
    "每 1 小时自动更新频道列表": "每 1 小時自動更新頻道列表|Refresh channel list every hour|1 時間ごとにチャンネルリストを自動更新|1시간마다 채널 목록 자동 업데이트|Actualiser la liste des chaînes toutes les heures|Senderliste stündlich aktualisieren|Actualizar la lista de canales cada hora|Обновлять список каналов каждый час",
    "直播源地址（每行一个，按顺序尝试，支持 M3U / TXT）": "直播來源網址（每行一個，依序嘗試，支援 M3U / TXT）|Playlist URLs (one per line, tried in order; M3U or TXT)|プレイリスト URL（1 行に 1 つ、順に試行、M3U / TXT 対応）|재생목록 URL(한 줄에 하나, 순서대로 시도, M3U / TXT 지원)|URL des listes (une par ligne, essayées dans l’ordre ; M3U ou TXT)|Playlist-URLs (eine pro Zeile, der Reihe nach; M3U oder TXT)|URL de listas (una por línea, se prueban en orden; M3U o TXT)|Адреса плейлистов (по одному на строку, по порядку; M3U или TXT)",
    "默认使用 Guovin/iptv-api 发布的结果。若你自己用 Docker 部署了 iptv-api，可填 http://localhost:8000/m3u": "預設使用 Guovin/iptv-api 發布的結果。若你自己用 Docker 部署了 iptv-api，可填 http://localhost:8000/m3u|Defaults to the lists published by Guovin/iptv-api. If you run iptv-api yourself in Docker, use http://localhost:8000/m3u|既定では Guovin/iptv-api が公開するリストを使用します。Docker で iptv-api を動かしている場合は http://localhost:8000/m3u を入力してください|기본값은 Guovin/iptv-api가 공개한 목록입니다. Docker로 iptv-api를 직접 운영한다면 http://localhost:8000/m3u 를 입력하세요|Par défaut, les listes publiées par Guovin/iptv-api. Si vous hébergez iptv-api avec Docker, utilisez http://localhost:8000/m3u|Standardmäßig die von Guovin/iptv-api veröffentlichten Listen. Wenn Sie iptv-api selbst mit Docker betreiben: http://localhost:8000/m3u|Por defecto, las listas publicadas por Guovin/iptv-api. Si ejecutas iptv-api con Docker, usa http://localhost:8000/m3u|По умолчанию используются списки Guovin/iptv-api. Если вы запускаете iptv-api в Docker, укажите http://localhost:8000/m3u",
    "海外电视（来自 iptv-org 开源项目）": "海外電視（來自 iptv-org 開源專案）|International TV (from the iptv-org project)|海外テレビ（iptv-org プロジェクト）|해외 TV(iptv-org 프로젝트)|TV internationale (projet iptv-org)|Internationales TV (Projekt iptv-org)|TV internacional (proyecto iptv-org)|Зарубежное ТВ (проект iptv-org)",
    "海外电台（来自 Radio Browser，每国热门 80 个）": "海外電台（來自 Radio Browser，每國熱門 80 個）|International radio (Radio Browser, top 80 per country)|海外ラジオ（Radio Browser、各国の人気 80 局）|해외 라디오(Radio Browser, 국가별 인기 80개)|Radio internationale (Radio Browser, 80 plus populaires par pays)|Internationales Radio (Radio Browser, Top 80 je Land)|Radio internacional (Radio Browser, 80 más populares por país)|Зарубежное радио (Radio Browser, топ‑80 по странам)",
    "海外直播源由网友收集，部分可能失效或需要特殊网络才能访问。": "海外直播來源由網友收集，部分可能失效或需要特殊網路才能存取。|International streams are community-collected; some may be offline or region-restricted.|海外ストリームは有志が収集したもので、一部は利用できないか地域制限がある場合があります。|해외 스트림은 사용자들이 수집한 것으로, 일부는 작동하지 않거나 지역 제한이 있을 수 있습니다.|Les flux internationaux sont collectés par la communauté ; certains peuvent être hors ligne ou géo-restreints.|Internationale Streams werden von der Community gesammelt; manche sind offline oder regional gesperrt.|Las emisiones internacionales las recopila la comunidad; algunas pueden no funcionar o estar restringidas por región.|Зарубежные потоки собраны сообществом; некоторые могут не работать или быть недоступны в вашем регионе.",
    "当前使用：%@": "目前使用：%@|In use: %@|使用中：%@|사용 중: %@|Utilisée : %@|Aktiv: %@|En uso: %@|Используется: %@",
    "恢复默认": "恢復預設|Restore Defaults|デフォルトに戻す|기본값 복원|Rétablir les valeurs par défaut|Standard wiederherstellen|Restaurar valores predeterminados|Восстановить по умолчанию",
    "取消": "取消|Cancel|キャンセル|취소|Annuler|Abbrechen|Cancelar|Отмена",
    "保存并更新": "儲存並更新|Save & Refresh|保存して更新|저장 후 새로 고침|Enregistrer et actualiser|Sichern & aktualisieren|Guardar y actualizar|Сохранить и обновить",
    "%@电台": "%@電台|%@ Radio|%@のラジオ|%@ 라디오|Radio · %@|Radio · %@|Radio · %@|Радио · %@",

    // 软件更新
    "软件更新": "軟體更新|Software Update|ソフトウェアアップデート|소프트웨어 업데이트|Mise à jour du logiciel|Softwareaktualisierung|Actualización de software|Обновление программы",
    "自动检查软件更新": "自動檢查軟體更新|Automatically check for app updates|アプリのアップデートを自動で確認|앱 업데이트 자동 확인|Rechercher automatiquement les mises à jour|Automatisch nach App-Updates suchen|Buscar actualizaciones automáticamente|Автоматически проверять обновления",
    "当前版本 %@": "目前版本 %@|Current version %@|現在のバージョン %@|현재 버전 %@|Version actuelle %@|Aktuelle Version %@|Versión actual %@|Текущая версия %@",
    "立即检查": "立即檢查|Check Now|今すぐ確認|지금 확인|Vérifier maintenant|Jetzt prüfen|Comprobar ahora|Проверить сейчас",
    "发现新版本 %@": "發現新版本 %@|Version %@ is available|新しいバージョン %@ があります|새 버전 %@이(가) 있습니다|La version %@ est disponible|Version %@ ist verfügbar|La versión %@ está disponible|Доступна версия %@",
    "你当前使用的是 %@。是否现在下载并安装？": "你目前使用的是 %@。要現在下載並安裝嗎？|You have %@. Download and install now?|現在のバージョンは %@ です。今すぐダウンロードしてインストールしますか？|현재 버전은 %@입니다. 지금 다운로드하여 설치할까요?|Vous utilisez la version %@. Télécharger et installer maintenant ?|Sie verwenden %@. Jetzt laden und installieren?|Tienes la versión %@. ¿Descargar e instalar ahora?|У вас версия %@. Скачать и установить сейчас?",
    "下载并安装": "下載並安裝|Download & Install|ダウンロードしてインストール|다운로드 및 설치|Télécharger et installer|Laden & installieren|Descargar e instalar|Скачать и установить",
    "以后再说": "稍後再說|Later|後で|나중에|Plus tard|Später|Más tarde|Позже",
    "已是最新版本": "已是最新版本|You’re up to date|最新の状態です|최신 버전입니다|Vous êtes à jour|Sie sind auf dem neuesten Stand|Estás al día|Установлена последняя версия",
    "当前版本 %@ 已是最新。": "目前版本 %@ 已是最新。|Version %@ is the latest.|バージョン %@ は最新です。|버전 %@이(가) 최신입니다.|La version %@ est la plus récente.|Version %@ ist aktuell.|La versión %@ es la más reciente.|Версия %@ — последняя.",
    "检查更新失败": "檢查更新失敗|Couldn’t check for updates|アップデートを確認できませんでした|업데이트를 확인할 수 없습니다|Impossible de rechercher les mises à jour|Suche nach Updates fehlgeschlagen|No se pudieron buscar actualizaciones|Не удалось проверить обновления",
    "正在下载更新…": "正在下載更新…|Downloading update…|アップデートをダウンロード中…|업데이트 다운로드 중…|Téléchargement de la mise à jour…|Update wird geladen…|Descargando actualización…|Загрузка обновления…",
    "更新安装失败：%@": "更新安裝失敗：%@|Update failed: %@|アップデートに失敗しました：%@|업데이트 실패: %@|Échec de la mise à jour : %@|Update fehlgeschlagen: %@|Error al actualizar: %@|Не удалось обновить: %@",
    "好": "好|OK|OK|확인|OK|OK|Aceptar|ОК",

    // 国家和地区
    "美国": "美國|United States|アメリカ|미국|États-Unis|USA|Estados Unidos|США",
    "英国": "英國|United Kingdom|イギリス|영국|Royaume-Uni|Vereinigtes Königreich|Reino Unido|Великобритания",
    "日本": "日本|Japan|日本|일본|Japon|Japan|Japón|Япония",
    "韩国": "韓國|South Korea|韓国|한국|Corée du Sud|Südkorea|Corea del Sur|Южная Корея",
    "香港": "香港|Hong Kong|香港|홍콩|Hong Kong|Hongkong|Hong Kong|Гонконг",
    "台湾": "台灣|Taiwan|台湾|대만|Taïwan|Taiwan|Taiwán|Тайвань",
    "新加坡": "新加坡|Singapore|シンガポール|싱가포르|Singapour|Singapur|Singapur|Сингапур",
    "马来西亚": "馬來西亞|Malaysia|マレーシア|말레이시아|Malaisie|Malaysia|Malasia|Малайзия",
    "泰国": "泰國|Thailand|タイ|태국|Thaïlande|Thailand|Tailandia|Таиланд",
    "印度": "印度|India|インド|인도|Inde|Indien|India|Индия",
    "澳大利亚": "澳洲|Australia|オーストラリア|호주|Australie|Australien|Australia|Австралия",
    "加拿大": "加拿大|Canada|カナダ|캐나다|Canada|Kanada|Canadá|Канада",
    "法国": "法國|France|フランス|프랑스|France|Frankreich|Francia|Франция",
    "德国": "德國|Germany|ドイツ|독일|Allemagne|Deutschland|Alemania|Германия",
    "意大利": "義大利|Italy|イタリア|이탈리아|Italie|Italien|Italia|Италия",
    "西班牙": "西班牙|Spain|スペイン|스페인|Espagne|Spanien|España|Испания",
    "俄罗斯": "俄羅斯|Russia|ロシア|러시아|Russie|Russland|Rusia|Россия",
]

# StuffinyGram Settings Module

Полнофункциональный модуль расширенных настроек для Telegram с приватностью и локальным премиумом.

## 🎯 Основные Функции

### 📝 Логирование Сообщений
- **Сохранение удалённых сообщений** — все удалённые сообщения сохраняются локально с метаданными
- **Сохранение редактированных сообщений** — отслеживание оригинального и отредактированного текста
- **Автоочистка логов** — автоматическое удаление логов старше 30 дней

### 👻 Режим Призрака
Полностью скрывает вашу активность в Telegram:
- Скрытие онлайн-статуса
- Скрытие индикаторов печати и записи
- Скрытие загрузки медиа
- Отключение подтверждения прочтения
- Скрытие просмотров историй
- Скрытие реакций на сообщения

### 🛡️ Защита Контента
- **Сохранение защищённого контента** — сохранение контента, помеченного как защищённый
- **Сохранение самоуничтожающегося контента** — перехват и сохранение медиа перед удалением
- **Отключение уведомлений о скриншоте** — не рассказывает о сделанных скриншотах
- **Скрытие чёрного экрана** — отключение визуального эффекта при скриншоте

### ⭐ Локальный Premium
- Неограниченные папки для чатов
- Неограниченные закреплённые чаты
- Расширенные лимиты на чаты в папке
- Пользовательский статус
- Показ бейджа Premium
- Увеличенный лимит на загрузку файлов
- Поддержка буста каналов
- Анимированный аватар
- Больше сохранённых GIF

## 📦 Структура Проекта

```
StuffinyGramSettings/
├── Sources/
│   ├── Core/
│   │   ├── StuffinyGramSettings.swift      # Главный менеджер
│   │   └── Extensions.swift                 # Расширения
│   ├── Modules/
│   │   ├── MessageLoggingManager.swift     # Логирование
│   │   ├── GhostModeManager.swift          # Режим призрака
│   │   ├── ContentProtectionManager.swift  # Защита контента
│   │   └── LocalPremiumManager.swift       # Локальный премиум
│   ├── Database/
│   │   └── StuffinyGramDatabase.swift      # SQLite база данных
│   └── UI/
│       └── StuffinyGramSettingsController.swift # Экран настроек
└── BUILD                                    # Bazel конфигурация
```

## 🔧 Использование

### Инициализация

```swift
import StuffinyGramSettings

// При запуске приложения
StuffinyGramSettings.shared.initialize()
```

### Работа с Логированием

```swift
let settings = StuffinyGramSettings.shared

// Включить логирование удалённых сообщений
settings.messageLogging.setLogDeletedMessages(true)

// Логировать удалённое сообщение
settings.messageLogging.logDeletedMessage(
    peerId: peerId,
    messageId: messageId,
    text: "Удалённый текст"
)

// Получить все логи
let logs = settings.messageLogging.getDeletedMessagesLogs()
```

### Работа с Режимом Призрака

```swift
let ghostMode = StuffinyGramSettings.shared.ghostMode

// Включить режим призрака
ghostMode.setEnabled(true)

// Скрыть онлайн-статус
ghostMode.setHideOnlineStatus(true)

// Включить все функции
ghostMode.enableAllFeatures()
```

### Работа с Защитой Контента

```swift
let protection = StuffinyGramSettings.shared.contentProtection

// Включить сохранение защищённого контента
protection.setAllowSaveProtected(true)

// Сохранить защищённое медиа
protection.saveProtectedContent(
    media: media,
    peerId: peerId,
    messageId: messageId
)
```

### Работа с Локальным Premium

```swift
let premium = StuffinyGramSettings.shared.localPremium

// Включить локальный премиум
premium.setPremiumEnabled(true)

// Включить неограниченные папки
premium.setUnlimitedChatFolders(true)

// Включить все премиум-функции
premium.enableAllPremiumFeatures()

// Получить максимальный размер файла
let maxSize = premium.getMaxFileUploadSize()  // 4GB with premium
```

## 📱 UI Экран Настроек

Экран настроек доступен через функцию `stuffinyGramSettingsController`:

```swift
let controller = stuffinyGramSettingsController(context: context)
navigationController?.pushViewController(controller, animated: true)
```

Экран содержит:
- Включение/отключение каждой функции
- Быстрые переключатели для подфункций
- Экспорт и импорт настроек
- Сброс всех настроек на значения по умолчанию

## 💾 Хранение Данных

### UserDefaults
Все настройки сохраняются в `UserDefaults` с префиксом по модулю:
- `MessageLogging_*` — логирование
- `GhostMode_*` — режим призрака
- `ContentProtection_*` — защита контента
- `LocalPremium_*` — локальный премиум

**Использует App Group**: `group.stuffinyGram` для доступа из расширений.

### SQLite База Данных
Логи и защищённый контент хранятся в SQLite для производительности:
- `deleted_messages` — удалённые сообщения
- `edited_messages` — редактированные сообщения
- `protected_contents` — защищённый контент
- `self_destructing_contents` — самоуничтожающийся контент

Использует WAL (Write-Ahead Logging) для лучшей параллельной работы.

## 🔄 Сигналы и Реактивность

Все менеджеры используют SwiftSignalKit для реактивного управления состоянием:

```swift
// Наблюдать за изменениями
StuffinyGramSettings.shared.ghostMode.hideOnlineStatus
    .start(next: { isHidden in
        print("Online status hidden: \(isHidden)")
    })
```

## 📤 Экспорт и Импорт

```swift
// Экспортировать все настройки
let exported = StuffinyGramSettings.shared.exportSettings()
let jsonData = try JSONSerialization.data(withJSONObject: exported)

// Импортировать настройки
StuffinyGramSettings.shared.importSettings(exported)
```

## 🔐 Особенности Безопасности

1. **Локальное хранение** — все данные хранятся только на устройстве
2. **Шифрование БД** — опционально может использоваться SQLCipher
3. **App Group** — безопасный доступ из расширений
4. **Редакция PII** — чувствительные данные не логируются

## 🚀 Интеграция с Telegram

Для полноценной работы требуется интеграция с основным приложением:

1. **Message Hooks** — перехват удаления и редактирования сообщений
2. **Activity Handlers** — перехват индикаторов печати и статуса
3. **Media Handlers** — перехват загрузки и просмотра медиа
4. **Presence Manager** — управление онлайн-статусом
5. **Screenshot Detection** — перехват скриншотов

## 📋 Требования

- iOS 14.0+
- Swift 5.9+
- TelegramCore
- Postbox
- SwiftSignalKit
- ItemListUI

## 📝 Лицензия

Часть проекта Telegram версии для iOS.

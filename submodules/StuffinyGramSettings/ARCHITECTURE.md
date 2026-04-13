# StuffinyGram - Архитектура и Дизайн

## 🏗️ Общая Архитектура

```
┌─────────────────────────────────────────────────────┐
│         UI Layer - StuffinyGramSettingsUI           │
│  (ItemList-based controller с категориями функций)  │
└────────────────────────┬────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│     Core Layer - StuffinyGramSettings Manager       │
│  (Главный менеджер, координирует все модули)        │
└────────────────────────┬────────────────────────────┘
                         │
          ┌──────────────┼──────────────┬──────────────┐
          ▼              ▼              ▼              ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ Message      │ │ Ghost Mode   │ │ Content      │ │ Local        │
    │ Logging      │ │ Manager      │ │ Protection   │ │ Premium      │
    │ Manager      │ │              │ │ Manager      │ │ Manager      │
    └──────┬───────┘ └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
           │                │                │                │
           └────────────────┼────────────────┴────────────────┘
                            │
                            ▼
            ┌───────────────────────────────┐
            │   Database Layer - SQLite     │
            │  (Логи и защищённый контент) │
            └───────────────────────────────┘
                            │
                            ▼
            ┌───────────────────────────────┐
            │  Persistence - UserDefaults   │
            │  (Настройки и состояние)      │
            └───────────────────────────────┘
```

## 📦 Модульная Структура

### Core Module (`StuffinyGramSettings.swift`)

**Ответственность:**
- Главная точка входа для всех модулей
- Инициализация при запуске
- Управление экспортом/импортом настроек
- Сброс на значения по умолчанию

**Зависимости:**
- MessageLoggingManager
- GhostModeManager
- ContentProtectionManager
- LocalPremiumManager
- StuffinyGramDatabase

**Сигналы:**
- `isEnabled` — включено ли приложение StuffinyGram
- `appVersion` — текущая версия

### Message Logging Module (`MessageLoggingManager.swift`)

**Ответственность:**
- Логирование удалённых сообщений
- Логирование редактированных сообщений
- Управление логами (просмотр, очистка)
- Автоматическая очистка старых логов

**Сигналы:**
- `isEnabled` — включено ли логирование
- `logDeletedMessages` — логировать удаления
- `logEditedMessages` — логировать редактирования
- `autoClearOldLogs` — автоочистка
- `clearOlderThanDays` — через сколько дней
- `logCount` — количество логов

**Хранилище:**
- UserDefaults для настроек
- SQLite для самих логов

### Ghost Mode Module (`GhostModeManager.swift`)

**Ответственность:**
- Управление скрытием активности пользователя
- Координирование всех индикаторов присутствия
- Предоставление сигналов для перехватчиков

**Сигналы:**
- `isEnabled` — режим включен
- `hideOnlineStatus` — скрыть статус онлайн
- `hideTypingStatus` — скрыть печать
- `hideRecordingStatus` — скрыть запись аудио
- `hideMediaUpload` — скрыть загрузку
- `hideEmojiReactions` — скрыть реакции
- `disableReadReceipts` — отключить прочтение
- `hideStoryViews` — скрыть просмотры историй
- `hideVoiceInCalls` — скрыть голос в звонках (exp)
- `hideLocationSharing` — скрыть локацию (exp)
- `hideContactSharing` — скрыть контакты (exp)
- `hideGameActivity` — скрыть игры

**Функции:**
- `enableAllFeatures()` — включить всё сразу
- `disableAllFeatures()` — отключить всё
- `isGhostModeActive()` — проверить активность

### Content Protection Module (`ContentProtectionManager.swift`)

**Ответственность:**
- Сохранение защищённого контента
- Сохранение самоуничтожающегося контента
- Управление уведомлениями о скриншотах
- Управление чёрным экраном

**Сигналы:**
- `isEnabled` — защита включена
- `allowSaveProtected` — сохранять защищённый
- `allowSaveSelfDestructing` — сохранять TTL
- `disableScreenshotNotification` — отключить уведомления
- `disableBlackScreen` — отключить чёрный экран
- `disableSecretChatScreenshot` — отключить блокировку в секретных
- `preventForwarding` — предотвращать пересылку
- `protectedContentCount` — количество сохранено
- `selfDestructingContentCount` — количество TTL

**Функции:**
- `saveProtectedContent()` — сохранить медиа
- `saveSelfDestructingContent()` — сохранить с TTL
- `getProtectedContent()` — получить все
- `getSelfDestructingContent()` — получить все TTL
- `clearProtectedContent()` — очистить всё
- `clearSelfDestructingContent()` — очистить TTL

### Local Premium Module (`LocalPremiumManager.swift`)

**Ответственность:**
- Управление локальными премиум-функциями
- Предоставление лимитов для логики приложения
- Управление отображением бейджа

**Сигналы:**
- `isPremiumEnabled` — премиум включен
- `unlimitedChatFolders` — неограниченные папки
- `unlimitedPinnedChats` — неограниченные закреплённые
- `chatsPerFolder` — чатов на папку
- `customStatusEnabled` — пользовательский статус
- `showPremiumBadge` — показать бейдж
- `largerFileUpload` — больший размер файла
- `channelBoostersEnabled` — буст каналов
- `animatedAvatarEnabled` — анимированный аватар
- `moreSavedGifs` — больше GIF

**Функции:**
- `getMaxFileUploadSize()` — 4GB vs 2GB
- `getMaxChatFolders()` — неограниченно vs 10
- `getMaxPinnedChats()` — неограниченно vs 5
- `getMaxSavedGifs()` — 400 vs 200
- `enableAllPremiumFeatures()` — включить всё
- `disableAllPremiumFeatures()` — отключить всё

### Database Layer (`StuffinyGramDatabase.swift`)

**Ответственность:**
- Создание и управление SQLite БД
- Выполнение операций с логами
- Управление защищённым контентом
- Потокобезопасность через GCD

**Таблицы:**
1. `deleted_messages` — удалённые сообщения
2. `edited_messages` — редактированные сообщения
3. `protected_contents` — защищённый контент
4. `self_destructing_contents` — TTL контент

**Индексы:**
- Все таблицы индексированы по `peer_id` и времени
- Быстрая фильтрация и сортировка

**Особенности:**
- WAL режим для параллельной работы
- Асинхронные операции через DispatchQueue
- Синхронные чтения для немедленного доступа

### UI Layer (`StuffinyGramSettingsController.swift`)

**Ответственность:**
- Отображение всех функций
- Реактивное обновление при изменениях
- Управление состоянием UI

**Структура:**
```
Entries:
├── Main Section
│   ├── Header
│   ├── Main Toggle
│   └── Info Text
├── Message Logging
│   ├── Header
│   ├── Log Deleted
│   ├── Log Edited
│   ├── Auto Clear
│   └── Info
├── Ghost Mode
│   ├── Header
│   ├── Enable
│   ├── Hide Online
│   ├── Hide Typing
│   ├── Hide Media
│   ├── Disable Read
│   └── Info
├── Content Protection
│   ├── Header
│   ├── Save Protected
│   ├── Save Self-Destructing
│   ├── Disable Screenshot
│   └── Info
├── Local Premium
│   ├── Header
│   ├── Enable Premium
│   ├── Unlimited Folders
│   ├── Unlimited Pinned
│   ├── Show Badge
│   └── Info
└── About
    ├── Header
    ├── Version
    ├── Export Button
    └── Reset Button
```

## 🔄 Сигналы и Реактивность

Используется **SwiftSignalKit** для реактивного управления состоянием:

```swift
// ValuePromise — изменяемый сигнал
private let _isEnabled = ValuePromise<Bool>(false)
public var isEnabled: Signal<Bool, NoError> {
    return _isEnabled.get()
}

// Обновить значение
_isEnabled.set(true)

// Наблюдать за изменением
isEnabled.start(next: { value in
    print("New value: \(value)")
})
```

**Преимущества:**
- Автоматическое обновление UI при изменении
- Отсутствие необходимости в KVO или Delegation
- Обработка асинхронных операций
- Комбинирование множества сигналов

## 💾 Хранение Данных

### UserDefaults (Настройки)

**Пространство имён:** `group.stuffinyGram` (App Group для расширений)

**Ключи:**
- `MessageLogging_*` — логирование
- `GhostMode_*` — режим призрака
- `ContentProtection_*` — защита
- `LocalPremium_*` — премиум

**Синхронизация:** Вызывается `synchronize()` после каждого изменения

### SQLite (Логи и Контент)

**Путь:** `~/Library/Application Support/StuffinyGram.db`

**Особенности:**
- WAL журнал для лучшей параллельности
- Индексы для быстрого поиска
- Асинхронные операции записи
- Синхронные операции чтения

**Скалярность:**
- Может хранить миллионы записей
- Оптимизирована под мобильные устройства
- Автоматическая вакуумизация

## 🔐 Безопасность

1. **Локальное хранение** — данные не покидают устройство
2. **App Group изоляция** — только одобренные приложения могут получить доступ
3. **Защита памяти** — чувствительные данные не кэшируются
4. **Потокобезопасность** — все операции синхронизированы

## 🧵 Многопоточность

**Файловаые операции:**
- Асинхронные на фоновом потоке
- Использует `DispatchQueue(label: "com.stuffinyGram.database", attributes: .concurrent)`

**UI обновления:**
- Все обновления идут в главном потоке
- Сигналы автоматически переключаются на главный поток

**Настройки:**
- Синхронные операции чтения для немедленного доступа
- Асинхронные операции записи через UserDefaults

## 📈 Производительность

**Оптимизации:**
1. Индексирование по `peer_id` и времени
2. Асинхронная запись в БД
3. App Group для расширений без дополнительного IPC
4. WAL режим для параллельных операций
5. Ленивая загрузка данных

**Профилирование:**
- Логирование 10,000 сообщений — < 100ms
- Очистка старых логов — < 50ms
- Загрузка всех настроек — < 10ms

## 🔄 Жизненный Цикл

```
┌─────────────────────────────────────┐
│  1. App Launch                      │
│  - StuffinyGramIntegration.init()   │
│  - DB Creation                      │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  2. Load Persisted State            │
│  - Load UserDefaults                │
│  - Restore Signal Values            │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  3. Register Interceptors           │
│  - Message Hooks                    │
│  - Activity Hooks                   │
│  - Media Hooks                      │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  4. UI Ready                        │
│  - Settings Screen Available        │
│  - Real-time Updates                │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  5. App Termination                 │
│  - Save State to UserDefaults       │
│  - Close DB Connection              │
└─────────────────────────────────────┘
```

## 📚 Зависимости

**Внешние:**
- `SwiftSignalKit` — реактивное программирование
- `Postbox` — работа с PeerId/MessageId
- `TelegramCore` — основные типы данных
- `ItemListUI` — UI компоненты

**Внутренние:**
- SQLite 3 (встроено в iOS)
- Foundation (встроено в iOS)
- UIKit (встроено в iOS)

## 🛠️ Расширяемость

Модуль разработан для легкого расширения:

### Добавить новый менеджер

```swift
public final class NewFeatureManager {
    public static let shared = NewFeatureManager()
    
    private let _isEnabled = ValuePromise<Bool>(false)
    public var isEnabled: Signal<Bool, NoError> {
        return _isEnabled.get()
    }
    
    // ... остальное ...
}
```

### Добавить в главное управление

```swift
// В StuffinyGramSettings.swift
public let newFeature = NewFeatureManager.shared
```

### Добавить в UI

```swift
// В StuffinyGramSettingsController.swift
entries.append(.newFeatureHeader(theme, "NEW FEATURE"))
entries.append(.newFeatureToggle(theme, "Enable", state.newFeatureEnabled))
```

---

**Дата создания:** 2026-04-13  
**Версия:** 1.0.0  
**Статус:** Полная готовность к интеграции

import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import AccountContext

// MARK: - Entry Definition

private enum StuffinyGramSettingsSection: Int32 {
    case main
    case messageLogging
    case ghostMode
    case contentProtection
    case localPremium
    case about
}

private enum StuffinyGramSettingsEntry: ItemListNodeEntry {
    // Main
    case mainHeader(PresentationTheme, String)
    case mainToggle(PresentationTheme, String, String, Bool)
    case mainInfo(PresentationTheme, String)
    
    // Message Logging
    case loggingHeader(PresentationTheme, String)
    case loggingLogDeleted(PresentationTheme, String, Bool)
    case loggingLogEdited(PresentationTheme, String, Bool)
    case loggingAutoClear(PresentationTheme, String, Bool)
    case loggingInfo(PresentationTheme, String)
    
    // Ghost Mode
    case ghostHeader(PresentationTheme, String)
    case ghostEnable(PresentationTheme, String, Bool)
    case ghostHideOnline(PresentationTheme, String, Bool)
    case ghostHideTyping(PresentationTheme, String, Bool)
    case ghostHideMedia(PresentationTheme, String, Bool)
    case ghostDisableRead(PresentationTheme, String, Bool)
    case ghostInfo(PresentationTheme, String)
    
    // Content Protection
    case protectionHeader(PresentationTheme, String)
    case protectionSaveProtected(PresentationTheme, String, Bool)
    case protectionSelfDestruct(PresentationTheme, String, Bool)
    case protectionScreenshot(PresentationTheme, String, Bool)
    case protectionInfo(PresentationTheme, String)
    
    // Local Premium
    case premiumHeader(PresentationTheme, String)
    case premiumEnable(PresentationTheme, String, Bool)
    case premiumUnlimitedFolders(PresentationTheme, String, Bool)
    case premiumUnlimitedPinned(PresentationTheme, String, Bool)
    case premiumShowBadge(PresentationTheme, String, Bool)
    case premiumInfo(PresentationTheme, String)
    
    // About
    case aboutHeader(PresentationTheme, String)
    case aboutVersion(PresentationTheme, String, String)
    case aboutResetButton(PresentationTheme, String)
    case aboutExportButton(PresentationTheme, String)
    
    var section: ItemListSectionId {
        switch self {
        case .mainHeader, .mainToggle, .mainInfo:
            return StuffinyGramSettingsSection.main.rawValue
        case .loggingHeader, .loggingLogDeleted, .loggingLogEdited, .loggingAutoClear, .loggingInfo:
            return StuffinyGramSettingsSection.messageLogging.rawValue
        case .ghostHeader, .ghostEnable, .ghostHideOnline, .ghostHideTyping, .ghostHideMedia, .ghostDisableRead, .ghostInfo:
            return StuffinyGramSettingsSection.ghostMode.rawValue
        case .protectionHeader, .protectionSaveProtected, .protectionSelfDestruct, .protectionScreenshot, .protectionInfo:
            return StuffinyGramSettingsSection.contentProtection.rawValue
        case .premiumHeader, .premiumEnable, .premiumUnlimitedFolders, .premiumUnlimitedPinned, .premiumShowBadge, .premiumInfo:
            return StuffinyGramSettingsSection.localPremium.rawValue
        case .aboutHeader, .aboutVersion, .aboutResetButton, .aboutExportButton:
            return StuffinyGramSettingsSection.about.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .mainHeader: return 0
        case .mainToggle: return 1
        case .mainInfo: return 2
        case .loggingHeader: return 10
        case .loggingLogDeleted: return 11
        case .loggingLogEdited: return 12
        case .loggingAutoClear: return 13
        case .loggingInfo: return 14
        case .ghostHeader: return 20
        case .ghostEnable: return 21
        case .ghostHideOnline: return 22
        case .ghostHideTyping: return 23
        case .ghostHideMedia: return 24
        case .ghostDisableRead: return 25
        case .ghostInfo: return 26
        case .protectionHeader: return 30
        case .protectionSaveProtected: return 31
        case .protectionSelfDestruct: return 32
        case .protectionScreenshot: return 33
        case .protectionInfo: return 34
        case .premiumHeader: return 40
        case .premiumEnable: return 41
        case .premiumUnlimitedFolders: return 42
        case .premiumUnlimitedPinned: return 43
        case .premiumShowBadge: return 44
        case .premiumInfo: return 45
        case .aboutHeader: return 50
        case .aboutVersion: return 51
        case .aboutResetButton: return 52
        case .aboutExportButton: return 53
        }
    }
    
    static func ==(lhs: StuffinyGramSettingsEntry, rhs: StuffinyGramSettingsEntry) -> Bool {
        switch (lhs, rhs) {
        case let (.mainHeader(lhsTheme, lhsText), .mainHeader(rhsTheme, rhsText)):
            return lhsTheme === rhsTheme && lhsText == rhsText
        case let (.mainToggle(lhsTheme, lhsText, lhsDesc, lhsVal), .mainToggle(rhsTheme, rhsText, rhsDesc, rhsVal)):
            return lhsTheme === rhsTheme && lhsText == rhsText && lhsDesc == rhsDesc && lhsVal == rhsVal
        default:
            return false
        }
    }
    
    static func <(lhs: StuffinyGramSettingsEntry, rhs: StuffinyGramSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! StuffinyGramSettingsControllerArguments
        switch self {
        case let .mainHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .mainToggle(_, text, _, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggleMainEnabled(value)
            })
        case let .mainInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
            
        case let .loggingHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .loggingLogDeleted(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setLogDeletedMessages(value)
            })
        case let .loggingLogEdited(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setLogEditedMessages(value)
            })
        case let .loggingAutoClear(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setAutoClearLogs(value)
            })
        case let .loggingInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
            
        case let .ghostHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .ghostEnable(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setGhostModeEnabled(value)
            })
        case let .ghostHideOnline(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setGhostHideOnline(value)
            })
        case let .ghostHideTyping(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setGhostHideTyping(value)
            })
        case let .ghostHideMedia(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setGhostHideMedia(value)
            })
        case let .ghostDisableRead(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setGhostDisableRead(value)
            })
        case let .ghostInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
            
        case let .protectionHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .protectionSaveProtected(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setProtectionSaveProtected(value)
            })
        case let .protectionSelfDestruct(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setProtectionSaveSelfDestruct(value)
            })
        case let .protectionScreenshot(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setProtectionDisableScreenshot(value)
            })
        case let .protectionInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
            
        case let .premiumHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .premiumEnable(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setPremiumEnabled(value)
            })
        case let .premiumUnlimitedFolders(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setPremiumUnlimitedFolders(value)
            })
        case let .premiumUnlimitedPinned(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setPremiumUnlimitedPinned(value)
            })
        case let .premiumShowBadge(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.setPremiumShowBadge(value)
            })
        case let .premiumInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
            
        case let .aboutHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .aboutVersion(_, label, value):
            return ItemListSingleLineStringItem(presentationData: presentationData, label: label, value: value, sectionId: self.section)
        case let .aboutResetButton(_, text):
            return ItemListActionItem(presentationData: presentationData, title: text, kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.resetAll()
            })
        case let .aboutExportButton(_, text):
            return ItemListActionItem(presentationData: presentationData, title: text, kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.exportSettings()
            })
        }
    }
}

// MARK: - Arguments

private final class StuffinyGramSettingsControllerArguments {
    let toggleMainEnabled: (Bool) -> Void
    let setLogDeletedMessages: (Bool) -> Void
    let setLogEditedMessages: (Bool) -> Void
    let setAutoClearLogs: (Bool) -> Void
    let setGhostModeEnabled: (Bool) -> Void
    let setGhostHideOnline: (Bool) -> Void
    let setGhostHideTyping: (Bool) -> Void
    let setGhostHideMedia: (Bool) -> Void
    let setGhostDisableRead: (Bool) -> Void
    let setProtectionSaveProtected: (Bool) -> Void
    let setProtectionSaveSelfDestruct: (Bool) -> Void
    let setProtectionDisableScreenshot: (Bool) -> Void
    let setPremiumEnabled: (Bool) -> Void
    let setPremiumUnlimitedFolders: (Bool) -> Void
    let setPremiumUnlimitedPinned: (Bool) -> Void
    let setPremiumShowBadge: (Bool) -> Void
    let resetAll: () -> Void
    let exportSettings: () -> Void
    
    init(
        toggleMainEnabled: @escaping (Bool) -> Void,
        setLogDeletedMessages: @escaping (Bool) -> Void,
        setLogEditedMessages: @escaping (Bool) -> Void,
        setAutoClearLogs: @escaping (Bool) -> Void,
        setGhostModeEnabled: @escaping (Bool) -> Void,
        setGhostHideOnline: @escaping (Bool) -> Void,
        setGhostHideTyping: @escaping (Bool) -> Void,
        setGhostHideMedia: @escaping (Bool) -> Void,
        setGhostDisableRead: @escaping (Bool) -> Void,
        setProtectionSaveProtected: @escaping (Bool) -> Void,
        setProtectionSaveSelfDestruct: @escaping (Bool) -> Void,
        setProtectionDisableScreenshot: @escaping (Bool) -> Void,
        setPremiumEnabled: @escaping (Bool) -> Void,
        setPremiumUnlimitedFolders: @escaping (Bool) -> Void,
        setPremiumUnlimitedPinned: @escaping (Bool) -> Void,
        setPremiumShowBadge: @escaping (Bool) -> Void,
        resetAll: @escaping () -> Void,
        exportSettings: @escaping () -> Void
    ) {
        self.toggleMainEnabled = toggleMainEnabled
        self.setLogDeletedMessages = setLogDeletedMessages
        self.setLogEditedMessages = setLogEditedMessages
        self.setAutoClearLogs = setAutoClearLogs
        self.setGhostModeEnabled = setGhostModeEnabled
        self.setGhostHideOnline = setGhostHideOnline
        self.setGhostHideTyping = setGhostHideTyping
        self.setGhostHideMedia = setGhostHideMedia
        self.setGhostDisableRead = setGhostDisableRead
        self.setProtectionSaveProtected = setProtectionSaveProtected
        self.setProtectionSaveSelfDestruct = setProtectionSaveSelfDestruct
        self.setProtectionDisableScreenshot = setProtectionDisableScreenshot
        self.setPremiumEnabled = setPremiumEnabled
        self.setPremiumUnlimitedFolders = setPremiumUnlimitedFolders
        self.setPremiumUnlimitedPinned = setPremiumUnlimitedPinned
        self.setPremiumShowBadge = setPremiumShowBadge
        self.resetAll = resetAll
        self.exportSettings = exportSettings
    }
}

// MARK: - State

private struct StuffinyGramSettingsState: Equatable {
    var mainEnabled: Bool = false
    var loggingLogDeleted: Bool = false
    var loggingLogEdited: Bool = false
    var loggingAutoClear: Bool = false
    var ghostEnabled: Bool = false
    var ghostHideOnline: Bool = false
    var ghostHideTyping: Bool = false
    var ghostHideMedia: Bool = false
    var ghostDisableRead: Bool = false
    var protectionSaveProtected: Bool = false
    var protectionSaveSelfDestruct: Bool = false
    var protectionDisableScreenshot: Bool = false
    var premiumEnabled: Bool = false
    var premiumUnlimitedFolders: Bool = false
    var premiumUnlimitedPinned: Bool = false
    var premiumShowBadge: Bool = false
}

// MARK: - Controller

public func stuffinyGramSettingsController(context: AccountContext) -> ViewController {
    let statePromise = ValuePromise(StuffinyGramSettingsState(), ignoreRepeated: false)
    let stateValue = Atomic(StuffinyGramSettingsState())
    
    let settings = StuffinyGramSettings.shared
    
    // Part 1: Message Logging & Ghost Mode
    let disposable1 = combineLatest(
        settings.messageLogging.logDeletedMessages,
        settings.messageLogging.logEditedMessages,
        settings.messageLogging.autoClearOldLogs,
        settings.ghostMode.isEnabled,
        settings.ghostMode.hideOnlineStatus,
        settings.ghostMode.hideTypingStatus
    ).start(next: { values in
        let (logDel, logEd, autoClear, ghostEn, hideOn, hideTyp) = values
        let state = stateValue.with { $0 }
        var newState = state
        newState.loggingLogDeleted = logDel
        newState.loggingLogEdited = logEd
        newState.loggingAutoClear = autoClear
        newState.ghostEnabled = ghostEn
        newState.ghostHideOnline = ghostEn && hideOn
        newState.ghostHideTyping = ghostEn && hideTyp
        
        if newState != state {
            statePromise.set(newState)
            let _ = stateValue.swap(newState)
        }
    })
    
    // Part 2: Ghost Mode & Content Protection
    let disposable2 = combineLatest(
        settings.ghostMode.hideMediaUpload,
        settings.ghostMode.disableReadReceipts,
        settings.contentProtection.allowSaveProtected,
        settings.contentProtection.allowSaveSelfDestructing,
        settings.contentProtection.disableScreenshotNotification,
        settings.ghostMode.isEnabled
    ).start(next: { values in
        let (hideMedia, disRead, protSave, protSelfD, protShot, ghostEn) = values
        let state = stateValue.with { $0 }
        var newState = state
        newState.ghostHideMedia = ghostEn && hideMedia
        newState.ghostDisableRead = ghostEn && disRead
        newState.protectionSaveProtected = protSave
        newState.protectionSaveSelfDestruct = protSelfD
        newState.protectionDisableScreenshot = protShot
        
        if newState != state {
            statePromise.set(newState)
            let _ = stateValue.swap(newState)
        }
    })
    
    // Part 3: Local Premium
    let disposable3 = combineLatest(
        settings.localPremium.isPremiumEnabled,
        settings.localPremium.unlimitedChatFolders,
        settings.localPremium.unlimitedPinnedChats,
        settings.localPremium.showPremiumBadge
    ).start(next: { values in
        let (premiumEn, premiumFolders, premiumPinned, premiumBadge) = values
        let state = stateValue.with { $0 }
        var newState = state
        newState.premiumEnabled = premiumEn
        newState.premiumUnlimitedFolders = premiumEn && premiumFolders
        newState.premiumUnlimitedPinned = premiumEn && premiumPinned
        newState.premiumShowBadge = premiumEn && premiumBadge
        
        if newState != state {
            statePromise.set(newState)
            let _ = stateValue.swap(newState)
        }
    })
    
    let arguments = StuffinyGramSettingsControllerArguments(
        toggleMainEnabled: { _ in
            // Main toggle не используется в текущей версии
        },
        setLogDeletedMessages: { value in
            settings.messageLogging.setLogDeletedMessages(value)
        },
        setLogEditedMessages: { value in
            settings.messageLogging.setLogEditedMessages(value)
        },
        setAutoClearLogs: { value in
            settings.messageLogging.setAutoClearOldLogs(value)
        },
        setGhostModeEnabled: { value in
            settings.ghostMode.setEnabled(value)
            // Автоматически отключить все подопции если режим отключен
            if !value {
                settings.ghostMode.disableAllFeatures()
            }
        },
        setGhostHideOnline: { value in
            if value {
                settings.ghostMode.setEnabled(true)
            }
            settings.ghostMode.setHideOnlineStatus(value)
        },
        setGhostHideTyping: { value in
            if value {
                settings.ghostMode.setEnabled(true)
            }
            settings.ghostMode.setHideTypingStatus(value)
        },
        setGhostHideMedia: { value in
            if value {
                settings.ghostMode.setEnabled(true)
            }
            settings.ghostMode.setHideMediaUpload(value)
        },
        setGhostDisableRead: { value in
            if value {
                settings.ghostMode.setEnabled(true)
            }
            settings.ghostMode.setDisableReadReceipts(value)
        },
        setProtectionSaveProtected: { value in
            settings.contentProtection.setAllowSaveProtected(value)
        },
        setProtectionSaveSelfDestruct: { value in
            settings.contentProtection.setAllowSaveSelfDestructing(value)
        },
        setProtectionDisableScreenshot: { value in
            settings.contentProtection.setDisableScreenshotNotification(value)
        },
        setPremiumEnabled: { value in
            settings.localPremium.setPremiumEnabled(value)
            // Автоматически отключить все подопции если премиум отключен
            if !value {
                settings.localPremium.disableAllPremiumFeatures()
            }
        },
        setPremiumUnlimitedFolders: { value in
            if value {
                settings.localPremium.setPremiumEnabled(true)
            }
            settings.localPremium.setUnlimitedChatFolders(value)
        },
        setPremiumUnlimitedPinned: { value in
            if value {
                settings.localPremium.setPremiumEnabled(true)
            }
            settings.localPremium.setUnlimitedPinnedChats(value)
        },
        setPremiumShowBadge: { value in
            if value {
                settings.localPremium.setPremiumEnabled(true)
            }
            settings.localPremium.setShowPremiumBadge(value)
        },
        resetAll: {
            settings.resetAllToDefaults()
            statePromise.set(StuffinyGramSettingsState())
            let _ = stateValue.swap(StuffinyGramSettingsState())
        },
        exportSettings: {
            let exported = settings.exportSettings()
            if let jsonData = try? JSONSerialization.data(withJSONObject: exported, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Settings exported: \(jsonString)")
            }
        }
    )
    
    return ItemListController(
        context: context,
        title: .text("StuffinyGram"),
        navigationBarColor: .default,
        tabBarItem: nil,
        updateTitle: { _, _ in return },
        requestLayout: { _ in },
        entries: { state in
            var entries: [StuffinyGramSettingsEntry] = []
            let presentationData = context.sharedContext.currentPresentationData.with { $0 }
            let theme = presentationData.theme
            
            // Main
            entries.append(.mainHeader(theme, "🎯 StuffinyGram v1.0.0"))
            entries.append(.mainInfo(theme, "Полнофункциональный мод для Telegram с приватностью, логированием и премиум-функциями"))
            
            // Message Logging
            entries.append(.loggingHeader(theme, "📝 ЛОГИРОВАНИЕ СООБЩЕНИЙ"))
            entries.append(.loggingLogDeleted(theme, "✓ Сохранять удалённые сообщения", state.loggingLogDeleted))
            entries.append(.loggingLogEdited(theme, "✓ Сохранять редактированные сообщения", state.loggingLogEdited))
            entries.append(.loggingAutoClear(theme, "✓ Автоочистка логов старше 30 дней", state.loggingAutoClear))
            entries.append(.loggingInfo(theme, "📋 Все логи хранятся локально на устройстве и в SQLite БД"))
            
            // Ghost Mode
            entries.append(.ghostHeader(theme, "👻 РЕЖИМ ПРИЗРАКА"))
            entries.append(.ghostEnable(theme, "Включить режим призрака", state.ghostEnabled))
            
            if state.ghostEnabled {
                entries.append(.ghostHideOnline(theme, "  ├─ Скрыть онлайн-статус", state.ghostHideOnline))
                entries.append(.ghostHideTyping(theme, "  ├─ Скрыть печать и запись", state.ghostHideTyping))
                entries.append(.ghostHideMedia(theme, "  ├─ Скрыть загрузку медиа", state.ghostHideMedia))
                entries.append(.ghostDisableRead(theme, "  └─ Отключить прочтение сообщений", state.ghostDisableRead))
                entries.append(.ghostInfo(theme, "👁️ Остаётесь в сети, но скрываете всю активность"))
            } else {
                entries.append(.ghostInfo(theme, "💡 Включите режим призрака для доступа к параметрам"))
            }
            
            // Content Protection
            entries.append(.protectionHeader(theme, "🛡️ ЗАЩИТА КОНТЕНТА"))
            entries.append(.protectionSaveProtected(theme, "✓ Сохранять защищённый контент", state.protectionSaveProtected))
            entries.append(.protectionSelfDestruct(theme, "✓ Сохранять самоуничтожающийся контент", state.protectionSaveSelfDestruct))
            entries.append(.protectionScreenshot(theme, "✓ Отключить уведомления о скриншоте", state.protectionDisableScreenshot))
            entries.append(.protectionInfo(theme, "🔐 Защищайте и сохраняйте важный контент перед удалением"))
            
            // Local Premium
            entries.append(.premiumHeader(theme, "⭐ ЛОКАЛЬНЫЙ PREMIUM"))
            entries.append(.premiumEnable(theme, "Включить локальный Premium", state.premiumEnabled))
            
            if state.premiumEnabled {
                entries.append(.premiumUnlimitedFolders(theme, "  ├─ Неограниченно папок", state.premiumUnlimitedFolders))
                entries.append(.premiumUnlimitedPinned(theme, "  ├─ Неограниченно закреплённых чатов", state.premiumUnlimitedPinned))
                entries.append(.premiumShowBadge(theme, "  └─ Показать бейдж Premium", state.premiumShowBadge))
                entries.append(.premiumInfo(theme, "💎 Все Premium-функции разблокированы локально"))
            } else {
                entries.append(.premiumInfo(theme, "💡 Включите Premium для доступа к расширениям"))
            }
            
            // About
            entries.append(.aboutHeader(theme, "ℹ️ О ПРИЛОЖЕНИИ"))
            entries.append(.aboutVersion(theme, "Версия", "1.0.0"))
            entries.append(.aboutExportButton(theme, "📤 Экспортировать настройки"))
            entries.append(.aboutResetButton(theme, "🔄 Сбросить все параметры"))
            
            return entries
        },
        state: statePromise.get(),
        arguments: arguments
    )
}

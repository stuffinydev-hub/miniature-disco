import Foundation
import UIKit
import Display
import SwiftSignalKit
import Postbox
import TelegramCore
import TelegramPresentationData
import ItemListUI
import AccountContext

private final class GhostSettingsControllerArguments {
    let context: AccountContext
    let updateSetting: (GhostSettingKey, Bool) -> Void
    let clearDeletedLogs: () -> Void
    
    init(context: AccountContext, updateSetting: @escaping (GhostSettingKey, Bool) -> Void, clearDeletedLogs: @escaping () -> Void) {
        self.context = context
        self.updateSetting = updateSetting
        self.clearDeletedLogs = clearDeletedLogs
    }
}

private enum GhostSettingKey {
    case saveDeletedMessages
    case saveEditedMessages
    case hideOnlineStatus
    case hideTyping
    case hideRecordingVoice
    case hideRecordingVideo
    case hideUploadingMedia
    case hideStickerSelection
    case hideReactions
    case hideVoiceInGroupCall
    case hideLocationSelection
    case disableReadReceipts
    case disableStoryViews
    case saveProtectedContent
    case saveSelfDestructingContent
    case disableScreenshotNotification
    case disableBlackScreenOnScreenshot
    case disableSecretChatMessageHiding
    case unlimitedFolders
    case unlimitedPinnedChats
    case increasedChatLimits
    case showPremiumBadge
}

private enum GhostSettingsSection: Int32 {
    case logging
    case ghostMode
    case protection
    case premium
}

private enum GhostSettingsEntry: ItemListNodeEntry {
    case loggingHeader(PresentationTheme, String)
    case saveDeletedMessages(PresentationTheme, String, Bool)
    case saveEditedMessages(PresentationTheme, String, Bool)
    case clearLogsButton(PresentationTheme, String)
    case loggingInfo(PresentationTheme, String)
    
    case ghostModeHeader(PresentationTheme, String)
    case hideOnlineStatus(PresentationTheme, String, Bool)
    case hideTyping(PresentationTheme, String, Bool)
    case hideRecordingVoice(PresentationTheme, String, Bool)
    case hideRecordingVideo(PresentationTheme, String, Bool)
    case hideUploadingMedia(PresentationTheme, String, Bool)
    case hideStickerSelection(PresentationTheme, String, Bool)
    case hideReactions(PresentationTheme, String, Bool)
    case hideVoiceInGroupCall(PresentationTheme, String, Bool)
    case hideLocationSelection(PresentationTheme, String, Bool)
    case disableReadReceipts(PresentationTheme, String, Bool)
    case disableStoryViews(PresentationTheme, String, Bool)
    case ghostModeInfo(PresentationTheme, String)
    
    case protectionHeader(PresentationTheme, String)
    case saveProtectedContent(PresentationTheme, String, Bool)
    case saveSelfDestructingContent(PresentationTheme, String, Bool)
    case disableScreenshotNotification(PresentationTheme, String, Bool)
    case disableBlackScreenOnScreenshot(PresentationTheme, String, Bool)
    case disableSecretChatMessageHiding(PresentationTheme, String, Bool)
    case protectionInfo(PresentationTheme, String)
    
    case premiumHeader(PresentationTheme, String)
    case unlimitedFolders(PresentationTheme, String, Bool)
    case unlimitedPinnedChats(PresentationTheme, String, Bool)
    case increasedChatLimits(PresentationTheme, String, Bool)
    case showPremiumBadge(PresentationTheme, String, Bool)
    case premiumInfo(PresentationTheme, String)
    
    var section: ItemListSectionId {
        switch self {
        case .loggingHeader, .saveDeletedMessages, .saveEditedMessages, .clearLogsButton, .loggingInfo:
            return GhostSettingsSection.logging.rawValue
        case .ghostModeHeader, .hideOnlineStatus, .hideTyping, .hideRecordingVoice, .hideRecordingVideo,
             .hideUploadingMedia, .hideStickerSelection, .hideReactions, .hideVoiceInGroupCall,
             .hideLocationSelection, .disableReadReceipts, .disableStoryViews, .ghostModeInfo:
            return GhostSettingsSection.ghostMode.rawValue
        case .protectionHeader, .saveProtectedContent, .saveSelfDestructingContent,
             .disableScreenshotNotification, .disableBlackScreenOnScreenshot,
             .disableSecretChatMessageHiding, .protectionInfo:
            return GhostSettingsSection.protection.rawValue
        case .premiumHeader, .unlimitedFolders, .unlimitedPinnedChats, .increasedChatLimits,
             .showPremiumBadge, .premiumInfo:
            return GhostSettingsSection.premium.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .loggingHeader: return 0
        case .saveDeletedMessages: return 1
        case .saveEditedMessages: return 2
        case .clearLogsButton: return 3
        case .loggingInfo: return 4
        case .ghostModeHeader: return 100
        case .hideOnlineStatus: return 101
        case .hideTyping: return 102
        case .hideRecordingVoice: return 103
        case .hideRecordingVideo: return 104
        case .hideUploadingMedia: return 105
        case .hideStickerSelection: return 106
        case .hideReactions: return 107
        case .hideVoiceInGroupCall: return 108
        case .hideLocationSelection: return 109
        case .disableReadReceipts: return 110
        case .disableStoryViews: return 111
        case .ghostModeInfo: return 112
        case .protectionHeader: return 200
        case .saveProtectedContent: return 201
        case .saveSelfDestructingContent: return 202
        case .disableScreenshotNotification: return 203
        case .disableBlackScreenOnScreenshot: return 204
        case .disableSecretChatMessageHiding: return 205
        case .protectionInfo: return 206
        case .premiumHeader: return 300
        case .unlimitedFolders: return 301
        case .unlimitedPinnedChats: return 302
        case .increasedChatLimits: return 303
        case .showPremiumBadge: return 304
        case .premiumInfo: return 305
        }
    }
    
    static func <(lhs: GhostSettingsEntry, rhs: GhostSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! GhostSettingsControllerArguments
        switch self {
        case let .loggingHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .saveDeletedMessages(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.saveDeletedMessages, value)
            })
        case let .saveEditedMessages(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.saveEditedMessages, value)
            })
        case let .clearLogsButton(_, text):
            return ItemListActionItem(presentationData: presentationData, title: text, kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.clearDeletedLogs()
            })
        case let .loggingInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
            
        case let .ghostModeHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .hideOnlineStatus(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.hideOnlineStatus, value)
            })
        case let .hideTyping(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.hideTyping, value)
            })
        case let .hideRecordingVoice(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.hideRecordingVoice, value)
            })
        case let .hideRecordingVideo(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.hideRecordingVideo, value)
            })
        case let .hideUploadingMedia(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.hideUploadingMedia, value)
            })
        case let .hideStickerSelection(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.hideStickerSelection, value)
            })
        case let .hideReactions(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.hideReactions, value)
            })
        case let .hideVoiceInGroupCall(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.hideVoiceInGroupCall, value)
            })
        case let .hideLocationSelection(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.hideLocationSelection, value)
            })
        case let .disableReadReceipts(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.disableReadReceipts, value)
            })
        case let .disableStoryViews(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.disableStoryViews, value)
            })
        case let .ghostModeInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
            
        case let .protectionHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .saveProtectedContent(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.saveProtectedContent, value)
            })
        case let .saveSelfDestructingContent(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.saveSelfDestructingContent, value)
            })
        case let .disableScreenshotNotification(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.disableScreenshotNotification, value)
            })
        case let .disableBlackScreenOnScreenshot(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.disableBlackScreenOnScreenshot, value)
            })
        case let .disableSecretChatMessageHiding(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.disableSecretChatMessageHiding, value)
            })
        case let .protectionInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
            
        case let .premiumHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .unlimitedFolders(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.unlimitedFolders, value)
            })
        case let .unlimitedPinnedChats(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.unlimitedPinnedChats, value)
            })
        case let .increasedChatLimits(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.increasedChatLimits, value)
            })
        case let .showPremiumBadge(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSetting(.showPremiumBadge, value)
            })
        case let .premiumInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private func ghostSettingsControllerEntries(presentationData: PresentationData, settings: GhostSettings) -> [GhostSettingsEntry] {
    var entries: [GhostSettingsEntry] = []
    
    // Logging Section
    entries.append(.loggingHeader(presentationData.theme, "Логирование"))
    entries.append(.saveDeletedMessages(presentationData.theme, "Сохранять удалённые сообщения", settings.saveDeletedMessages))
    entries.append(.saveEditedMessages(presentationData.theme, "Сохранять отредактированные", settings.saveEditedMessages))
    entries.append(.clearLogsButton(presentationData.theme, "Очистить логи"))
    entries.append(.loggingInfo(presentationData.theme, "Удалённые и отредактированные сообщения будут сохраняться локально"))
    
    // Ghost Mode Section
    entries.append(.ghostModeHeader(presentationData.theme, "Режим призрака"))
    entries.append(.hideOnlineStatus(presentationData.theme, "Скрыть онлайн-статус", settings.hideOnlineStatus))
    entries.append(.hideTyping(presentationData.theme, "Скрыть печать/запись аудио", settings.hideTyping))
    entries.append(.hideRecordingVoice(presentationData.theme, "Скрыть запись голоса", settings.hideRecordingVoice))
    entries.append(.hideRecordingVideo(presentationData.theme, "Скрыть запись видео", settings.hideRecordingVideo))
    entries.append(.hideUploadingMedia(presentationData.theme, "Скрыть загрузку медиа", settings.hideUploadingMedia))
    entries.append(.hideStickerSelection(presentationData.theme, "Скрыть выбор стикеров", settings.hideStickerSelection))
    entries.append(.hideReactions(presentationData.theme, "Скрыть реакции", settings.hideReactions))
    entries.append(.hideVoiceInGroupCall(presentationData.theme, "Скрыть голос в звонке", settings.hideVoiceInGroupCall))
    entries.append(.hideLocationSelection(presentationData.theme, "Скрыть выбор локации", settings.hideLocationSelection))
    entries.append(.disableReadReceipts(presentationData.theme, "Отключить прочтение", settings.disableReadReceipts))
    entries.append(.disableStoryViews(presentationData.theme, "Отключить просмотр историй", settings.disableStoryViews))
    entries.append(.ghostModeInfo(presentationData.theme, "Ваши действия не будут видны другим пользователям"))
    
    // Protection Section
    entries.append(.protectionHeader(presentationData.theme, "Защита и ограничения"))
    entries.append(.saveProtectedContent(presentationData.theme, "Сохранять защищённый контент", settings.saveProtectedContent))
    entries.append(.saveSelfDestructingContent(presentationData.theme, "Сохранять самоуничтожающийся", settings.saveSelfDestructingContent))
    entries.append(.disableScreenshotNotification(presentationData.theme, "Отключить уведомление о скриншоте", settings.disableScreenshotNotification))
    entries.append(.disableBlackScreenOnScreenshot(presentationData.theme, "Отключить чёрный экран", settings.disableBlackScreenOnScreenshot))
    entries.append(.disableSecretChatMessageHiding(presentationData.theme, "Не скрывать секретные сообщения", settings.disableSecretChatMessageHiding))
    entries.append(.protectionInfo(presentationData.theme, "Обход ограничений на сохранение контента"))
    
    // Premium Section
    entries.append(.premiumHeader(presentationData.theme, "Локальный Premium"))
    entries.append(.unlimitedFolders(presentationData.theme, "Безлимитные папки", settings.unlimitedFolders))
    entries.append(.unlimitedPinnedChats(presentationData.theme, "Безлимитные закреплённые", settings.unlimitedPinnedChats))
    entries.append(.increasedChatLimits(presentationData.theme, "Увеличенные лимиты чатов", settings.increasedChatLimits))
    entries.append(.showPremiumBadge(presentationData.theme, "Показать бейдж Premium", settings.showPremiumBadge))
    entries.append(.premiumInfo(presentationData.theme, "Локальные функции Premium без подписки"))
    
    return entries
}

public func ghostSettingsController(context: AccountContext) -> ViewController {
    let statePromise = ValuePromise(GhostSettings.default, ignoreRepeated: true)
    let stateValue = Atomic(value: GhostSettings.default)
    let updateState: ((GhostSettings) -> GhostSettings) -> Void = { f in
        statePromise.set(stateValue.modify(f))
    }
    
    var presentControllerImpl: ((ViewController, Any?) -> Void)?
    
    let arguments = GhostSettingsControllerArguments(
        context: context,
        updateSetting: { key, value in
            let _ = (context.account.postbox.transaction { transaction -> Void in
                updateGhostSettings(transaction: transaction) { settings in
                    var settings = settings
                    switch key {
                    case .saveDeletedMessages:
                        settings.saveDeletedMessages = value
                    case .saveEditedMessages:
                        settings.saveEditedMessages = value
                    case .hideOnlineStatus:
                        settings.hideOnlineStatus = value
                    case .hideTyping:
                        settings.hideTyping = value
                    case .hideRecordingVoice:
                        settings.hideRecordingVoice = value
                    case .hideRecordingVideo:
                        settings.hideRecordingVideo = value
                    case .hideUploadingMedia:
                        settings.hideUploadingMedia = value
                    case .hideStickerSelection:
                        settings.hideStickerSelection = value
                    case .hideReactions:
                        settings.hideReactions = value
                    case .hideVoiceInGroupCall:
                        settings.hideVoiceInGroupCall = value
                    case .hideLocationSelection:
                        settings.hideLocationSelection = value
                    case .disableReadReceipts:
                        settings.disableReadReceipts = value
                    case .disableStoryViews:
                        settings.disableStoryViews = value
                    case .saveProtectedContent:
                        settings.saveProtectedContent = value
                    case .saveSelfDestructingContent:
                        settings.saveSelfDestructingContent = value
                    case .disableScreenshotNotification:
                        settings.disableScreenshotNotification = value
                    case .disableBlackScreenOnScreenshot:
                        settings.disableBlackScreenOnScreenshot = value
                    case .disableSecretChatMessageHiding:
                        settings.disableSecretChatMessageHiding = value
                    case .unlimitedFolders:
                        settings.unlimitedFolders = value
                    case .unlimitedPinnedChats:
                        settings.unlimitedPinnedChats = value
                    case .increasedChatLimits:
                        settings.increasedChatLimits = value
                    case .showPremiumBadge:
                        settings.showPremiumBadge = value
                    }
                    return settings
                }
            }).start()
        },
        clearDeletedLogs: {
            // TODO: Implement clear logs functionality
        }
    )
    
    let signal = combineLatest(
        context.sharedContext.presentationData,
        statePromise.get()
    )
    |> map { presentationData, settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("Ghost Mode"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: ghostSettingsControllerEntries(presentationData: presentationData, settings: settings),
            style: .blocks
        )
        
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    presentControllerImpl = { [weak controller] c, a in
        controller?.present(c, in: .window(.root), with: a)
    }
    
    return controller
}

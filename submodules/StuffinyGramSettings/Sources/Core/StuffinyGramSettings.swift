import Foundation
import SwiftSignalKit
import TelegramCore
import Postbox

/// Главный менеджер всех функций StuffinyGram
/// Управляет состоянием и обеспечивает доступ ко всем модулям
public final class StuffinyGramSettings {
    public static let shared = StuffinyGramSettings()
    
    // MARK: - Modules
    public let messageLogging = MessageLoggingManager.shared
    public let ghostMode = GhostModeManager.shared
    public let contentProtection = ContentProtectionManager.shared
    public let localPremium = LocalPremiumManager.shared
    public let database = StuffinyGramDatabase.shared
    
    // MARK: - General State
    private let _isEnabled = ValuePromise<Bool>(true)
    public var isEnabled: Signal<Bool, NoError> {
        return _isEnabled.get()
    }
    
    private let _appVersion = ValuePromise<String>("1.0.0")
    public var appVersion: Signal<String, NoError> {
        return _appVersion.get()
    }
    
    private init() {
        setupDefaults()
    }
    
    // MARK: - Public Methods
    
    /// Инициализация всех модулей при запуске приложения
    public func initialize() {
        messageLogging.initialize()
        ghostMode.initialize()
        contentProtection.initialize()
        localPremium.initialize()
    }
    
    /// Сброс всех настроек на значения по умолчанию
    public func resetAllToDefaults() {
        messageLogging.resetToDefaults()
        ghostMode.resetToDefaults()
        contentProtection.resetToDefaults()
        localPremium.resetToDefaults()
    }
    
    /// Экспорт всех настроек (для backup)
    public func exportSettings() -> [String: Any] {
        return [
            "messageLogging": messageLogging.exportSettings(),
            "ghostMode": ghostMode.exportSettings(),
            "contentProtection": contentProtection.exportSettings(),
            "localPremium": localPremium.exportSettings(),
            "timestamp": Date().timeIntervalSince1970
        ]
    }
    
    /// Импорт настроек из файла
    public func importSettings(_ settings: [String: Any]) {
        if let loggingSettings = settings["messageLogging"] as? [String: Any] {
            messageLogging.importSettings(loggingSettings)
        }
        if let ghostSettings = settings["ghostMode"] as? [String: Any] {
            ghostMode.importSettings(ghostSettings)
        }
        if let protectionSettings = settings["contentProtection"] as? [String: Any] {
            contentProtection.importSettings(protectionSettings)
        }
        if let premiumSettings = settings["localPremium"] as? [String: Any] {
            localPremium.importSettings(premiumSettings)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupDefaults() {
        // Инициализация значений по умолчанию из UserDefaults
        let defaults = UserDefaults(suiteName: "group.stuffinyGram") ?? UserDefaults.standard
        
        if defaults.value(forKey: "StuffinyGramInitialized") == nil {
            defaults.set(true, forKey: "StuffinyGramInitialized")
            defaults.set("1.0.0", forKey: "StuffinyGramVersion")
            defaults.synchronize()
        }
    }
}

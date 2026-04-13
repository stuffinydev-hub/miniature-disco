import Foundation
import TelegramCore

// MARK: - PeerId Extensions

extension PeerId {
    public func toInt64() -> Int64 {
        return self.id._value
    }
}

// MARK: - MessageId Extensions

extension MessageId {
    public var id: Int32 {
        return self.id
    }
}

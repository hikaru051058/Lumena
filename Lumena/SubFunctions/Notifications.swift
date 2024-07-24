//
//  Notifications.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/07.
//

import Foundation


extension Notification.Name {
    static let authStatusChanged = Notification.Name("authStatusChanged")
}

extension Notification.Name {
    static let uploadProgressUpdated = Notification.Name("uploadProgressUpdated")
}

extension Notification.Name {
    static let pauseVideoNotification = Notification.Name("pauseVideoNotification")
    static let resumeVideoNotification = Notification.Name("resumeVideoNotification")
    static let muteStatusChanged = Notification.Name("muteStatusChanged")
}

extension Notification.Name {
    static let didChangeFollowStatus = Notification.Name("didChangeFollowStatus")
}

extension Notification.Name {
    static let showSheetBrowser = Notification.Name("showSheetBrowser")
}

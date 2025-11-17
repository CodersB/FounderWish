//
//  DeviceMetadata.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

@MainActor
@available(iOS 15.0, *)
func captureDeviceMeta() async -> DeviceMeta {
    #if canImport(UIKit)
    let bundle = Bundle.main
    let appName = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
        ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
        ?? bundle.bundleIdentifier
        ?? "Unknown"

    let appVersion = (bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0"
    let osVersion = "iOS \(UIDevice.current.systemVersion)"
    let deviceModel = await getDeviceModelIdentifier()
    let deviceType = UIDevice.current.userInterfaceIdiom == .pad ? "tablet" : "phone"
    let language = Locale.current.languageCode ?? "en"
    let timezone = TimeZone.current.identifier
    
    // Screen size
    let screen = UIScreen.main.bounds
    let scale = UIScreen.main.scale
    let screenWidth = Int(screen.width * scale)
    let screenHeight = Int(screen.height * scale)
    
    // User identifier and install date
    let userID = await UserProfileManager.shared.getUserIdentifier()
    let installDate = await UserProfileManager.shared.getInstallDate()

    return DeviceMeta(
        app_name: appName,
        app_version: appVersion,
        os_version: osVersion,
        device_model: deviceModel,
        device_type: deviceType,
        lang: language,
        timezone: timezone,
        screen_w: screenWidth,
        screen_h: screenHeight,
        user_identifier: userID,
        install_date: installDate
    )
    #else
    fatalError("UIKit is required for device metadata")
    #endif
}

@MainActor
@available(iOS 15.0, *)
func getDeviceModelIdentifier() async -> String {
    #if canImport(UIKit)
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    // Detect simulator
    #if targetEnvironment(simulator)
    let deviceType = UIDevice.current.userInterfaceIdiom == .pad ? "iPad Simulator" : "iPhone Simulator"
    return "\(deviceType) (\(identifier))"
    #else
    return identifier
    #endif
    #else
    return "Unknown"
    #endif
}

// DeviceMeta needs to be accessible from FeedbackAPI
struct DeviceMeta: Codable, Sendable {
    let app_name: String
    let app_version: String
    let os_version: String
    let device_model: String
    let device_type: String
    let lang: String
    let timezone: String
    let screen_w: Int
    let screen_h: Int
    let user_identifier: String
    let install_date: Date
}


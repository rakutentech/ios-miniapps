//
//  Config.swift
//  MiniApp_Example
//
//  Created by Villa, PierreMichel on 2020/03/05.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import MiniApp

class Config: NSObject {
    enum Key: String {
        case applicationIdentifier = "RASApplicationIdentifier",
        version = "CFBundleShortVersionString",
        subscriptionKey = "RASProjectSubscriptionKey",
        endpoint = "RMAAPIEndpoint"
    }

    static let userDefaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings")

    class func getCurrent() -> MiniAppSdkConfig {
        return MiniAppSdkConfig(baseUrl: Config.userDefaults?.string(forKey: Config.Key.endpoint.rawValue),
                                         rasAppId: Config.userDefaults?.string(forKey: Config.Key.applicationIdentifier.rawValue),
                                         subscriptionKey: Config.userDefaults?.string(forKey: Config.Key.subscriptionKey.rawValue),
                                         hostAppVersion: Config.userDefaults?.string(forKey: Config.Key.version.rawValue))
    }

}

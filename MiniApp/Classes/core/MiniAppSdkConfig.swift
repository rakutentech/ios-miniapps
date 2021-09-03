import Foundation

/// MiniAppSdkConfig class helps you to configure the endpoints at runtime.
public class MiniAppSdkConfig {

    public var isPreviewMode: Bool?
    public var requireMiniAppSignatureVerification: Bool?

    public var baseUrl: String? {
        didSet {
            if baseUrl?.count ?? 0 == 0 {
                baseUrl = nil
            }
        }
    }
    public var rasProjectId: String? {
        didSet {
            if rasProjectId?.count ?? 0 == 0 {
                rasProjectId = nil
            }
        }
    }
    public var subscriptionKey: String? {
        didSet {
            if subscriptionKey?.count ?? 0 == 0 {
                subscriptionKey = nil
            }
        }
    }
    public var hostAppVersion: String? {
        didSet {
            if hostAppVersion?.count ?? 0 == 0 {
                hostAppVersion = nil
            }
        }
    }

    public var analyticsConfigList: [MAAnalyticsConfig]? {
        didSet {
            if analyticsConfigList?.count == 0 {
                analyticsConfigList = []
            }
        }
    }

    /// Initialize a MiniAppSdkConfig object that can be used to configure a MiniApp client. All the parameters are optional.
    /// If a parameter is omitted the client will fallback its value to the configuration values provided into the project configuration .plist
    ///
    /// - Parameters:
    ///   - baseUrl: The production URL of the API endpoint
    ///   - rasProjectId: The Rakuten Studio Host App Project ID
    ///   - subscriptionKey: The Rakuten Studio Subscription Key
    ///   - hostAppVersion: The Rakuten Studio Host App version
    ///   - isPreviewMode: A boolean used by MiniApp SDK to determine which endpoint to use. Default is true
    ///   - requireMiniAppSignatureVerification: A boolean used by MiniApp SDK to determine if you prevent man in the middle attack during MiniApp launch. Default is false
    public init(baseUrl: String? = nil,
                rasProjectId: String? = nil,
                subscriptionKey: String? = nil,
                hostAppVersion: String? = nil,
                isPreviewMode: Bool? = nil,
                analyticsConfigList: [MAAnalyticsConfig]? = [],
                requireMiniAppSignatureVerification: Bool? = nil) {
        self.isPreviewMode = isPreviewMode
        self.baseUrl = baseUrl?.count ?? 0 > 0 ? baseUrl : nil
        self.rasProjectId = rasProjectId?.count ?? 0 > 0 ? rasProjectId  : nil
        self.subscriptionKey = subscriptionKey?.count ?? 0 > 0 ? subscriptionKey : nil
        self.hostAppVersion = hostAppVersion?.count ?? 0 > 0 ? hostAppVersion : nil
        self.analyticsConfigList = analyticsConfigList
        self.requireMiniAppSignatureVerification = requireMiniAppSignatureVerification
    }
}

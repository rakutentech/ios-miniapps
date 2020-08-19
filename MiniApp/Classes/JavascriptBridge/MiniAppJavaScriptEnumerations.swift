enum MiniAppJSActionCommand: String {
    case getUniqueId
    case getCurrentPosition
    case requestPermission
    case requestCustomPermissions
}

enum JavaScriptExecResult: String {
    case onSuccess
    case onError
}

enum MiniAppJavaScriptError: String {
    case internalError
    case unexpectedMessageFormat
    case invalidPermissionType
}

enum MiniAppSupportedSchemes: String {
    case tel
}

public enum MiniAppPermissionType: String {
    case location
}

public enum MiniAppCustomPermissionType: String {
    case userName = "User Name"
    case profilePhoto = "Profile Photo"
    case contactsList = "Contacts List"
}

public enum MiniAppPermissionResult: Error {
    case denied
    case notDetermined
    case restricted
}

extension MiniAppPermissionResult: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .denied:
            return NSLocalizedString("Denied", comment: "Permission Error")
        case .notDetermined:
            return NSLocalizedString("NotDetermined", comment: "Permission Error")
        case .restricted:
            return NSLocalizedString("Restricted", comment: "Permission Error")
        }
    }
}

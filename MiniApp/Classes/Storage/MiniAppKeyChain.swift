import Foundation

@objc class MiniAppKeyChain: NSObject {
    let service: String
    var account: String

    typealias KeysDictionary = [String: [MASDKCustomPermissionModel]]

    init(service: String = Bundle.main.bundleIdentifier!) {
        self.service = service
        self.account = "\(service).rakuten.tech.permission.keys"
    }

    func getCustomPermissions(forMiniApp keyId: String) -> [MASDKCustomPermissionModel]? {
        guard let allKeys = keys() else {
            return nil
        }
        guard let permissionList = allKeys[keyId] as [MASDKCustomPermissionModel]? else {
            return setDefaultPermissionsInKeyChain(forMiniApp: keyId)
        }
        return permissionList
    }

    func storeCustomPermissions(permissions: [MASDKCustomPermissionModel], forMiniApp keyId: String) {
        var keysDic = keys()
        guard var cachedPermissions = self.getCustomPermissions(forMiniApp: keyId) else {
            return
        }

        _ = permissions.map { (permissionModel: MASDKCustomPermissionModel) -> MASDKCustomPermissionModel in
            if let index = cachedPermissions.firstIndex(of: permissionModel) {
                cachedPermissions[index] = permissionModel
                cachedPermissions[index].permissionDescription = ""
            }
            return permissionModel
        }

        if keysDic != nil {
            keysDic?[keyId] = cachedPermissions
        } else {
            keysDic = [keyId: cachedPermissions]
        }

        if let keys = keysDic {
            write(keys: keys)
        }
    }

    internal func setDefaultPermissionsInKeyChain(forMiniApp id: String) -> [MASDKCustomPermissionModel] {
        var supportedPermissionList = [MASDKCustomPermissionModel]()
        MiniAppCustomPermissionType.allCases.forEach {
            supportedPermissionList.append(MASDKCustomPermissionModel(
                permissionName: MiniAppCustomPermissionType(
                    rawValue: $0.rawValue)!,
                isPermissionGranted: .denied,
                permissionRequestDescription: ""
            ))
        }
        write(keys: [id: supportedPermissionList])
        return supportedPermissionList
    }

    private func write(keys: KeysDictionary) {
        guard let data = try? JSONEncoder().encode(keys) else {
            return
        }

        let queryFind: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let update: [String: Any] = [
            kSecValueData as String: data
        ]

        var status = SecItemUpdate(queryFind as CFDictionary, update as CFDictionary)

        if status == errSecItemNotFound {
            let queryAdd: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            ]
            status = SecItemAdd(queryAdd as CFDictionary, nil)
        }

        if status != errSecSuccess {
            var error: String?
            if #available(iOS 11.3, *) {
                error = SecCopyErrorMessageString(status, nil) as String?
            } else {
                error = "OSStatus \(status)"
            }
            print("KeyStore write error \(String(describing: error))")
        }
    }

    private func keys() -> KeysDictionary? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let objectData = result as? Data else {
            return nil
        }

        guard let keys = ResponseDecoder.decode(decodeType: KeysDictionary.self, data: objectData) else {
            return nil
        }

        return keys
    }
}

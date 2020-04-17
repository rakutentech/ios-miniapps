/// Model for a Mini App information
public struct MiniAppInfo: Decodable {
    /// Unique identifier of a Miniapp
    internal var id: String
    /// Name given for a Miniapp that will be displayed on the list
    public var displayName: String?
    /// App Icon associated for the Miniapp
    public var icon: URL
    /// Version information of a Miniapp
    public var version: Version

    private enum CodingKeys: String, CodingKey {
        case id,
        displayName,
        icon,
        version
    }
}

/// Miniapp version information
public struct Version: Decodable {
    /// Custom Tag name associated for every Miniapp which was given while uploading it in the platform
    public var versionTag: String
    /// Version number associated for every Miniapp which was given while uploading it in the platform
    public var versionId: String

    private enum CodingKeys: String, CodingKey {
        case versionTag,
        versionId
    }
}

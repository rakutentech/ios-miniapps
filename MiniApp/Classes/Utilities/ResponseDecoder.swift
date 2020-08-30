struct ResponseEncoder {
    static func encode<T: Codable>(data: T) -> Data? {
        do {
            return try JSONEncoder().encode(data)
        } catch {
            MiniAppLogger.e("Encoding Failed", error)
            return nil
        }
    }
}

struct ResponseDecoder {
    static func decode<T: Decodable>(decodeType: T.Type, data: Data) -> T? {
        do {
            return try JSONDecoder().decode(decodeType, from: data)
        } catch let error {
            MiniAppLogger.e("Decoding Failed", error)
            return nil
        }
    }
}

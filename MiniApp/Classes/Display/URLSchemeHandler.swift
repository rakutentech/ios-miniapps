import WebKit

/// This class helps to handle Custom URL schemes that is Registered in MiniAppWebView class
class URLSchemeHandler: NSObject, WKURLSchemeHandler {

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {

        if urlSchemeTask.request.url != nil {
            do {
                guard let scheme = webView.url?.scheme else {
                    return
                }
                let miniAppId = getAppIdFromScheme(scheme: scheme)
                let relativeFilePath = getFileName(url: urlSchemeTask.request.url)
                guard let miniAppFilePath = getFilePath(relativeFilePath: relativeFilePath, appId: miniAppId) else {
                    return
                }
                let data = try Data(contentsOf: miniAppFilePath)
                urlSchemeTask.didReceive(URLResponse(url: urlSchemeTask.request.url!, mimeType: "text/html", expectedContentLength: data.count, textEncodingName: nil))
                urlSchemeTask.didReceive(data)
                urlSchemeTask.didFinish()
            } catch let error as NSError {
                print("Error: ", error)
            }
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }

    /// Returns Mini app id from a given scheme
    ///
    /// For eg., If mscheme.MINI_APP_ID is the scheme, this method returns only MINI_APP_ID
    /// - Parameter scheme: Scheme that is requested to load in the WebView instance
    func getAppIdFromScheme(scheme: String) -> String {
        return scheme.replacingOccurrences(of: Constants.miniAppSchemePrefix, with: "")
    }

    /// Returns file name from the given URL
    /// - Parameter url: URL
    func getFileName(url: URL?) -> String {
        /*
         Only for the first request i.e initial load request from WebView, url.path
         will be empty
         */
        guard let fileName = url?.path, !fileName.isEmpty else {
            return Constants.rootFileName
        }
        return fileName.deletingPrefix("/")
    }

    /// Method to get the absolute file path using relative file path and appID
    /// - Parameters:
    ///   - relativeFilePath: Relative file path for a request URL
    ///   - appId: Mini app ID
    func getFilePath(relativeFilePath: String, appId: String) -> URL? {
        guard let miniAppPath = FileManager.getMiniAppVersionDirectory(usingAppId: appId) else {
            return nil
        }
        return miniAppPath.appendingPathComponent(relativeFilePath)
    }
}

import Foundation
import UniformTypeIdentifiers
import AsyncHTTPClient

struct File : Codable {
    private static let _apiUrl = "https://api.openai.com/v1/files"
    private static let _purpose = "assistants"
    private static let _cache = Cache.shared
    
    let id: String
    let url: URL
    let name: String
    let mimeType: String
    
    init(id: String, url: URL, name: String, mimeType: String) {
        self.id = id
        self.url = url
        self.name = name
        self.mimeType = mimeType
    }
    
    init(path: String, httpClient: HTTPClient, auth: String) throws {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
            throw FileError.creationFailed("File not found!")
        }
        guard !isDirectory.boolValue else {
            throw FileError.creationFailed("Path provided is for a directory!")
        }
        
        let fileURL = URL(filePath: path)
        if let cachedFile = File._cache.readFile(absolutePath: fileURL.absoluteString) {
            self = cachedFile
        } else {
            let fileMimeType = UTType(filenameExtension: fileURL.pathExtension)?.preferredMIMEType ?? "text/plain"
            
            var requestBody = Data()
            let boundary = "Boundary-\(UUID().uuidString)"
            requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            requestBody.append("Content-Disposition: form-data; name=\"purpose\"\r\n\r\n".data(using: .utf8)!)
            requestBody.append("\(File._purpose)\r\n".data(using: .utf8)!)
            requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            requestBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.absoluteString)\"\r\n".data(using: .utf8)!)
            requestBody.append("Content-Type: \(fileMimeType)\r\n\r\n".data(using: .utf8)!)
            requestBody.append(try! Data(contentsOf: fileURL))
            requestBody.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            let request = try! HTTPClient.Request(
                url: File._apiUrl,
                method: .POST,
                headers: [
                    "Authorization": auth,
                    "Content-Type": "multipart/form-data; boundary=\(boundary)"
                ],
                body: HTTPClient.Body.data(requestBody)
            )
            
            let response = try? httpClient.execute(request: request).wait()
            guard response?.status == .ok,
                  let responseBody = response?.body,
                  let jsonObject = try? JSONSerialization.jsonObject(with: responseBody) as? [String: Any],
                  let fileId = jsonObject["id"] as? String else {
                throw FileError.uploadFailed("Failed to upload file to OpenAI servers!")
            }
            
            self.id = fileId
            self.url = fileURL
            self.name = fileURL.lastPathComponent
            self.mimeType = fileMimeType
            
            guard File._cache.add(file: self) else {
                throw FileError.cashSyncFailed("File uploaded but cache sync failed!")
            }
        }
    }
    
    func delete(httpClient: HTTPClient, auth: String) throws {
        let request = try! HTTPClient.Request(
            url: File._apiUrl.appending("/\(self.id)"),
            method: .DELETE,
            headers: ["Authorization": auth]
        )
        let response = try? httpClient.execute(request: request).wait()
        guard response?.status == .ok,
              let responseBody = response?.body,
              let jsonObject = try? JSONSerialization.jsonObject(with: responseBody) as? [String: Any],
              let deleted = jsonObject["deleted"] as? Bool,
              deleted else {
            print(response!.status)
            print(String(buffer: response!.body!))
            throw FileError.deleteFailed("Failed to delete the file [\(self.url.absoluteString)].")
        }
        
        guard File._cache.remove(file: self) else {
            throw FileError.cashSyncFailed("Failed to sync cache with file removal!")
        }
    }
    
    static func list() -> [File] {
        return File._cache.listFiles()
    }
    
    static func get(path: String) -> File? {
        return File._cache.readFile(absolutePath: URL(filePath: path).absoluteString)
    }
    
    enum FileError: Error {
        case creationFailed(String)
        case uploadFailed(String)
        case deleteFailed(String)
        case cashSyncFailed(String)
    }
}

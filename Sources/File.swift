import Foundation
import UniformTypeIdentifiers
import AsyncHTTPClient

struct File {
    private static let _apiUrl = "https://api.openai.com/v1/files"
    private static let _purpose = "assistants"
    
    private let id: String
    private let url: URL
    private let name: String
    private let mimeType: String
    
    init(path: String, httpClient: HTTPClient, auth: String) throws {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
            throw FileError.uploadFailed("File not found!")
        }
        guard !isDirectory.boolValue else {
            throw FileError.uploadFailed("Path provided is for a directory!")
        }
        
        // TODO: verify if file exists in DB
        // if it does not: create it
        
        self.url = URL(filePath: path)
        self.name = self.url.lastPathComponent
        self.mimeType = UTType(filenameExtension: self.url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        
        var requestBody = Data()
        let boundary = "Boundary-\(UUID().uuidString)"
        requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"purpose\"\r\n\r\n".data(using: .utf8)!)
        requestBody.append("\(File._purpose)\r\n".data(using: .utf8)!)
        requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(self.name)\"\r\n".data(using: .utf8)!)
        requestBody.append("Content-Type: \(self.mimeType)\r\n\r\n".data(using: .utf8)!)
        requestBody.append(try! Data(contentsOf: self.url))
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
              let jsonObject = try? JSONSerialization.jsonObject(with: responseBody, options: []) as? [String: Any],
              let fileId = jsonObject["id"] as? String else {
            throw FileError.uploadFailed("Failed to upload file to OpenAI servers!")
        }
        
        self.id = fileId
        
        // TODO: add file to db
    }
    
    func delete(httpClient: HTTPClient, auth: String) throws {
        let request = try! HTTPClient.Request(
            url: File._apiUrl.appending(self.id),
            method: .DELETE,
            headers: ["Authorization": auth]
        )
        let response = try! httpClient.execute(request: request).wait()
        guard response.status == .noContent else {
            throw FileError.deleteFailed("Failed to delete the file. Status: \(response.status)")
        }
    }
    
    enum FileError: Error {
        case uploadFailed(String)
        case deleteFailed(String)
    }
}

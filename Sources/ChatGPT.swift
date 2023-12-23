import Foundation
import UniformTypeIdentifiers
import AsyncHTTPClient
import NIOHTTP1

class ChatGPT {
    private static let _apiKey = ProcessInfo.processInfo.environment["HEY_OPENAI"]
    private static let _chatUrl = "https://api.openai.com/v1/chat/completions"
    private static let _model = "gpt-3.5-turbo"
    private static let _temperature = 1
    private static let _auth = ("Authorization", "Bearer " + (ChatGPT._apiKey ?? ""))
    
    private let httpClient: HTTPClient
    
    init() {
        httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        testAgentAvailability()
    }
    
    deinit {
        try! httpClient.syncShutdown()
    }
    
    private func testAgentAvailability() {
        let request = try! HTTPClient.Request(
            url: "https://api.openai.com/v1/models",
            method: .GET,
            headers: HTTPHeaders([ChatGPT._auth])
        )
        
        let responseFuture = httpClient.execute(request: request)
        responseFuture.whenComplete { result in
            switch result {
                case .failure:
                    print("Client seems to have failed to connect to OpenAI servers.")
                case .success(let response):
                    if response.status == .ok, let body = response.body {
                        print("SUCCESS -- \(String(buffer: body))")
                    } else {
                        print("OpenAI servers seem to have returned an error: \(response.status)")
                    }
            }
        }
        
        _ = try! responseFuture.wait()
    }
    
    private struct Assistant {
        private let model: String
        private let name: String
        private let desription: String
        private let instructions: String
        private let tools: [String]
        private let files: [File]
    }
    
    private class File {
        private static let _apiUrl = "https://api.openai.com/v1/files"
        private static let _purpose = "code-interpreter"
        
        private let id: String
        private let url: URL
        private let name: String
        private let mimeType: String
        
        init(httpClient: HTTPClient, url: URL) {
            self.url = url
            self.name = url.lastPathComponent
            self.mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            let requestBody = """
                --\(boundary)\r\n\
                Content-Disposition: form-data; name="purpose"\r\n\r\n\
                \(File._purpose)\r\n\
                --\(boundary)\r\n\
                Content-Disposition: form-data; name="file"; filename="\(self.name)"\r\n\
                Content-Type: \(self.mimeType)\r\n\r\n
            """.data(using: .utf8)!
            let fileData = try! Data(contentsOf: url)
            let endData = "\r\n--\(boundary)--\r\n".data(using: .utf8)!
            
            let request = try! HTTPClient.Request(
                url: File._apiUrl,
                method: .POST,
                headers: HTTPHeaders([
                    ChatGPT._auth,
                    ("Content-Type", "multipart/form-data; boundary=\(boundary)")
                ]),
                body: HTTPClient.Body.data(requestBody + fileData + endData)
            )
            
            let response = try? httpClient.execute(request: request).wait()
            
            guard response?.status == .ok,
                  let responseBody = response?.body,
                  let jsonObject = try? JSONSerialization.jsonObject(with: responseBody, options: []) as? [String: Any],
                  let fileId = jsonObject["id"] as? String else {
                fatalError("Failed to upload file to OpenAI servers!")
            }
            
            self.id = fileId
        }
        
        func delete(httpClient: HTTPClient) {
            let request = try! HTTPClient.Request(
                url: File._apiUrl.appending(self.id),
                method: .DELETE,
                headers: HTTPHeaders([ChatGPT._auth])
            )
            let response = try! httpClient.execute(request: request).wait()
            guard response.status == .noContent else {
                fatalError("Failed to delete the file. Status: \(response.status)")
            }
        }
    }
}

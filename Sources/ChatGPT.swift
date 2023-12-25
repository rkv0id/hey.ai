import Foundation
import AsyncHTTPClient

class ChatGPT {
    private static let _apiKey = ProcessInfo.processInfo.environment["HEY_OPENAI"]
    private static let _chatUrl = "https://api.openai.com/v1/chat/completions"
    private static let _model = "gpt-3.5-turbo"
    private static let _temperature = 1
    private static let _auth = "Bearer " + (ChatGPT._apiKey ?? "")
    
    private let httpClient: HTTPClient
    
    init() {
        httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
//        testAgentAvailability()
    }
    
    deinit {
        try! httpClient.syncShutdown()
    }
    
    func uploadFile(path: String) {
        _ = try! File(path: path, httpClient: self.httpClient, auth: ChatGPT._auth)
    }
    
    private func testAgentAvailability() {
        let request = try! HTTPClient.Request(
            url: "https://api.openai.com/v1/models",
            method: .GET,
            headers: ["Authorization": ChatGPT._auth]
        )
        
        let responseFuture = httpClient.execute(request: request)
        responseFuture.whenComplete { result in
            switch result {
                case .failure:
                    print("Client seems to have failed to connect to OpenAI servers.")
                case .success(let response):
                    if response.status == .ok {
                        print("SUCCESS -- Connected to OpenAI servers.")
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
}

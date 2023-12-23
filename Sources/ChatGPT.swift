import AsyncHTTPClient
import Foundation
import NIOHTTP1

class ChatGPT {
  private static let _apiKey = ProcessInfo.processInfo.environment["HEY_OPENAI"]
  private static let _chatUrl = "https://api.openai.com/v1/chat/completions"
  private static let _model = "gpt-3.5-turbo"
  private static let _temperature = 1

  private let httpClient: HTTPClient

  init() {
    httpClient = Hey.createHTTPClient()
    testAgentAvailability()
  }

  deinit {
    try! httpClient.syncShutdown()
  }

  private func testAgentAvailability() {
    let request = try! HTTPClient.Request(
      url: "https://api.openai.com/v1/models",
      method: .GET,
      headers: HTTPHeaders([("Authorization", "Bearer " + (ChatGPT._apiKey ?? ""))])
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
}

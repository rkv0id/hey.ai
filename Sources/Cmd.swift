import ArgumentParser
import AsyncHTTPClient
import NIOHTTP1

extension Hey {
    struct Cmd: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "cmd",
            abstract: "Write ad-hoc commands."
        )
        
        @OptionGroup var args: CodeArgs
        
        mutating func run() throws {
            let httpClient = Hey.createHTTPClient()
            defer { try! httpClient.syncShutdown() }
            
            let verbose = args.verbose ? "" : "non-"
            
            let bodyString = "{\"Cmd[\(verbose + "verbose")]\": \"with prompt[\(args.prompt.joined(separator: " "))]\"}"
            let request = try HTTPClient.Request(
                url: "https://webhook.site/672f9dd2-070c-44a2-9886-89e971f74e2e",
                method: .POST,
                headers: HTTPHeaders([("User-Agent", "Hey CLI-Assistant")]),
                body: HTTPClient.Body.data(bodyString.data(using: .utf8)!)
            )
            
            let responseFuture = httpClient.execute(request: request)
            responseFuture.whenComplete { result in
                switch result {
                    case .failure(let error):
                        print("Client seems to have failed: \(error)")
                    case .success(let response):
                        if response.status == .ok, let body = response.body {
                            print("SUCCESS -- \(String(buffer: body))")
                        } else {
                            print("Server seems to have failed iternally -- Error code: \(response.status)")
                        }
                }
            }
            
            print("Cmd[\(verbose + "verbose")]: with prompt[\(args.prompt.joined(separator: " "))]")
            _ = try! responseFuture.wait()
        }
    }
}

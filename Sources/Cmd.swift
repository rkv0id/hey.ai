import ArgumentParser
import AsyncHTTPClient
import NIOHTTP1

extension Hey {
    struct Cmd: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "cmd",
            abstract: "Write ad-hoc commands."
        )
        
        @Option(name: [.long, .short], help: "Helper files to prompt as context for the assistant.")
        var context: [String] = []
        
        @Argument(help: "The input prompt (request) for the acting agent.")
        var prompt: [String]
        
        mutating func run() throws {
            let assistant = ChatGPT()
        }
    }
}

import ArgumentParser

extension Hey {
    struct Cmd: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "cmd",
            abstract: "Write ad-hoc commands."
        )
        
        @Argument(help: "The input prompt (request) for the acting agent.")
        var prompt: [String]
        
        mutating func run() throws {
            print(prompt)
        }
    }
}

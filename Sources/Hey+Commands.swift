import ArgumentParser
import AsyncHTTPClient

@main
struct Hey: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "hey",
        abstract: "An AI-powered terminal assistant.",
        version: "0.0.1",
        subcommands: [Cmd.self, Script.self, Summarize.self, Verbosify.self],
        defaultSubcommand: Cmd.self
    )
    
    struct Script: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "script",
            abstract: "Write ad-hoc multi-lingual scripts."
        )
        
        @Option(name: [.customLong("in")], help: "The target scripting/programming language.")
        var lang: String = "bash"  // replace with hey init conf file option or with system default shell
        
        @Option(name: [.long, .short], help: "Helper files to prompt as context for the assistant.")
        var context: [String] = []
        
        @Argument(help: "The input prompt (request) for the acting agent.")
        var prompt: [String]
        
        mutating func run() throws {
            let context =
            if self.context.isEmpty { "empty" } else { self.context.joined(separator: ", ") }
            print(
                "Script: In \(self.lang) with context[\(context)] \(prompt.joined(separator: " "))"
            )
        }
    }
    
    struct Summarize: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "summarize",
            abstract: "Summarize and explain multi-lingual code and commands."
        )
        
        @Argument(help: "The code/script file(s) to explain.")
        var files: [String]
        
        func run() throws {
            print("Summarize: [\n\t\(files.joined(separator: ",\n\t"))\n]")
        }
    }
    
    struct Verbosify: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "verbosify",
            abstract: "Verbosify and beautify (execution of) commands and code."
        )
        
        @Argument(help: "The code/script file to augment.")
        var file: String
        
        @Flag(name: [.long, .short], help: "Run the verbose code generated instead of printing it.")
        var eval = false
        
        mutating func run() throws {
            print("Verbosify: \(file)")
        }
    }
}

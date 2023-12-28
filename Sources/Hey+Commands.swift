import ArgumentParser

@main
struct Hey: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "hey",
        abstract: "An AI-powered terminal assistant.",
        version: "0.0.1",
        subcommands: [Cmd.self, Script.self, Summarize.self, Verbosify.self, Context.self],
        defaultSubcommand: Cmd.self
    )
    
    struct Script: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "script",
            abstract: "Write ad-hoc scripts."
        )
        
        @Option(name: .customLong("in"), help: "The target scripting/programming language.")
        var lang: String = "bash"  // replace with hey init conf file option or with system default shell
        
        @Argument(help: "The input prompt (request) for the acting agent.")
        var prompt: [String]
        
        mutating func run() throws {
            print(
                "Script: In \(self.lang) \(prompt.joined(separator: " "))"
            )
        }
    }
    
    struct Summarize: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "summarize",
            abstract: "Summarize and explain multi-lingual code and commands."
        )
        
        @Argument(help: "The code/script file(s) to explain.")
        // TODO: can support folders
        var file: [String]
        
        func run() throws {
            print("Summarize: [\n\t\(file.joined(separator: ",\n\t"))\n]")
        }
    }
    
    struct Verbosify: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "verbosify",
            abstract: "Verbosify and beautify (execution of) commands and code."
        )
        
        @Argument(help: "The code/script file to augment.")
        var file: String
        
        @Flag(name: .shortAndLong, help: "Run the verbose code generated instead of printing it.")
        var eval = false
        
        mutating func run() throws {
            print("Verbosify: \(file)")
        }
    }
}

import ArgumentParser

struct Context: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "context",
        abstract: "Manage contexts for hey sessions.",
        subcommands: [Describe.self, Files.self]
    )
    
    func run() throws {
        // TODO: list all contexts
        print("listing contexts...")
    }
    
    struct New: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "new",
            abstract: "Create and activate a new context."
        )
        
        @Option(name: .long, help: "Custom description for the new context.")
        var describe = ""
        
        func run() throws {
            print("Creating a new context [description: \(describe)]...")
        }
    }
    
    struct Describe: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "describe",
            abstract: "Assign a description to set context."
        )
        
        @Argument(help: "The description to assign to the active context for a better explainability.")
        var description: String
        
        func run() throws {
            print("Setting this \(description)...")
        }
    }
    
    struct Files: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "files",
            abstract: "Manage files for set context."
        )
        
        @OptionGroup
        var context: Context
        
        @Flag(name: .shortAndLong, help: "Delete files for the list of provided ids from set context.")
        var delete = false
        
        @Argument(help: "The list of files to load or ids of files to [--delete] from set context.")
        var files: [String] = []
        
        func run() throws {
            let openAI = OpenAI()
            if delete {
                try files.forEach { try openAI.deleteFile(path: $0) }
            } else if !files.isEmpty {
                try files.forEach { try openAI.uploadFile(path: $0) }
            } else {
                openAI.listFiles().forEach { print("\($0.url.absoluteString) --> \($0)") }
            }
        }
    }
}

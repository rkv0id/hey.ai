import ArgumentParser

struct Context: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "context",
        abstract: "Manage contexts for hey sessions.",
        subcommands: [Files.self]
    )
    
    func run() throws {
        // TODO: list all contexts
        print("listing contexts")
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
    
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "list",
            abstract: "List all available contexts."
        )
        
        func run() throws {
            // TODO: list all contexts
        }
    }
}

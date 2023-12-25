import ArgumentParser

struct Context: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "context",
        abstract: "Manage contexts for hey sessions.",
        subcommands: [Files.self]
    )
    
    struct Files: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "files",
            abstract: "Manage files for set context."
        )
        
        @Flag(name: [.long, .short], help: "Delete files for the list of provided ids from set context.")
        var delete = false
        
        @Argument(help: "The list of files to load or ids of files to [--delete] from set context.")
        var files: [String] = []
        
        mutating func run() throws {
            if files.isEmpty {
                // TODO: List
                print("Listing")
            } else {
                let openAI = ChatGPT()
                if delete {
                    // TODO: Delete
                    print("Deleting")
                } else {
                    print("Uploading")
                    // TODO: Filter out files already linked
                    files.forEach { openAI.uploadFile(path: $0) }
                    // TODO: Link File in DB and to online assistant
                }
            }
        }
    }
}

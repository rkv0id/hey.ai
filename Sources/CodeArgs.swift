import ArgumentParser

struct CodeArgs: ParsableArguments {
    @Flag(name: [.long, .short], help: "Elaborate on the result and provide explicit explanation.")
    var verbose = false
    
    @Flag(name: [.long, .short], help: "Gather needed prompt-specific context.")
    var context = false
    
    @Option(name: [.long, .short], help: "Timeout (in seconds) for context collection.")
    var timeout = 1
    
    @Option(name: [.long, .short], help: "Helper files to prompt as context for the assistant.")
    var files: [String] = []
    
    @Argument(help: "The input prompt (request) for the acting agent.")
    var prompt: [String]
}


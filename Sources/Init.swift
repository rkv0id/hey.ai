import ArgumentParser

struct Init: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initiate (and reset) system-wide context awareness."
    )
    
    mutating func run() throws {
        print("Initiating.")
        // TODO:
        // in db: updates a flag table to mention which context has
        // been collected so that other sub-commands become aware of
        // which context tables might fail and for which raise an error
        // when failing to collect their attributes.
        
        // also find a way to interact with Hey s flag to force use of
        // context (which means fail when system context fails) or not
        // when forced to use system context, all commands would fail
        // also when there is no context used. Maybe also advise user
        // to reset or inititate context before usage.
        
        // also please review all arguments names.
    }
}


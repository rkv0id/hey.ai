import Foundation
import ArgumentParser

struct There: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "there",
        abstract: "Initiate (and reset) system-wide context awareness."
    )
    
    mutating func run() throws {
        print("> Initiating assistant...")
        
        let cache = Cache()
        let context = Context().withBinaries()
        cache.sync(context: context)
        
        print("> Context Reset Complete!\nAssistant online and at service.")
        
        // TODO:
        // in db: updates a flag table to mention which context has
        // been collected so that other sub-commands become aware of
        // which context tables might fail and for which raise an error
        // when failing to collect their attributes.
        
        // also interact with the general context and notify the user on
        // output that context has not been updated for a while (if last
        // timestamp is too old). Also update some keys on demand (like
        // pwd for ex) as response usually depends on those.
        
        // also please review all arguments names.
    }
}


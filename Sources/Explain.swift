import ArgumentParser

struct Explain: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "explain",
        abstract: "Explain multi-lingual code and commands."
    )
}
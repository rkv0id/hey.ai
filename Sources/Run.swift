import ArgumentParser

struct Run: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Run, verbosify and beautify (execution of) commands and code."
    )
}
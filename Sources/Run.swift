import ArgumentParser

extension Hey {
  struct Run: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "run",
      abstract: "Run, verbosify and beautify (execution of) commands and code."
    )

    @Option(help: "The command/script to run.")
    var code: [String]

    mutating func run() throws {
      print("Run: \(code.joined(separator: " "))")
    }
  }
}

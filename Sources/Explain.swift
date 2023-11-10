import ArgumentParser

extension Hey {
  struct Explain: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "explain",
      abstract: "Explain multi-lingual code and commands."
    )

    @Option(help: "The command/script to explain.")
    var code: [String]

    func run() throws {
      print("Explain: \(code.joined(separator: " "))")
    }
  }
}

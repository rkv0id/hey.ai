import ArgumentParser

extension Hey {
  struct There: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "there",
      abstract: "Prompts the assistant in an ad-hoc way.",
      shouldDisplay: false
    )

    @Argument(help: "The input prompt (request) for the acting agent.")
    var prompt: [String]

    func run() throws {
      print("There there: \(prompt.joined(separator: " "))")
    }
  }
}
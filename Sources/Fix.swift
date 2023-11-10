import ArgumentParser

extension Hey {
  struct Fix: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "fix",
      abstract: "Proof-check commands and scripts (syntaxically/semantically)."
    )

    @OptionGroup var args:CodeArgs

    mutating func run() throws {
      let elaborate = if !self.args.elaborate { "Non-" } else { "" }
      print("Fix[\(elaborate + "Elaborate")]: \(args.prompt.joined(separator: " "))")
    }
  }
}
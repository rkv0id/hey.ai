import ArgumentParser

extension Hey {
  struct Code: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "code",
      abstract: "Write ad-hoc multi-lingual code."
    )

    @Argument(help: "The target programming language.")
    var lang: String

    @OptionGroup var args:CodeArgs

    mutating func run() throws {
      let elaborate = if !self.args.elaborate { "Non-" } else { "" }
      print(
        "Code[\(elaborate + "Elaborate")]: In \(self.lang) \(args.prompt.joined(separator: " "))")
    }
  }
}
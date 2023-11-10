import ArgumentParser

extension Hey {
  struct Cmd: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "cmd",
      abstract: "Write ad-hoc commands."
    )

    @OptionGroup var args: CodeArgs

    mutating func run() throws {
      let elaborate = if !self.args.elaborate { "Non-" } else { "" }
      print("Cmd[\(elaborate + "Elaborate")]: \(args.prompt.joined(separator: " "))")
    }
  }
}
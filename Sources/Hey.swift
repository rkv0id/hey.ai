import ArgumentParser

@main
struct Hey: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "hey",
    abstract: "An AI-powered assistant.",
    version: "0.0.1",
    subcommands: [Cmd.self, Code.self, Fix.self, Run.self, Explain.self],
    defaultSubcommand: There.self
  )
}

struct CodeArgs: ParsableArguments {
  @Flag(name: [.long, .short], help: "Elaborate on the result and provide explicit explanation.")
  var elaborate = false

  @Argument(help: "The input prompt (request) for the acting agent.")
  var prompt: [String]
}

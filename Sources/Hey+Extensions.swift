import ArgumentParser

@main
struct Hey: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "hey",
    abstract: "An AI-powered assistant.",
    version: "0.0.1",
    subcommands: [Cmd.self, Code.self, Fix.self, There.self],
    defaultSubcommand: There.self
  )
}

struct CodeArgs: ParsableArguments {
  @Flag(name: [.long, .short], help: "Elaborate on the result and provide explicit explanation.")
  var elaborate = false

  @Argument(help: "The input prompt (request) for the acting agent.")
  var prompt: [String]
}

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

  struct Cmd: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "cmd",
      abstract: "Write ad-hoc commands."
    )

    @OptionGroup var args:CodeArgs

    mutating func run() throws {
      let elaborate = if !self.args.elaborate { "Non-" } else { "" }
      print("Cmd[\(elaborate + "Elaborate")]: \(args.prompt.joined(separator: " "))")
    }
  }

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

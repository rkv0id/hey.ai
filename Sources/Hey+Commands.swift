import ArgumentParser

@main
struct Hey: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "hey",
    abstract: "An AI-powered terminal assistant.",
    version: "0.0.1",
    subcommands: [Cmd.self, Script.self, Summarize.self, Verbosify.self],
    defaultSubcommand: Cmd.self
  )
}

struct CodeArgs: ParsableArguments {
  @Flag(name: [.long, .short], help: "Elaborate on the result and provide explicit explanation.")
  var verbose = false

  @Option(name: [.long, .short], help: "Helper files to prompt as context for the assistant.")
  var context: [String]

  @Argument(help: "The input prompt (request) for the acting agent.")
  var prompt: [String]
}

extension Hey {
  struct Cmd: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "cmd",
      abstract: "Write ad-hoc commands."
    )

    @OptionGroup var args: CodeArgs

    mutating func run() throws {
      let verbose = if !self.args.verbose { "non-" } else { "" }
      print("Cmd[\(verbose + "verbose")]: \(args.prompt.joined(separator: " "))")
    }
  }

  struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "script",
      abstract: "Write ad-hoc multi-lingual scripts."
    )

    @Argument(help: "The target scripting/programming language.")
    var lang: String

    @OptionGroup var args:CodeArgs

    mutating func run() throws {
      let verbose = if !self.args.verbose { "non-" } else { "" }
      print(
        "Script[\(verbose + "verbose")]: In \(self.lang) \(args.prompt.joined(separator: " "))")
    }
  }

  struct Summarize: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "summarize",
      abstract: "Summarize and explain multi-lingual code and commands."
    )

    @Argument(help: "The code/script file to explain.")
    var file: String

    func run() throws {
      print("Summarize: \(file)")
    }
  }

  struct Verbosify: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "verbosify",
      abstract: "Verbosify and beautify (execution of) commands and code."
    )

    @Argument(help: "The code/script file to augment.")
    var file: String

    mutating func run() throws {
      print("Verbosify: \(file))")
    }
  }
}
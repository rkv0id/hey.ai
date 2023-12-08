import ArgumentParser
import AsyncHTTPClient
import NIOHTTP1

struct CodeArgs: ParsableArguments {
  @Flag(name: [.long, .short], help: "Elaborate on the result and provide explicit explanation.")
  var verbose = false

  @Option(name: [.long, .short], help: "Helper files to prompt as context for the assistant.")
  var context: [String] = []

  @Argument(help: "The input prompt (request) for the acting agent.")
  var prompt: [String]
}

@main
struct Hey: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "hey",
    abstract: "An AI-powered terminal assistant.",
    version: "0.0.1",
    subcommands: [Cmd.self, Script.self, Summarize.self, Verbosify.self],
    defaultSubcommand: Cmd.self
  )

  static func createHTTPClient() -> HTTPClient {
    return HTTPClient(eventLoopGroupProvider: .singleton)
  }

  struct Cmd: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "cmd",
      abstract: "Write ad-hoc commands."
    )

    @OptionGroup var args: CodeArgs

    mutating func run() throws {
      let httpClient = Hey.createHTTPClient()
      defer { try! httpClient.syncShutdown() }

      let bodyString = "{\"key\": \"value\"}"
      let request = try HTTPClient.Request(
        url: "https://webhook.site/672f9dd2-070c-44a2-9886-89e971f74e2e",
        method: .POST,
        headers: HTTPHeaders([("User-Agent", "Hey CLI-Assistant")]),
        body: HTTPClient.Body.data(bodyString.data(using: .utf8)!)
      )

      let responseFuture = httpClient.execute(request: request)
      responseFuture.whenComplete { result in
        switch result {
        case .failure(let error):
          print("Client seems to have failed: \(error)")
        case .success(let response):
          if response.status == .ok, let body = response.body {
            print("SUCCESS -- \(String(buffer: body))")
          } else {
            print("Server seems to have failed iternally -- Error code: \(response.status)")
          }
        }
      }

      let verbose = args.verbose ? "" : "non-"
      print("Cmd[\(verbose + "verbose")]: with prompt[\(args.prompt.joined(separator: " "))]")
      _ = try! responseFuture.wait()
    }
  }

  struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "script",
      abstract: "Write ad-hoc multi-lingual scripts."
    )

    @Option(name: [.customLong("in")], help: "The target scripting/programming language.")
    var lang: String = "bash"  // replace with hey init conf file option or with system default shell

    @OptionGroup var args: CodeArgs

    mutating func run() throws {
      let verbose = args.verbose ? "" : "non-"
      let context =
        if self.args.context.isEmpty { "empty" } else { self.args.context.joined(separator: ", ") }
      print(
        "Script[\(verbose + "verbose")]: In \(self.lang) with context[\(context)] \(args.prompt.joined(separator: " "))"
      )
    }
  }

  struct Summarize: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "summarize",
      abstract: "Summarize and explain multi-lingual code and commands."
    )

    @Argument(help: "The code/script file(s) to explain.")
    var files: [String]

    func run() throws {
      print("Summarize: [\n\t\(files.joined(separator: ",\n\t"))\n]")
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
      print("Verbosify: \(file)")
    }
  }
}

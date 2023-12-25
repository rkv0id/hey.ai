import Foundation

struct Cache {
    private static let _version = Hey.configuration.version
    private static let _userHome = ProcessInfo.processInfo.environment["HOME"] ?? "/tmp"
    private static let _appDir = ".hey"
    private static let _envFile = URL(fileURLWithPath: _userHome)
        .appending(path: _appDir)
        .appending(path: "env.json")
    
    init() {
        let fileManager = FileManager.default
        let cacheDir = Cache._envFile.deletingLastPathComponent()
        
        do {
            try fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        } catch {
            print("Error creating assistant custom directory:\n\(error)")
        }
        
        let envPath = Cache._envFile.path()
        if !fileManager.fileExists(atPath: envPath)
            && !fileManager.createFile(atPath: envPath, contents: nil)
        {
            print("Failed to initialize environment cache at \(envPath)!")
        }
    }
    
    func update(environment: Environment) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        do {
            let jsonContext = try encoder.encode(
                CachableEnvironment(
                    environment: environment,
                    updatedAt: Date(),
                    version: Cache._version))
            try jsonContext.write(to: Cache._envFile)
        } catch {
            print("Encountered an error while parsing context to cache. Cache sync failed.")
        }
    }
    
    func read() -> Environment? {
        if let jsonData = try? Data(contentsOf: Cache._envFile),
           let cachedContext = try? JSONDecoder().decode(CachableEnvironment.self, from: jsonData),
           let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
           cachedContext.updatedAt > oneHourAgo
        {
            return cachedContext.environment
        } else {
            return nil
        }
    }
    
    struct CachableEnvironment: Codable {
        let environment: Environment
        let updatedAt: Date
        let version: String
    }
}

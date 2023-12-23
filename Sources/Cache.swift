import Foundation

struct Cache {
    private static let _version = Hey.configuration.version
    private static let _userHome = ProcessInfo.processInfo.environment["HOME"] ?? "/tmp"
    private static let _appDir = ".hey"
    private static let _ctxFile = URL(fileURLWithPath: _userHome)
        .appending(path: _appDir)
        .appending(path: "ctx.json")
    
    init() {
        let fileManager = FileManager.default
        let cacheDir = Cache._ctxFile.deletingLastPathComponent()
        
        do {
            try fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        } catch {
            print("Error creating assistant custom directory:\n\(error)")
        }
        
        let ctxPath = Cache._ctxFile.path()
        if !fileManager.fileExists(atPath: ctxPath)
            && !fileManager.createFile(atPath: ctxPath, contents: nil)
        {
            print("Failed to initialize context cache at \(ctxPath)!")
        }
    }
    
    func update(context: Context) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        do {
            let jsonContext = try encoder.encode(
                CachableContext(
                    context: context,
                    updatedAt: Date(),
                    version: Cache._version))
            try jsonContext.write(to: Cache._ctxFile)
        } catch {
            print("Encountered an error while parsing context to cache. Cache sync failed.")
        }
    }
    
    func read() -> Context? {
        if let jsonData = try? Data(contentsOf: Cache._ctxFile),
           let cachedContext = try? JSONDecoder().decode(CachableContext.self, from: jsonData),
           let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
           cachedContext.updatedAt > oneHourAgo
        {
            return cachedContext.context
        } else {
            return nil
        }
    }
    
    struct CachableContext: Codable {
        let context: Context
        let updatedAt: Date
        let version: String
    }
}

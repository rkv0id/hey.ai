import Foundation

struct Cache {
    private static let _version = "0.1"
    private static let _userHome = ProcessInfo.processInfo.environment["HOME"] ?? "/tmp"
    private static let _appDir = ".hey"
    private static let _ctxFileName = "ctx.json"
    
    private let ctxFile: URL
    
    init() {
        let fileManager = FileManager.default
        let cacheDir = URL(fileURLWithPath: Cache._userHome).appending(path: Cache._appDir)
        
        do {
            try fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        } catch {
            print("Error creating assistant custom directory:\n\(error)")
        }
        
        ctxFile = cacheDir.appending(path: Cache._ctxFileName)
        let ctxPath = ctxFile.path()
        if !fileManager.fileExists(atPath: ctxPath) && !fileManager.createFile(atPath: ctxPath, contents: nil) {
            print("Failed to create context cache medium at \(ctxPath)!")
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
            try jsonContext.write(to: ctxFile)
        } catch {
            print("Encountered an error while parsing context to cache. Cache sync failed.")
        }
    }
    
    func read() -> Context? {
        if let jsonData = try? Data(contentsOf: ctxFile),
           let cachedContext = try? JSONDecoder().decode(CachableContext.self, from: jsonData),
           let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
           cachedContext.updatedAt > oneHourAgo {
            return cachedContext.context
        } else {
            return nil
        }
    }
    
    struct CachableContext : Codable {
        let context: Context
        let updatedAt: Date
        let version: String
    }
}

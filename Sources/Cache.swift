import Foundation

struct Cache {
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
    
    func sync(context: Context) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        do {
            let jsonContext = try encoder.encode(context)
            try jsonContext.write(to: ctxFile)
        } catch {
            print("Encountered an error while parsing context to cache. Caching sync failed.")
        }
    }
}

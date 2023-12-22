import Foundation

struct HeyCache {
    private static let _userHome = ProcessInfo.processInfo.environment["HOME"] ?? "/tmp"
    private static let _appDir = ".hey"
    private static let _ctxFileName = "ctx.json"
    
    
    init() {
        let fileManager = FileManager.default
        let cacheDir = URL(fileURLWithPath: HeyCache._userHome).appending(path: HeyCache._appDir)
        
        do {
            try fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        } catch {
            print("Error creating assistant custom directory:\n\(error)")
        }
        
        let ctxPath = cacheDir.appending(path: HeyCache._ctxFileName).path()
        if !fileManager.fileExists(atPath: ctxPath) && !fileManager.createFile(atPath: ctxPath, contents: nil) {
            print("Failed to create context cache medium at \(ctxPath)!")
        }
    }
    
    func sync(context: Context) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonContext = try encoder.encode(context)
        if let jsonString = String(data: jsonContext, encoding: .utf8) {
            print(jsonString)
        }
    }
}

import SQLite
import Foundation

struct HeyDB {
    private static let _userHome = ProcessInfo.processInfo.environment["HOME"] ?? "/tmp"
    private static let _appDir = ".hey"
    private static let _dbFileName = "hey.db"
    
    private let db: Connection?
    
    init(readOnly: Bool = true) {
        let fileManager = FileManager.default
        let dbDir = URL(fileURLWithPath: HeyDB._userHome).appending(path: HeyDB._appDir)
        
        do {
            try fileManager.createDirectory(at: dbDir, withIntermediateDirectories: true)
        } catch {
            print("Error creating assistant custom directory:\n\(error)")
        }
        
        let dbPath = dbDir.appending(path: HeyDB._dbFileName).path()
        if !fileManager.fileExists(atPath: dbPath) && !fileManager.createFile(atPath: dbPath, contents: nil) {
            print("Failed to create database file at \(dbPath)!")
        }
        
        do {
            db = try Connection(dbPath, readonly: readOnly)
        } catch {
            db = nil
            print("Encountered issues while connecting to database!")
        }
    }
    
    func sync(context: Context) {
        let id = Expression<Int64>("id")
        let term = Expression<String>("term")
        let environment = Expression<String>("environment")
        let user = Expression<String>("user")
        let system = Expression<String>("system")
        let network = Expression<String>("network")
    }
}

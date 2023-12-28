import Foundation

struct Cache {
    static let shared = Cache()
    private static let _appConfDir = URL(fileURLWithPath: ProcessInfo.processInfo.environment["HOME"] ?? "/tmp").appending(path: ".hey")
    private static let _envFile = _appConfDir.appending(path: "env.json")
    private static let _filesFile = _appConfDir.appending(path: "files.json")
    
    private init() {
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(at: Cache._appConfDir, withIntermediateDirectories: true)
        } catch {
            print("Error creating assistant custom directory:\n\(error)")
        }
        
        let envPath = Cache._envFile.path()
        if !fileManager.fileExists(atPath: envPath)
            && !fileManager.createFile(atPath: envPath, contents: nil) {
            print("Failed to initialize environment cache at \(envPath)!")
        }
        
        let filesPath = Cache._filesFile.path()
        if !fileManager.fileExists(atPath: filesPath)
            && !fileManager.createFile(atPath: filesPath, contents: nil) {
            print("Failed to initialize files cache at \(filesPath)")
        }
    }
    
    func update(environment: Environment) -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        do {
            let jsonContext = try encoder.encode(
                CachableEnvironment(
                    environment: environment,
                    updatedAt: Date(),
                    version: Hey.configuration.version))
            try jsonContext.write(to: Cache._envFile)
            return true
        } catch {
            print("Encountered an error while parsing context to cache. Cache sync failed.")
        }
        return false
    }
    
    func readEnv() -> Environment? {
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
    
    func readFile(absolutePath: String) -> File? {
        if let jsonData = try? Data(contentsOf: Cache._filesFile),
           let cachedFiles = try? JSONDecoder().decode([String: CachableFile].self, from: jsonData),
           let found = cachedFiles[absolutePath]
        {
            return File(
                id: found.file.id,
                url: found.file.url,
                name: found.file.name,
                mimeType: found.file.mimeType
            )
        } else {
            return nil
        }
    }
    
    func add(file: File) -> Bool {
        var cache: [String: CachableFile] = [:]
        if let jsonData = try? Data(contentsOf: Cache._filesFile),
           let cachedFiles = try? JSONDecoder().decode([String: CachableFile].self, from: jsonData) {
            cache = cachedFiles
        }
        
        cache[file.url.absoluteString] = CachableFile(file: file, createdAt: Date.now)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        do {
            let jsonCache = try encoder.encode(cache)
            try jsonCache.write(to: Cache._filesFile)
            return true
        } catch {
            print("Encountered an error while parsing files to cache. Cache sync failed.")
        }
        return false
    }
    
    func remove(file: File) -> Bool {
        let filePath = file.url.absoluteString
        if let jsonData = try? Data(contentsOf: Cache._filesFile),
           var cachedFiles = try? JSONDecoder().decode([String: CachableFile].self, from: jsonData),
           cachedFiles.contains(where: { $0.key == filePath }) {
            cachedFiles.removeValue(forKey: filePath)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            do {
                let jsonCache = try encoder.encode(cachedFiles)
                try jsonCache.write(to: Cache._filesFile)
                return true
            } catch {
                print("Encountered an error while parsing files to cache. Cache sync failed.")
            }
        }
        return false
    }
    
    func listFiles() -> [File] {
        if let jsonData = try? Data(contentsOf: Cache._filesFile),
           let cachedFiles = try? JSONDecoder().decode([String: CachableFile].self, from: jsonData) {
            return cachedFiles.values.map { $0.file }
        }
        return []
    }
    
    struct CachableEnvironment: Codable {
        let environment: Environment
        let updatedAt: Date
        let version: String
    }
    
    struct CachableFile: Codable {
        let file: File
        let createdAt: Date
    }
}

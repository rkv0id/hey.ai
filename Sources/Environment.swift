import Foundation

struct Environment: Codable {
    private static let _undefined: String = "UNDEFINED"
    private static let _cache = Cache.shared
    
    private let term: Term
    private let executables: Executables
    private let user: User
    private let system: System
    private let network: Network
    
    private init() {
        let global = ProcessInfo.processInfo.environment
        
        term = Term(
            emulator: global["TERM"] ?? Environment._undefined,
            app: global["TERM_PROGRAM"] ?? Environment._undefined,
            size: Term.getTerminalSize(),
            colored: (global["CLICOLOR"] ?? Environment._undefined).lowercased() == "yes",
            colors: global["LSCOLORS"] ?? Environment._undefined,
            encoding: global["LC_CTYPE"] ?? Environment._undefined,
            shell: global["SHELL"] ?? Environment._undefined,
            display: global["DISPLAY"] ?? Environment._undefined
        )
        
        executables = Executables(
            paths: (global["PATH"] ?? Environment._undefined)
                .split(separator: ":")
                .map { String($0) }
        )
        
        user = User(
            name: ProcessInfo.processInfo.userName,
            lang: global["LANG"] ?? Environment._undefined,
            home: global["HOME"] ?? Environment._undefined
        )
        
        system = System(
            os: "macOS",
            version: ProcessInfo.processInfo.operatingSystemVersionString,
            hostName: Host.current().name ?? Environment._undefined,
            arch: System.getSystemArchitecture(),
            cpu: System.getCPUInfo()
        )
        
        network = Network(
            httpProxy: global["http_proxy"] ?? Environment._undefined,
            ftpProxy: global["FTP_PROXY"] ?? Environment._undefined,
            httpsProxy: global["HTTPS_PROXY"] ?? Environment._undefined,
            noProxy: Network.getNoProxyList(noProxyEnv: global["NO_PROXY"])
        )
    }
    
    static func load() -> Environment {
        if let cachedEnv = _cache.readEnv() {
            return cachedEnv
        }
        
        let newEnv = Environment()
        _ = _cache.update(environment: newEnv)
        return newEnv
    }
    
    private struct Term: Codable {
        let emulator: String
        let app: String
        let size: Size
        let colored: Bool
        let colors: String
        let encoding: String
        let shell: String
        let display: String
        
        struct Size: Codable {
            let width: Int
            let height: Int
        }
        
        static func getTerminalSize() -> Size {
            var w = winsize()
            guard ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 else {
                return Term.Size(width: 0, height: 0)
            }
            return Size(width: Int(w.ws_col), height: Int(w.ws_row))
        }
    }
    
    private struct Executables: Codable {
        let paths: [String]
        let bins: Set<String>
        
        init(paths: [String]) {
            self.paths = paths
            self.bins = Set(
                paths
                    .compactMap { URL(string: $0) }
                    .flatMap { Executables._findBinaries(in: $0) })
        }
        
        private static func _findBinaries(in directory: URL) -> [String] {
            let fileManager = FileManager.default
            let contents = try? fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil)
            return (contents ?? [])
                .filter { fileURL in
                    var isDirectory: ObjCBool = false
                    return fileManager.fileExists(atPath: fileURL.path(), isDirectory: &isDirectory)
                    && !isDirectory.boolValue
                    && fileManager.isExecutableFile(atPath: fileURL.path())
                }
                .map { $0.lastPathComponent }
        }
    }
    
    private struct User: Codable {
        let name: String
        let lang: String
        let home: String
    }
    
    private struct System: Codable {
        let os: String
        let version: String
        let hostName: String
        let arch: String
        let cpu: CPU
        
        struct CPU: Codable {
            let name: String
            let physical: Int
            let logical: Int
        }
        
        static func getCPUInfo() -> CPU {
            var size = 64
            var name = [CChar](repeating: 0, count: size)
            sysctlbyname("machdep.cpu.brand_string", &name, &size, nil, 0)
            
            var cores: Int = 0
            size = MemoryLayout<Int>.size
            sysctlbyname("hw.physicalcpu", &cores, &size, nil, 0)
            
            var threads: Int = 0
            size = MemoryLayout<Int>.size
            sysctlbyname("hw.logicalcpu", &threads, &size, nil, 0)
            
            return CPU(name: String(cString: name), physical: cores, logical: threads)
        }
        
        static func getSystemArchitecture() -> String {
            var unameInfo = utsname()
            uname(&unameInfo)
            
            return withUnsafePointer(to: &unameInfo.machine) {
                $0.withMemoryRebound(to: Int8.self, capacity: 1) { String(cString: $0) }
            }
        }
    }
    
    private struct Network: Codable {
        let httpProxy: String
        let ftpProxy: String
        let httpsProxy: String
        let noProxy: [String]
        
        static func getNoProxyList(noProxyEnv: String?) -> [String] {
            return (noProxyEnv ?? "").split(separator: ",").map { String($0) }
        }
    }
}

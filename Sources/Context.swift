import Foundation

struct Context : Encodable {
    let term: Term
    let environment: Environment
    let user: User
    let system: System
    let network: Network
    
    private static let _undefined: String = "UNDEFINED"
    
    init() {
        let global = ProcessInfo.processInfo.environment
        
        term = Term(
            emulator: global["TERM"] ?? Context._undefined,
            app: global["TERM_PROGRAM"] ?? Context._undefined,
            size: Term.getTerminalSize(),
            encoding: global["LC_CTYPE"] ?? Context._undefined,
            shell: global["SHELL"] ?? Context._undefined,
            display: global["DISPLAY"] ?? Context._undefined
        )
        
        environment = Environment(
            lang: global["LANG"] ?? Context._undefined,
            pwd: Environment.getCurrentWorkingDirectory() ?? Context._undefined,
            paths: (global["PATH"] ?? Context._undefined).split(separator: ":").map { String($0) }
        )
        
        user = User(
            name: ProcessInfo.processInfo.userName,
            home: global["HOME"] ?? Context._undefined
        )
        
        system = System(
            os: "macOS",
            version: ProcessInfo.processInfo.operatingSystemVersionString,
            hostName: Host.current().name ?? Context._undefined,
            arch: System.getSystemArchitecture(),
            cpu: System.getCPUInfo()
        )
        
        network = Network(
            httpProxy: global["http_proxy"] ?? Context._undefined,
            ftpProxy: global["FTP_PROXY"] ?? Context._undefined,
            httpsProxy: global["HTTPS_PROXY"] ?? Context._undefined,
            noProxy: Network.getNoProxyList(noProxyEnv: global["NO_PROXY"])
        )
    }
    
    private init(term: Term, environment: Environment, user: User, system: System, network: Network) {
        self.term = term
        self.environment = environment
        self.user = user
        self.system = system
        self.network = network
    }
    
    func withBinaries() -> Context {
        return Context(
            term: self.term,
            environment: self.environment.withBinaries(),
            user: self.user,
            system: self.system,
            network: self.network
        )
    }
    
    struct Term : Encodable {
        let emulator: String
        let app: String
        let size: Size
        let encoding: String
        let shell: String
        let display: String
        
        struct Size : Encodable {
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
    
    struct Environment : Encodable {
        let lang: String
        let pwd: String
        let paths: [String]
        let bins: Set<String>
        
        init(lang: String, pwd: String, paths: [String], withBinaries: Bool = false) {
            self.lang = lang
            self.pwd = pwd
            self.paths = paths
            self.bins = Set(
                withBinaries
                ? paths
                    .compactMap { URL(string: $0) }
                    .flatMap { Environment._findBinaries(in: $0) }
                : []
            )
        }
        
        func withBinaries() -> Environment {
            return Environment(
                lang: self.lang,
                pwd: self.pwd,
                paths: self.paths,
                withBinaries: true
            )
        }
        
        static func getCurrentWorkingDirectory() -> String? {
            let bufferSize = 1028 // a reasonable bufferSize
            var buffer = [CChar](repeating: 0, count: bufferSize)
            guard let cwd = getcwd(&buffer, bufferSize) else {
                return nil
            }
            return String(cString: cwd)
        }
        
        private static func _findBinaries(in directory: URL) -> [String] {
            let fileManager = FileManager.default
            
            if let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
                return contents
                    .filter { fileURL in
                        var isDirectory: ObjCBool = false
                        if fileManager.fileExists(atPath: fileURL.path(), isDirectory: &isDirectory),
                           !isDirectory.boolValue,
                           fileManager.isExecutableFile(atPath: fileURL.path()) {
                            return true
                        }
                        return false
                    }
                    .map { $0.lastPathComponent }
            } else {
                return []
            }
        }
    }
    
    struct User : Encodable {
        let name: String
        let home: String
    }
    
    struct System : Encodable {
        let os: String
        let version: String
        let hostName: String
        let arch: String
        let cpu: CPU
        
        struct CPU : Encodable {
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
                $0.withMemoryRebound(to: Int8.self, capacity: 1) {
                    String(cString: $0)
                }
            }
        }
    }
    
    struct Network : Encodable {
        let httpProxy: String
        let ftpProxy: String
        let httpsProxy: String
        let noProxy: [String]
        
        static func getNoProxyList(noProxyEnv: String?) -> [String] {
            guard let noProxyList = noProxyEnv else {
                return []
            }
            return noProxyList.split(separator: ",").map { String($0) }
        }
    }
}

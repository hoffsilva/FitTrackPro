import Foundation

class EnvReader {
    static let shared = EnvReader()
    private var envVars: [String: String] = [:]
    
    private init() {
        loadEnvFile()
    }
    
    private func loadEnvFile() {
        guard let path = Bundle.main.path(forResource: ".env", ofType: nil),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            fatalError("⚠️ .env file not found in bundle")
        }
        
        parseEnvContent(content)
    }
    
    private func parseEnvContent(_ content: String) {
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                continue
            }
            
            // Parse KEY=VALUE
            let components = trimmedLine.components(separatedBy: "=")
            if components.count >= 2 {
                let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = components.dropFirst().joined(separator: "=").trimmingCharacters(in: .whitespacesAndNewlines)
                envVars[key] = value
            }
        }
    }
    
    func get(_ key: String) -> String? {
        return envVars[key]
    }
    
    func require(_ key: String) -> String {
        guard let value = envVars[key], !value.isEmpty else {
            fatalError("Required environment variable '\(key)' is missing or empty")
        }
        return value
    }
}

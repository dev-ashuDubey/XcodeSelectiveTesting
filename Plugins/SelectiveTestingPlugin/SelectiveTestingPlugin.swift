//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation
import PackagePlugin

@main
struct SelectiveTestingPlugin: CommandPlugin {
    private func run(_ executable: String) throws {
        let executableURL = URL(fileURLWithPath: executable)
        
        let process = Process()
        process.executableURL = executableURL
        process.arguments = [
        ]
        
        try process.run()
        process.waitUntilExit()
        
        let gracefulExit = process.terminationReason == .exit && process.terminationStatus == 0
        if !gracefulExit {
            throw "[ERROR] The plugin execution failed: \(process.terminationReason.rawValue) (\(process.terminationStatus))"
        }
    }
    
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // context.package.directory
        let tool = try context.tool(named: "xcode-selective-test")
        
        try run(tool.path.string)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SelectiveTestingPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "xcode-selective-test")
        
        try run(tool.path.string)
    }
}
#endif

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

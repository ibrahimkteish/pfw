import ArgumentParser
import Foundation

struct Status: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Show current login and install status."
  )

  func run() throws {
    let fileManager = FileManager.default
    let tokenExists = fileManager.fileExists(atPath: tokenURL.path)
    let dataExists = fileManager.fileExists(atPath: pfwDirectoryURL.path)

    print("Logged in: \(tokenExists ? "yes" : "no")")
    print("Token path: \(tokenURL.path)")
    print("Data directory: \(pfwDirectoryURL.path)")
    print("Data directory exists: \(dataExists ? "yes" : "no")")
    print("")

    // Show skills storage paths
    let globalPath = URL(filePath: "~/.pfw/skills")
    let expandedGlobalPath = URL(fileURLWithPath: NSString(string: globalPath.path).expandingTildeInPath)
    let globalExists = fileManager.fileExists(atPath: expandedGlobalPath.path)

    let localPath = URL(filePath: ".pfw/skills")
    let expandedLocalPath = URL(fileURLWithPath: NSString(string: localPath.path).expandingTildeInPath)
    let localExists = fileManager.fileExists(atPath: expandedLocalPath.path)

    print("Skills Storage:")
    print("  Global (~/.pfw/skills): \(globalExists ? "✓ installed" : "✗ not found")")
    print("  Local (.pfw/skills): \(localExists ? "✓ installed" : "✗ not found")")
    print("")

    // Show symlink status for each tool
    print("AI Tool Symlinks:")
    print("")
    print("Global (user-level):")
    for tool in Install.Tool.allCases {
      let symlinkPath = tool.symlinkPath(workspace: false)
      let expandedSymlinkPath = URL(fileURLWithPath: NSString(string: symlinkPath.path).expandingTildeInPath)

      if fileManager.fileExists(atPath: expandedSymlinkPath.path) {
        var isSymlink = false
        if let resourceValues = try? expandedSymlinkPath.resourceValues(forKeys: [.isSymbolicLinkKey]) {
          isSymlink = resourceValues.isSymbolicLink ?? false
        }

        if isSymlink {
          if let destination = try? fileManager.destinationOfSymbolicLink(atPath: expandedSymlinkPath.path) {
            print("  ✓ \(tool.rawValue): \(symlinkPath.path) → \(destination)")
          } else {
            print("  ✓ \(tool.rawValue): \(symlinkPath.path) (symlink)")
          }
        } else {
          print("  ⚠ \(tool.rawValue): \(symlinkPath.path) (exists but not a symlink)")
        }
      } else {
        print("  ✗ \(tool.rawValue): \(symlinkPath.path) (not installed)")
      }
    }

    print("")
    print("Workspace-specific (project-level):")
    print("  Run 'pfw status' from a project directory to check workspace symlinks")
  }
}

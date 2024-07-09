import Foundation

final class ImageFinder {
    private init() { }

    static func imageFile(for imageName: String) -> String {
        let fullExecutablePath = Bundle.main.executablePath!
        let executableName = fullExecutablePath.components(separatedBy: "/").last!
        let executablePath = String(fullExecutablePath.prefix(fullExecutablePath.count - executableName.count - 1))
        let font = "\(imageName).svg"
        var parent = "."

        for _ in 0...5 {
            let fullPath = executablePath + "/" + parent + "/" + font
            print("\(fullPath)")
            if FileManager.default.fileExists(atPath: fullPath) {
                return fullPath
            } 

            parent += "/.."
        }

        fatalError("Image \(imageName) not found.")
    }
}

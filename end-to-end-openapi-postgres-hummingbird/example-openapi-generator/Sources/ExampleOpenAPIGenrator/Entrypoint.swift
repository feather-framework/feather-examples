import FeatherOpenAPI
import OpenAPIKit30
import OpenAPIKit
import OpenAPIKitCompat
import Yams
import Foundation

@main
struct Entrypoint {

    static func main(
        
    ) async throws {

        let collection = MyPathCollection()

        let document = MyDocument(
            info: MyInfo(),
            paths: collection.pathMap,
            components: collection.components,
        )

        let openAPIdoc = document.openAPIDocument()

        let encoder = YAMLEncoder()

        _ =
            try openAPIdoc
            .locallyDereferenced()
            .resolved()

        let result = try encoder.encode(openAPIdoc)
        
        let workURL = URL(fileURLWithPath: getWorkDir())
        
        let openAPIDirURL = workURL
            .appending(path: "openapi")
        
        let v300YAMLFileURL = openAPIDirURL
            .appending(path: "v3_0_0.yml")
        let v310YAMLFileURL = openAPIDirURL
            .appending(path: "v3_1_0.yml")
        let v320YAMLFileURL = openAPIDirURL
            .appending(path: "v3_2_0.yml")
        
        let dockerYAMLFileURL = workURL
            .appending(path: "docker")
            .appending(path: "api")
            .appending(path: "www")
            .appending(path: "openapi.yaml")
        
        let libraryYAMLFileURL = workURL
            .appending(path: "../")
            .appending(path: "example-openapi")
            .appending(path: "openapi.yaml")

        let urls = [
            v300YAMLFileURL,
            dockerYAMLFileURL,
            libraryYAMLFileURL,
        ]
        
        for url in urls {
            try result.write(
                to: url,
                atomically: true,
                encoding: .utf8
            )
        }

        let doc310 = openAPIdoc.convert(to: .v3_1_0)
        let result310 = try encoder.encode(doc310)
        try result310.write(
            to: v310YAMLFileURL,
            atomically: true,
            encoding: .utf8
        )

        let doc320 = openAPIdoc.convert(to: .v3_2_0)
        let result320 = try encoder.encode(doc320)
        try result320.write(
            to: v320YAMLFileURL,
            atomically: true,
            encoding: .utf8
        )
    }
    
    static func getWorkDir() -> String {
        return "/" + #filePath
            .split(separator: "/")
            .dropLast(3)
            .joined(separator: "/")
        
//        let home = FileManager.default.homeDirectoryForCurrentUser.path
//        var publicPath = ".".replacingOccurrences(of: "~", with: home)
//        
//        if publicPath.hasPrefix(".") {
//            publicPath = FileManager.default.currentDirectoryPath + "/" + publicPath
//        }
//        return publicPath
    }
}



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
        _ = try openAPIdoc.locallyDereferenced().resolved()

        let baseURL = URL(fileURLWithPath: getWorkDir())
        
        let openapiOutputURL = baseURL
            .appending(path: "openapi")
        
        let v300YAMLFileURL = openapiOutputURL
            .appending(path: "openapi.yaml")
        
        let v310YAMLFileURL = openapiOutputURL
            .appending(path: "openapi@v3_1_0.yaml")
        
        let v320YAMLFileURL = openapiOutputURL
            .appending(path: "openapi@v3_2_0.yaml")
        

        let result300 = try encoder.encode(openAPIdoc)
        try result300.write(
            to: v300YAMLFileURL,
            atomically: true,
            encoding: .utf8
        )

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
        "/" + #filePath
            .split(separator: "/")
            .dropLast(4)
            .joined(separator: "/")
    }
}



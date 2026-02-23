import OpenAPIKit30
import OpenAPIKit
import OpenAPIKitCompat
import Yams
import Foundation

@main
struct Entrypoint {

    static func main() async throws {
        let baseURL = URL(fileURLWithPath: getWorkDir())
        let openapiOutputURL = baseURL.appending(path: "openapi")
        let encoder = YAMLEncoder()

        try write(
            kind: .main,
            basename: "openapi",
            outputURL: openapiOutputURL,
            encoder: encoder
        )
    }

    static func write(
        kind: APIDocumentKind,
        basename: String,
        outputURL: URL,
        encoder: YAMLEncoder
    ) throws {
        let openAPIDoc = buildDocument(kind: kind)
        _ = try openAPIDoc.locallyDereferenced().resolved()

        let v300YAMLFileURL = outputURL.appending(path: "\(basename).yaml")
        let v310YAMLFileURL = outputURL.appending(path: "\(basename)@v3_1_0.yaml")
        let v320YAMLFileURL = outputURL.appending(path: "\(basename)@v3_2_0.yaml")

        let result300 = try encoder.encode(openAPIDoc)
        try result300.write(
            to: v300YAMLFileURL,
            atomically: true,
            encoding: .utf8
        )

        let doc310 = openAPIDoc.convert(to: .v3_1_0)
        let result310 = try encoder.encode(doc310)
        try result310.write(
            to: v310YAMLFileURL,
            atomically: true,
            encoding: .utf8
        )

        let doc320 = openAPIDoc.convert(to: .v3_2_0)
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

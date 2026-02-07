//
//  OpenAPI.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct MyPathCollection: PathCollectionRepresentable {

    var pathMap: PathMap {
        [
            "todos": TodoPathItems(),
            "todos/{todoId}": TodoIdPathItems(),
            "lists": ListPathItems(),
            "lists/{listId}": ListIdPathItems(),
        ]
    }
}

struct MyInfo: InfoRepresentable {
    var title: String { "Todo API - example" }
    var version: String { "1.0.0" }
}

struct TestServer: ServerRepresentable {

    var url: any LocationRepresentable {
        Location("http://127.0.0.1:8080/")
    }
}


struct MyDocument: DocumentRepresentable {

    var info: OpenAPIInfoRepresentable

    var servers: [any OpenAPIServerRepresentable] {
        [
            TestServer()
        ]
    }

    var paths: PathMap
    var components: OpenAPIComponentsRepresentable

    init(
        info: OpenAPIInfoRepresentable,
        paths: PathMap,
        components: OpenAPIComponentsRepresentable
    ) {
        self.info = info
        self.paths = paths
        self.components = components
    }
}

struct Location: LocationRepresentable {
    public var location: String

    init(_ location: String) {
        self.location = location
    }
}

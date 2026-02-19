//
//  File.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 11..
//

import ServiceLifecycle

struct MigrationService: Service {
    
    let migrator: Migrator

    func run() async throws {
        try await migrator.run()
        print("✅ Migration ready.")
    }
}

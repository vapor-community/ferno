import Vapor
import JWT

extension Application {
    /// The `Ferno` object
    public var ferno: Ferno { .init(application: self) }
    
    public struct Ferno {
        
        struct Key: StorageKey {
            typealias Value = Storage
        }
        
        /// The provider of the `Ferno` configuration
        public struct Provider {
            let run: (Application) -> ()

            public init(_ run: @escaping (Application) -> ()) {
                self.run = run
            }
            
            public static func `default`(_ configuration: FernoConfiguration) -> Self {
                .init { app in
                    app.ferno.use(configuration)
                    app.ferno.use(custom: DefaultFernoDriver(client: app.client))
                }
            }
        }
        
        final class Storage {
            public var configuration: FernoConfiguration
            public var driver: FernoDriver?

            public init(config: FernoConfiguration) {
                self.configuration = config
            }
        }
        
        struct Lifecycle: LifecycleHandler {
            func shutdown(_ application: Application) {
                if let driver = application.ferno.storage.driver {
                    driver.shutdown()
                }
            }
        }
        
        public let application: Application
        
        /// The `FernoConfiguration` object
        public var configuration: FernoConfiguration {
            get { self.storage.configuration }
            nonmutating set { self.storage.configuration = newValue }
        }

        /// The selected `QueuesDriver`
        public var driver: FernoDriver {
            guard let driver = self.storage.driver else {
                fatalError("No Ferno driver configured. Configure with app.ferno.use(...)")
            }
            return driver
        }
        
        var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                fatalError("No Ferno configuration found. Configure with app.ferno.use(...)")
            }
            return storage
        }
        
        var client: FernoClient { driver.makeClient(with: configuration) }
        
        func initialize() {
            self.application.lifecycle.use(Lifecycle())
        }
        
        public func use(_ provider: Provider) {
            provider.run(self.application)
        }
        
        public func use(_ config: FernoConfiguration) {
            self.application.storage[Key.self] = .init(config: config)
            self.initialize()
        }
        
        public func use(custom driver: FernoDriver) {
            self.storage.driver = driver
        }
        
    }
}

extension Application.Ferno {
    
    /// Deletes everything
    public func delete(_ path: String...) async throws -> Bool {
        try await self.delete(path)
    }

    /// Creates child
    public func create<T: Content>(_ path: String..., body: T) async throws -> FernoChild {
        try await self.create(path, body: body)
    }

    /// Overwrites everything at that location with the data
    public func overwrite<T: Content>(_ path: String..., body: T) async throws -> T {
        try await self.overwrite(path, body: body)
    }

    /// Updates location, but omitted values won't get replaced
    public func update<T: Content>(_ path: String..., body: T) async throws -> T {
        try await self.update(path, body: body)
    }

    public func retrieveMany<F: Decodable>(_ path: String..., queryItems: [FernoQuery] = []) async throws -> [String: F] {
        try await self.retrieveMany(path, queryItems: queryItems)
    }

    public func retrieve<F: Decodable>(_ path: String..., queryItems: [FernoQuery] = []) async throws -> F {
        try await self.retrieve(path, queryItems: queryItems)
    }
}


extension Application.Ferno {
    
    /// Deletes everything
    public func delete(_ path: [String]) async throws -> Bool {
        try await self.client.delete(method: .DELETE, path: path)
    }

    /// Creates child
    public func create<T: Content>(_ path: [String], body: T) async throws -> FernoChild {
        try await self.client.send(
            method: .POST,
            path: path,
            query: [],
            body: body,
            headers: [:]
        )
    }


    /// Overwrites everything at that location with the data
    public func overwrite<T: Content>(_ path: [String], body: T) async throws -> T {
        try await self.client.send(
            method: .PUT,
            path: path,
            query: [],
            body: body,
            headers: [:]
        )
    }

    /// Updates location, but omitted values won't get replaced
    public func update<T: Content>(_ path: [String], body: T) async throws -> T {
        try await self.client.send(
            method: .PATCH,
            path: path,
            query: [],
            body: body,
            headers: [:]
        )
    }

    public func retrieveMany<F: Decodable>(_ path: [String], queryItems: [FernoQuery] = []) async throws -> [String: F] {
        try await self.client.sendMany(
            method: .GET,
            path: path,
            query: queryItems,
            body: "",
            headers: [:]
        )
    }

    public func retrieve<F: Decodable>(_ path: [String], queryItems: [FernoQuery] = []) async throws -> F {
        try await self.client.send(
            method: .GET,
            path: path,
            query: queryItems,
            body: "",
            headers: [:]
        )
    }
}

import Vapor

public struct FernoServiceJsonConfiguration: FernoConfigurationProvider, Decodable, Sendable {
    public let type: String
    public let projectId: String
    public let email: String
    public let clientId: String
    public let basePath: String
    public var accessToken: String?
    public var tokenExpirationDate: Date?
    public var logger: Logger = .init(label: "codes.vapor.ferno")
    public let privateKey: String
    public let tokenURI: String
    internal let privateKeyId: String
    internal let authURI: String
    internal let authProviderX509CertURL: String
    internal let clientX509CertURL: String
    internal let universeDomain: String

    enum CodingKeys: String, CodingKey {
        case type
        case projectId = "project_id"
        case privateKeyId = "private_key_id"
        case privateKey = "private_key"
        case email = "client_email"
        case clientId = "client_id"
        case authURI = "auth_uri"
        case tokenURI = "token_uri"
        case authProviderX509CertURL = "auth_provider_x509_cert_url"
        case clientX509CertURL = "client_x509_cert_url"
        case universeDomain = "universe_domain"
    }

    public init(type: String,
                projectId: String,
                privateKeyId: String,
                privateKey: String,
                clientEmail: String,
                clientId: String,
                authUri: String,
                tokenUri: String,
                authProviderX509CertUrl: String,
                clientX509CertUrl: String,
                universeDomain: String,
                logger: Logger = .init(label: "codes.vapor.ferno")) {
        self.type = type
        self.projectId = projectId
        self.privateKeyId = privateKeyId
        self.privateKey = privateKey
        self.email = clientEmail
        self.clientId = clientId
        self.authURI = authUri
        self.tokenURI = tokenUri
        self.authProviderX509CertURL = authProviderX509CertUrl
        self.clientX509CertURL = clientX509CertUrl
        self.universeDomain = universeDomain
        self.logger = logger
        self.basePath = "https://\(projectId).firebaseio.com"
    }

    public init(json: Data, logger: Logger = .init(label: "codes.vapor.ferno")) throws {
        let configuration = try JSONDecoder().decode(FernoServiceJsonConfiguration.self, from: json)
        self.type = configuration.type
        self.projectId = configuration.projectId
        self.privateKeyId = configuration.privateKeyId
        self.privateKey = configuration.privateKey
        self.email = configuration.email
        self.clientId = configuration.clientId
        self.authURI = configuration.authURI
        self.tokenURI = configuration.tokenURI
        self.authProviderX509CertURL = configuration.authProviderX509CertURL
        self.clientX509CertURL = configuration.clientX509CertURL
        self.universeDomain = configuration.universeDomain
        self.logger = logger
        self.basePath = "https://\(projectId).firebaseio.com"
    }

    public init(json: ByteBuffer, logger: Logger = .init(label: "codes.vapor.ferno")) throws {
        let configuration = try JSONDecoder().decode(FernoServiceJsonConfiguration.self, from: json)
        self.type = configuration.type
        self.projectId = configuration.projectId
        self.privateKeyId = configuration.privateKeyId
        self.privateKey = configuration.privateKey
        self.email = configuration.email
        self.clientId = configuration.clientId
        self.authURI = configuration.authURI
        self.tokenURI = configuration.tokenURI
        self.authProviderX509CertURL = configuration.authProviderX509CertURL
        self.clientX509CertURL = configuration.clientX509CertURL
        self.universeDomain = configuration.universeDomain
        self.logger = logger
        self.basePath = "https://\(projectId).firebaseio.com"
    }
    
    /// The `ServiceAccountKey.json` path in URL format
    public init(path: URL, logger: Logger = .init(label: "codes.vapor.ferno")) throws {
        let data = try Data(contentsOf: path)
        let configuration = try JSONDecoder().decode(FernoServiceJsonConfiguration.self, from: data)
        self.type = configuration.type
        self.projectId = configuration.projectId
        self.privateKeyId = configuration.privateKeyId
        self.privateKey = configuration.privateKey
        self.email = configuration.email
        self.clientId = configuration.clientId
        self.authURI = configuration.authURI
        self.tokenURI = configuration.tokenURI
        self.authProviderX509CertURL = configuration.authProviderX509CertURL
        self.clientX509CertURL = configuration.clientX509CertURL
        self.universeDomain = configuration.universeDomain
        self.logger = logger
        self.basePath = "https://\(projectId).firebaseio.com"
    }
    
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<FernoServiceJsonConfiguration.CodingKeys> = try decoder.container(keyedBy: FernoServiceJsonConfiguration.CodingKeys.self)
        self.type = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.type)
        self.projectId = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.projectId)
        self.privateKeyId = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.privateKeyId)
        self.privateKey = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.privateKey)
        self.email = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.email)
        self.clientId = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.clientId)
        self.authURI = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.authURI)
        self.tokenURI = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.tokenURI)
        self.authProviderX509CertURL = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.authProviderX509CertURL)
        self.clientX509CertURL = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.clientX509CertURL)
        self.universeDomain = try container.decode(String.self, forKey: FernoServiceJsonConfiguration.CodingKeys.universeDomain)
        self.basePath = "https://\(projectId).firebaseio.com"
    }
}

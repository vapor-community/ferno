import Vapor

public struct FirebaseServiceAccountKey: Content, Sendable {
    public let type: String
    public let projectId: String
    public let clientEmail: String
    public let clientId: String
    public let basePath: String
    internal let privateKeyId: String
    internal let privateKey: String
    internal let authUri: String
    internal let tokenUri: String
    internal let authProviderX509CertUrl: String
    internal let clientX509CertUrl: String
    internal let universeDomain: String

    enum CodingKeys: String, CodingKey {
        case type
        case projectId = "project_id"
        case privateKeyId = "private_key_id"
        case privateKey = "private_key"
        case clientEmail = "client_email"
        case clientId = "client_id"
        case authUri = "auth_uri"
        case tokenUri = "token_uri"
        case authProviderX509CertUrl = "auth_provider_x509_cert_url"
        case clientX509CertUrl = "client_x509_cert_url"
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
                universeDomain: String) {
        self.type = type
        self.projectId = projectId
        self.privateKeyId = privateKeyId
        self.privateKey = privateKey
        self.clientEmail = clientEmail
        self.clientId = clientId
        self.authUri = authUri
        self.tokenUri = tokenUri
        self.authProviderX509CertUrl = authProviderX509CertUrl
        self.clientX509CertUrl = clientX509CertUrl
        self.universeDomain = universeDomain
        self.basePath = "https://\(projectId).firebaseio.com"
    }

    public init(json: Data) throws {
        let configuration = try JSONDecoder().decode(FirebaseServiceAccountKey.self, from: json)
        self.type = configuration.type
        self.projectId = configuration.projectId
        self.privateKeyId = configuration.privateKeyId
        self.privateKey = configuration.privateKey
        self.clientEmail = configuration.clientEmail
        self.clientId = configuration.clientId
        self.authUri = configuration.authUri
        self.tokenUri = configuration.tokenUri
        self.authProviderX509CertUrl = configuration.authProviderX509CertUrl
        self.clientX509CertUrl = configuration.clientX509CertUrl
        self.universeDomain = configuration.universeDomain
        self.basePath = "https://\(projectId).firebaseio.com"
    }

    public init(json: ByteBuffer) throws {
        let configuration = try JSONDecoder().decode(FirebaseServiceAccountKey.self, from: json)
        self.type = configuration.type
        self.projectId = configuration.projectId
        self.privateKeyId = configuration.privateKeyId
        self.privateKey = configuration.privateKey
        self.clientEmail = configuration.clientEmail
        self.clientId = configuration.clientId
        self.authUri = configuration.authUri
        self.tokenUri = configuration.tokenUri
        self.authProviderX509CertUrl = configuration.authProviderX509CertUrl
        self.clientX509CertUrl = configuration.clientX509CertUrl
        self.universeDomain = configuration.universeDomain
        self.basePath = "https://\(projectId).firebaseio.com"
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<FirebaseServiceAccountKey.CodingKeys> = try decoder.container(keyedBy: FirebaseServiceAccountKey.CodingKeys.self)

        self.type = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.type)
        self.projectId = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.projectId)
        self.privateKeyId = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.privateKeyId)
        self.privateKey = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.privateKey)
        self.clientEmail = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.clientEmail)
        self.clientId = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.clientId)
        self.authUri = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.authUri)
        self.tokenUri = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.tokenUri)
        self.authProviderX509CertUrl = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.authProviderX509CertUrl)
        self.clientX509CertUrl = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.clientX509CertUrl)
        self.universeDomain = try container.decode(String.self, forKey: FirebaseServiceAccountKey.CodingKeys.universeDomain)
        self.basePath = "https://\(projectId).firebaseio.com"
    }
}

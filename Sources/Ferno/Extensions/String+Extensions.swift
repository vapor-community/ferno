import JWT

// MARK: - JWT Helper Stuff

internal extension String {
    var bytes: [UInt8] { .init(self.utf8) }
}

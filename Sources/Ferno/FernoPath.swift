//
//  FernoPath.swift
//  Ferno
//
//  Created by Austin Astorga on 5/4/18.
//

import Foundation

//Firebase Path Enum
public enum FernoPath {
    case child(String)
    case json
}

extension Array where Element == FernoPath {

    var childPath: String {
        var path = ""
        self.forEach { child in
            switch child {
            case .child(let string):
                path.append("/\(string)")
            case .json:
                path.append("/.json")
            }
        }
        return path
    }
}

public protocol FernoPathRepresentable {
    func fernoPath() -> FernoPath
}

extension String: FernoPathRepresentable {
    public func fernoPath() -> FernoPath {
        return .child(self)
    }
}

extension Array where Element == String {
    func makeFernoPath() -> [FernoPath] {
        return self.map { $0.fernoPath() } + [.json]
    }
}

//
//  FirebaseRoutes.swift
//  FirebaseRealtime
//
//  Created by Austin Astorga on 4/30/18.
//

import Vapor

public enum FirebaseQueryParams {
    case accessToken(String)
    case shallow(Bool)
    case orderBy(String)
    case limitToFirst(String)
    case limitToLast(String)
    case startAt(String)
    case endAt(String)
    case equalTo(String)
}

extension FirebaseQueryParams: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "access_token": self = .accessToken("")
        case "shallow": self = .shallow(false)
        case "orderBy": self = .orderBy("")
        case "limitToFirst": self = .limitToFirst("")
        case "limitToLast": self = .limitToLast("")
        case "startAt": self = .startAt("")
        case "endAt": self = .endAt("")
        case "equalTo": self = .equalTo("")
        default:
            return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .accessToken: return "access_token"
        case .shallow: return "shallow"
        case .orderBy: return "orderBy"
        case .limitToFirst: return "limitToFirst"
        case .limitToLast: return "limitToLast"
        case .startAt: return "startAt"
        case .endAt: return "endAt"
        case .equalTo: return "equalTo"
        }
    }
}


public struct FirebaseRoutes {
    private let request: FirebaseRequest

    init(request: FirebaseRequest) {
        self.request = request
    }

    public func retrieve<F: Decodable>(queryItems: [FirebaseQueryParams]? = nil, appendedPath: String) throws -> Future<F> {
        let query = queryItems == nil ? [] : queryItems!

        return try request.send(method: .GET, path: appendedPath, query: query)

    }
}

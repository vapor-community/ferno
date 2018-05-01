//
//  FirebaseRoutes.swift
//  FirebaseRealtime
//
//  Created by Austin Astorga on 4/30/18.
//

import Vapor

//Firebase Path Enum
public enum FirebasePath {
    case child(String)
    case json
}

extension Array where Element == FirebasePath {

    var childPath: String {
        var path = ""
        self.forEach { child in
            switch child {
            case .child(let string):
                path.append("/\(string)")
            case .json:
                path.append(".json")
            }
        }
        return path
    }
}

//Firebase Value Enum
public enum FirebaseValue {

    case number(Int)
    case string(String)
    case boolean(Bool)

    func stringForm() -> String {
        switch self {
        case .boolean(let bool):
            return bool.description
        case .number(let int):
            return int.description
        case .string(let str):
            return "\"\(str)\""
        }
    }
}

//Firebase Query Params Enum

public enum FirebaseQueryParams {
    case shallow(Bool)
    case orderBy(FirebaseValue)
    case limitToFirst(FirebaseValue)
    case limitToLast(FirebaseValue)
    case startAt(FirebaseValue)
    case endAt(FirebaseValue)
    case equalTo(FirebaseValue)
}

extension FirebaseQueryParams: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "shallow": self = .shallow(false)
        case "orderBy": self = .orderBy(.boolean(true))
        case "limitToFirst": self = .limitToFirst(.string(""))
        case "limitToLast": self = .limitToLast(.string(""))
        case "startAt": self = .startAt(.string(""))
        case "endAt": self = .endAt(.string(""))
        case "equalTo": self = .equalTo(.string(""))
        default:
            return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
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

extension Array where Element == FirebaseQueryParams {

    func createQuery(authKey: String) -> String {
        let queryString: String = self.map { param in
            let key = param.rawValue
            let value: String = {
                switch param {
                case .shallow(let val):
                    return val.description

                case .orderBy(let val),
                     .limitToFirst(let val),
                     .limitToLast(let val),
                     .startAt(let val),
                     .endAt(let val),
                     .equalTo(let val):
                    return val.stringForm()
                }
            }()

            return "\(key)=\(value)"
            }.joined(separator: "&")
        return queryString + "&auth=\(authKey)"
    }
}


public struct FirebaseRoutes {
    private let request: FirebaseRequest

    init(request: FirebaseRequest) {
        self.request = request
    }

    public func retrieve<F: Decodable>(req: Request, queryItems: [FirebaseQueryParams]? = nil, appendedPath: [FirebasePath]) throws -> Future<[F]> {
        let query = queryItems == nil ? [] : queryItems!
        let sendReq: Future<[F]> = try request.send(req: Request, method: .GET, path: appendedPath, query: query, body: "", headers: [:])
        return sendReq
    }

    public func retrieve<F: Decodable>(req: Request, queryItems: [FirebaseQueryParams]? = nil, appendedPath: [FirebasePath]) throws -> Future<F> {
        let query = queryItems == nil ? [] : queryItems!
        let sendReq: Future<F> = try request.send(req: Request, method: .GET, path: appendedPath, query: query, body: "", headers: [:])
        return sendReq
    }
}

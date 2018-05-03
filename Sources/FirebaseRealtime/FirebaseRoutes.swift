//
//  FirebaseRoutes.swift
//  FirebaseRealtime
//
//  Created by Austin Astorga on 4/30/18.
//

import Vapor


public struct FirebaseChild: Content {
    public var name: String
}

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
                path.append("/.json")
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
        return queryString + "&access_token=\(authKey)"
    }
}


public struct FirebaseRoutes {
    private let request: FirebaseRequest


    init(request: FirebaseRequest) {
        self.request = request
    }

    //DELETE -> deletes everything
    public func delete(req: Request, appendedPath: [FirebasePath]) throws -> Future<Bool> {
        let sendReq: Future<Bool> = try self.request.delete(req: req, method: .DELETE, path: appendedPath)
        return sendReq
    }

    //POST -> create child
    public func create<T: Content>(req: Request, appendedPath: [FirebasePath], body: T) throws -> Future<FirebaseChild> {
        let sendReq: Future<FirebaseChild> = try self.request.send(
            req: req,
            method: .POST,
            path: appendedPath,
            query: [],
            body: body,
            headers: [:])
        return sendReq
    }


    //PUT will overwrite everything at that location with the data
    public func overwrite<T: Content>(req: Request, appendedPath: [FirebasePath], body: T) throws -> Future<T> {
        let sendReq: Future<T> = try self.request.send(
            req: req,
            method: .PUT,
            path: appendedPath,
            query: [],
            body: body,
            headers: [:])
        return sendReq
    }

    //PATCH update location, but omitted values won't get replaced
    public func update<T: Content>(req: Request, appendedPath: [FirebasePath], body: T) throws -> Future<T> {
        let sendReq: Future<T> = try self.request.send(
            req: req,
            method: .PATCH,
            path: appendedPath,
            query: [],
            body: body,
            headers: [:])
        return sendReq
    }

    public func retrieveMany<F: Decodable>(req: Request, queryItems: [FirebaseQueryParams]? = nil, appendedPath: [FirebasePath]) throws -> Future<[F]> {
        let sendReq: Future<[F]> = try self.request.sendMany(
            req: req,
            method: .GET,
            path: appendedPath,
            query: queryItems ?? [],
            body: "",
            headers: [:])
        return sendReq
    }

    public func retrieve<F: Decodable>(req: Request, queryItems: [FirebaseQueryParams]? = nil, appendedPath: [FirebasePath]) throws -> Future<F> {
        let sendReq: Future<F> = try self.request.send(
            req: req,
            method: .GET,
            path: appendedPath,
            query: queryItems ?? [],
            body: "",
            headers: [:])
        return sendReq
    }
}

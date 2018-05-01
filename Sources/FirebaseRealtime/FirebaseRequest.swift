//
//  FirebaseRequest.swift
//  FirebaseRealtime
//
//  Created by Austin Astorga on 4/30/18.
//

import Foundation
import Vapor
import HTTP
public protocol FirebaseRequest: class {
    func serializedResponse<F: Decodable>(response: HTTPResponse, worker: EventLoop, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) throws -> Future<F>
    func send<F: Decodable>(method: HTTPMethod, path: String, query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> Future<F>
}

public extension FirebaseRequest {

    public func send<F: Decodable>(method: HTTPMethod, path: String, query: [FirebaseQueryParams] = [], body: String = "", headers: HTTPHeaders = [:]) throws -> Future<F> {
        return try send(method: method, path: path, query: query, body: body, headers: headers)
    }

    public func serializedResponse<F: Decodable>(response: HTTPResponse, worker: EventLoop, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) throws -> Future<F> {
        let decoder = JSONDecoder()
        if let dateDecodingStrat = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrat
        }

        guard response.status == .ok else {
            //throw error
            throw FirebaseRealtimeError.requestFailed
        }

        return try decoder.decode(F.self, from: response, maxSize: 65_536, on: worker)
    }
}

public class FirebaseAPIRequest: FirebaseRequest {

    private let httpClient: Client
    private let authKey: String
    private let basePath: String

    init(httpClient: Client, authKey: String, basePath: String) {
        self.httpClient = httpClient
        self.authKey = authKey
        self.basePath = basePath
    }

    public func send<F: Decodable>(method: HTTPMethod, path: String, query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> Future<F> {
        let encodedHTTPBody = HTTPBody(string: body)
        let completePath = basePath + path
        let queryString: String = {
            var dict: [String: String] = [:]
            query.forEach{ queryParam in
                switch queryParam {
                case .accessToken(let token):
                    dict[queryParam.rawValue] = token
                case .endAt(let endAt):
                    dict[queryParam.rawValue] = endAt
                case .equalTo(let equalTo):
                    dict[queryParam.rawValue] = equalTo
                case .limitToFirst(let limitToFirst):
                    dict[queryParam.rawValue] = limitToFirst
                case .limitToLast(let limitToLast):
                    dict[queryParam.rawValue] = limitToLast
                case .orderBy(let orderBy):
                    dict[queryParam.rawValue] = orderBy
                case .shallow(let shallow):
                    dict[queryParam.rawValue] = shallow ? "1" : "0"
                case .startAt(let startAt):
                    dict[queryParam.rawValue] = startAt
                }
            }
            let map: [String] = dict.map {(key, value) in
                return "\(key)=\(value)"
            }
            return map.joined(separator: "&")
        }()
        let request = HTTPRequest(method: method, url: URL(string: "\(completePath)?\(queryString)")!, headers: headers, body: encodedHTTPBody)

        return try httpClient.respond(to: Request(http: request, using: httpClient.container)).flatMap(to: F.self) { response in
            return try self.serializedResponse(response: response.http, worker: self.httpClient.container.eventLoop, dateDecodingStrategy: nil)
        }
    }
}

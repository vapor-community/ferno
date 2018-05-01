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
    //Firebase is so dumb
    func serializedResponse<F: Decodable>(response: HTTPResponse, worker: Worker, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) throws -> Future<F>

    func send<F: Decodable>(req: Request,method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> Future<F>

    func serializedResponse<F: Decodable>(response: HTTPResponse, worker: Worker, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) throws -> Future<[F]>

    func send<F: Decodable>(req: Request,method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> Future<[F]>
}


public class FirebaseAPIRequest: FirebaseRequest {

    public func serializedResponse<F>(response: HTTPResponse, worker: Worker, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) throws -> EventLoopFuture<F> where F : Decodable {
        let decoder = JSONDecoder()
        if let dateDecodingStrat = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrat
        }

        guard response.status == .ok else {
            //throw error
            print(response)
            throw FirebaseRealtimeError.requestFailed
        }

        return try decoder.decode(F.self, from: response, maxSize: 65_536, on: worker)
    }

    public func send<F>(req: Request, method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> EventLoopFuture<F> where F : Decodable {
        let encodedHTTPBody = HTTPBody(string: body)
        let completePath = basePath + path.childPath
        let queryString = query.createQuery(authKey: self.authKey)
        let urlString = "\(completePath)?\(queryString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(urlString)
        let request = HTTPRequest(method: method, url: URL(string: urlString)!, headers: headers, body: encodedHTTPBody)

        return try httpClient.respond(to: Request(http: request, using: httpClient.container)).flatMap(to: F.self) { response in
            return try self.serializedResponse(response: response.http, worker: req, dateDecodingStrategy: nil)
        }
    }

    public func serializedResponse<F>(response: HTTPResponse, worker: Worker, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) throws -> EventLoopFuture<[F]> where F : Decodable {
        let decoder = JSONDecoder()
        if let dateDecodingStrat = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrat
        }

        guard response.status == .ok else {
            //throw error
            print(response)
            throw FirebaseRealtimeError.requestFailed
        }

        return try decoder.decode([String : F].self, from: response, maxSize: 65_536, on: worker).map(to: [F].self) { data in
            return Array(data.values)
        }
    }

    public func send<F>(req: Request, method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> EventLoopFuture<[F]> where F : Decodable {
        let encodedHTTPBody = HTTPBody(string: body)
        let completePath = basePath + path.childPath
        let queryString = query.createQuery(authKey: self.authKey)
        let urlString = "\(completePath)?\(queryString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(urlString)
        let request = HTTPRequest(method: method, url: URL(string: urlString)!, headers: headers, body: encodedHTTPBody)

        return try httpClient.respond(to: Request(http: request, using: httpClient.container)).flatMap(to: [F].self) { response in
            let res: Future<[F]> = try self.serializedResponse(response: response.http, worker: req, dateDecodingStrategy: nil)
            return res
        }
    }



    private let httpClient: Client
    private let authKey: String
    private let basePath: String

    init(httpClient: Client, authKey: String, basePath: String) {
        self.httpClient = httpClient
        self.authKey = authKey
        self.basePath = basePath
    }

    //    public func serializedResponse<F: Decodable>(response: HTTPResponse, worker: Worker, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) throws -> Future<[F]> {
    //        let decoder = JSONDecoder()
    //        if let dateDecodingStrat = dateDecodingStrategy {
    //            decoder.dateDecodingStrategy = dateDecodingStrat
    //        }
    //
    //        guard response.status == .ok else {
    //            //throw error
    //            print(response)
    //            throw FirebaseRealtimeError.requestFailed
    //        }
    //
    //        return try decoder.decode([String : F].self, from: response, maxSize: 65_536, on: worker).map(to: [F].self) { data in
    //            return Array(data.values)
    //        }
    //    }
    //
    //    public func serializedResponse<F: Decodable>(response: HTTPResponse, worker: Worker, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) throws -> Future<F> {
    //        let decoder = JSONDecoder()
    //        if let dateDecodingStrat = dateDecodingStrategy {
    //            decoder.dateDecodingStrategy = dateDecodingStrat
    //        }
    //
    //        guard response.status == .ok else {
    //            //throw error
    //            print(response)
    //            throw FirebaseRealtimeError.requestFailed
    //        }
    //
    //        return try decoder.decode(F.self, from: response, maxSize: 65_536, on: worker)
    //    }
    //
    //    public func send<F: Decodable>(req: Request, method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> Future<F> {
    //        let encodedHTTPBody = HTTPBody(string: body)
    //        let completePath = basePath + path.childPath
    //        let queryString = query.createQuery(authKey: self.authKey)
    //        let urlString = "\(completePath)?\(queryString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    //        print(urlString)
    //        let request = HTTPRequest(method: method, url: URL(string: urlString)!, headers: headers, body: encodedHTTPBody)
    //
    //        return try httpClient.respond(to: Request(http: request, using: httpClient.container)).flatMap(to: F.self) { response in
    //            return try self.serializedResponse(response: response.http, worker: req, dateDecodingStrategy: nil)
    //        }
    //    }
    //
    //    public func send<F: Decodable>(req: Request, method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> Future<[F]> {
    //        let encodedHTTPBody = HTTPBody(string: body)
    //        let completePath = basePath + path.childPath
    //        let queryString = query.createQuery(authKey: self.authKey)
    //        let urlString = "\(completePath)?\(queryString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    //        print(urlString)
    //        let request = HTTPRequest(method: method, url: URL(string: urlString)!, headers: headers, body: encodedHTTPBody)
    //
    //        return try httpClient.respond(to: Request(http: request, using: httpClient.container)).flatMap(to: [F].self) { response in
    //            let res: Future<[F]> = try self.serializedResponse(response: response.http, worker: req, dateDecodingStrategy: nil)
    //            return res
    //
    //        }
    //    }
}

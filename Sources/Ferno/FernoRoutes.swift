//
//  FirebaseRoutes.swift
//  FirebaseRealtime
//
//  Created by Austin Astorga on 4/30/18.
//

import Vapor


public struct FernoChild: Content {
    public var name: String
}

public struct FernoRoutes {
    private let request: FernoRequest


    init(request: FernoRequest) {
        self.request = request
    }

    //DELETE -> deletes everything
    public func delete(req: Request, appendedPath: [String]) throws -> Future<Bool> {
        let sendReq: Future<Bool> = try self.request.delete(req: req, method: .DELETE, path: appendedPath)
        return sendReq
    }

    //POST -> create child
    public func create<T: Content>(req: Request, appendedPath: [String], body: T) throws -> Future<FernoChild> {
        let sendReq: Future<FernoChild> = try self.request.send(
            req: req,
            method: .POST,
            path: appendedPath,
            query: [],
            body: body,
            headers: [:])
        return sendReq
    }


    //PUT will overwrite everything at that location with the data
    public func overwrite<T: Content>(req: Request, appendedPath: [String], body: T) throws -> Future<T> {
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
    public func update<T: Content>(req: Request, appendedPath: [String], body: T) throws -> Future<T> {
        let sendReq: Future<T> = try self.request.send(
            req: req,
            method: .PATCH,
            path: appendedPath,
            query: [],
            body: body,
            headers: [:])
        return sendReq
    }

    public func retrieveMany<F: Decodable>(req: Request, queryItems: [FernoQuery], appendedPath: [String]) throws -> Future<[String: F]> {
        let sendReq: Future<[String: F]> = try self.request.sendMany(
            req: req,
            method: .GET,
            path: appendedPath,
            query: queryItems,
            body: "",
            headers: [:])
        return sendReq
    }

    public func retrieve<F: Decodable>(req: Request, queryItems: [FernoQuery], appendedPath: [String]) throws -> Future<F> {
        let sendReq: Future<F> = try self.request.send(
            req: req,
            method: .GET,
            path: appendedPath,
            query: queryItems,
            body: "",
            headers: [:])
        return sendReq
    }
}

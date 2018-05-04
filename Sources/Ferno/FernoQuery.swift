//
//  FernoQuery.swift
//  Ferno
//
//  Created by Austin Astorga on 5/4/18.
//

import Foundation

//Firebase Value Enum
//public enum FernoValue {
//
//    case number(Int)
//    case string(String)
//    case boolean(Bool)
//
//    func stringForm() -> String {
//        switch self {
//        case .boolean(let bool):
//            return bool.description
//        case .number(let int):
//            return int.description
//        case .string(let str):
//            return "\"\(str)\""
//        }
//    }
//}

//Firebase Query Params Enum

public enum FernoQuery {
    case shallow(Bool)
    case orderBy(FernoValue)
    case limitToFirst(FernoValue)
    case limitToLast(FernoValue)
    case startAt(FernoValue)
    case endAt(FernoValue)
    case equalTo(FernoValue)
}

extension FernoQuery: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "shallow": self = .shallow(false)
        case "orderBy": self = .orderBy(0)
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

extension Array where Element == FernoQuery {

    func createQuery(authKey: String) -> String {
        let queryString: String = self.map { param in
            let key = param.rawValue
            let value: String = {
                switch param {
                case .shallow(let val):
                    return val.description
                case .orderBy(let val):
                    return val.value
                case .limitToFirst(let val):
                    return val.value
                case .limitToLast(let val):
                    return val.value
                case .startAt(let val):
                    return val.value
                case .endAt(let val):
                    return val.value
                case .equalTo(let val):
                    return val.value
                }
            }()

            return "\(key)=\(value)"
            }.joined(separator: "&")
        return queryString + "&access_token=\(authKey)"
    }
}

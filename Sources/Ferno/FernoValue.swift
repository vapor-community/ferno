//
//  FernoValue.swift
//  Ferno
//
//  Created by Austin Astorga on 5/4/18.
//

import Foundation

public protocol FernoValue {
    var value: String { get }
}

extension String: FernoValue {
    public var value: String {
        return "\"\(self)\""
    }
}

extension Bool: FernoValue {
    public var value: String {
        return self.description
    }
}

extension Int: FernoValue {
    public var value: String {
        return self.description
    }
}

extension Double: FernoValue {
    public var value: String {
        return self.description
    }
}

extension Float: FernoValue {
    public var value: String {
        return self.description
    }
}

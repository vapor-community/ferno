//
//  String+Extensions.swift
//  Ferno
//
//  Created by Maxim Krouk on 6/12/20.
//

import JWT

// MARK: - JWT Helper Stuff

internal extension String {
    var bytes: [UInt8] { .init(self.utf8) }
}

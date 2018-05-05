//
//  Snapshot.swift
//  Ferno
//
//  Created by Austin Astorga on 5/4/18.
//

import Foundation
// module internal
struct Snapshot<T: Decodable>: Decodable {
    let data: [String: T]

    init(from decoder: Decoder) throws {
        if let keyedContainer = try? decoder.singleValueContainer(),
            let decodedData = try? keyedContainer.decode([String: T].self) {
                data = decodedData
                return
            }
        var unkeyedContainer = try decoder.unkeyedContainer()
        let decodedArrayData = try unkeyedContainer.decode([T?].self)
        let pairs = decodedArrayData.enumerated().compactMap { index, element -> (String, T)? in
            guard let element = element else {
                return nil
            }

            return (index.description, element)
        }

        data = Dictionary(uniqueKeysWithValues: pairs)
    }
}

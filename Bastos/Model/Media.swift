//
//  Media.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import Photos

struct Media: Identifiable, Equatable {
    var id: String
    var asset: PHAsset
    var date: String

    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.date = asset.addedDate.formatted(date: .abbreviated, time: .omitted)
    }
}

//
//  ViewedImageRepositoryProtocol.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 16/01/26.
//

import Foundation

protocol ViewedImageRepositoryProtocol {
    func fetchReadAssetIDs() -> Set<String>
    func markAssetAsViewed(asset: Media)
    func markMultipleAssetsAsViewed(assets: [Media])
}

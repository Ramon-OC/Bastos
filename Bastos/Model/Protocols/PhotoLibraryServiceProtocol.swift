//
//  PhotoLibraryServiceProtocol.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 14/01/26.
//

import SwiftUI
import Photos

protocol PhotoLibraryServiceProtocol {
    func checkAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void)
    func fetchPhotos(completion: @escaping ([Media]) -> Void)
    func loadImage(for media: Media, targetSize: CGSize, completion: @escaping (UIImage?) -> Void)
    func loadMultipleImages(for medias: [Media], targetSize: CGSize, completion: @escaping ([UIImage?]) -> Void)
    func toggleFavorite(for media: Media) async throws
    func hideMultipleImages(medias: [Media]) async throws
    func deleteMultipleAsstes(for medias: [Media]) async throws
}

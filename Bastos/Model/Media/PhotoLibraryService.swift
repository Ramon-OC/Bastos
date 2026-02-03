//
//  PhotoLibraryService.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 14/01/26.
//

import SwiftUI
import Photos

enum MediaSort: String, CaseIterable, Identifiable{
    case dateAscending, dateDescending, random
    
    var id: Self { self }
    
    var title: String {
            switch self {
            case .dateAscending:
                return String(localized: .oldestFirst)
            case .dateDescending:
                return String(localized: .newestFirst)
            case .random:
                return String(localized: .random)
            }
        }
    
    func getMediaType() -> NSSortDescriptor{
        switch self {
        case .dateAscending:
            NSSortDescriptor(key: "creationDate", ascending: true)
        case .dateDescending:
            NSSortDescriptor(key: "creationDate", ascending: false)
        case .random:
            NSSortDescriptor(key: "creationDate", ascending: false)
        }
    }
    
}


final class PhotoLibraryService: PhotoLibraryServiceProtocol {

    private let imageManager = PHCachingImageManager()

    func checkAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus)
                }
            }
        } else {
            completion(status)
        }
    }

    func fetchPhotos(sortType: MediaSort, completion: @escaping ([Media]) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            sortType.getMediaType()
        ]

        let result = PHAsset.fetchAssets(with: .image, options: options)
        var medias: [Media] = []

        result.enumerateObjects { asset, _, _ in
            medias.append(Media(asset: asset))
        }

        completion(medias)
    }

    func loadImage(
        for media: Media,
        targetSize: CGSize,
        completion: @escaping (UIImage?) -> Void
    ) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        imageManager.requestImage(
            for: media.asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            completion(image)
        }
    }

    func loadMultipleImages(
        for medias: [Media],
        targetSize: CGSize,
        completion: @escaping ([UIImage?]) -> Void
    ) {
        let group = DispatchGroup()
        var images = [UIImage?](repeating: nil, count: medias.count)

        for (index, media) in medias.enumerated() {
            group.enter()
            loadImage(for: media, targetSize: targetSize) { image in
                images[index] = image
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(images)
        }
    }

    // MARK: - photo manipulation actions [hide, remove]
    func hideMultipleImages(medias: [Media]) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            for media in medias {
                let request = PHAssetChangeRequest(for: media.asset)
                request.isHidden = true
            }
        }
    }

    func toggleFavorite(for media: Media) async throws {
        let newFavoriteState = !media.asset.isFavorite

        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest(for: media.asset)
            request.isFavorite = newFavoriteState
        }
    }

    func deleteMultipleAsstes(for medias: [Media]) async throws {
        let assets: [PHAsset] = medias.map { $0.asset }
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }
    }

}

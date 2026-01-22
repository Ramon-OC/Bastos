//
//  PhotoLibraryService.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 14/01/26.
//

import SwiftUI
import Photos

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

    func fetchPhotos(completion: @escaping ([Media]) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
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
    func hideMultipleImages(for medias: [Media]) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            for media in medias {
                let request = PHAssetChangeRequest(for: media.asset)
                request.isHidden = true
            }
        }
    }

//    USAGE
//    Task {
//        do {
//            try await hideMultipleImages(for: medias)
//        } catch {
//            print("Failed to hide images:", error)
//        }
//    }

    func toggleFavorite(for asset: PHAsset) {
        PHPhotoLibrary.shared().performChanges {
            // Create a change request from the asset to be modified.
            let request = PHAssetChangeRequest(for: asset)
            // Set a property of the request to change the asset itself.
            request.isFavorite = !asset.isFavorite
        } completionHandler: { success, error in
            print("Finished updating asset. " + (success ? "Success." : error!.localizedDescription))
        }
    }

}

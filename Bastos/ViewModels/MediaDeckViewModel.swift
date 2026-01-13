//
//  MediaDeckView.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import Photos
import SwiftUI

extension MediaDeckView {

    @Observable
    class ViewModel {
        private var photos: [Media] = [] // all pics
        var showingMedia: [Media] = []

        var authorizationStatus: PHAuthorizationStatus = .notDetermined
        var isLoading = false
        private let imageManager = PHCachingImageManager()

        // for deck
        var removalTransition = AnyTransition.trailingBottom
        let dragThreshold: CGFloat = 80.0

        init() {
            checkAuthorization()
            updateUpcomingImages()
            if photos.count > 2 {
                showingMedia = Array(photos.prefix(2))
            }
        }

        func checkAuthorization() {
            authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

            if authorizationStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        authorizationStatus = status
                        if status == .authorized || status == .limited {
                            fetchPhotos()
                        }
                    }
                }
            } else if authorizationStatus == .authorized || authorizationStatus == .limited {
                fetchPhotos()
            }
        }

        func fetchPhotos() {
            isLoading = true

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            var tempPhotos: [Media] = []
            fetchResult.enumerateObjects { asset, _, _ in
                tempPhotos.append(Media(asset: asset))
            }

            photos = tempPhotos
            isLoading = false
        }

        func loadImage(for media: Media, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
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

        func loadMultipleImages(for medias: [Media], targetSize: CGSize, completion: @escaping ([UIImage?]) -> Void) {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true

            let group = DispatchGroup()
            var results: [UIImage?] = Array(repeating: nil, count: medias.count)

            for (index, media) in medias.enumerated() {
                group.enter()

                imageManager.requestImage(
                    for: media.asset,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: options
                ) { image, _ in
                    results[index] = image
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(results)
            }
        }

        // for deck managment
        var lastIndex = 1
        var lastUpcomingIndex: Int { min(lastIndex + 4, photos.count - 1) }
        var upcomingMedia: [Media] = []

        func isTopCard(_ media: Media) -> Bool {
            guard let index = showingMedia.firstIndex(where: { $0.id == media.id }) else {
                return false
            }
            return index == 0
        }

        func moveCard() {
            showingMedia.removeFirst()
            self.lastIndex += 1

            if lastIndex < photos.count {
                showingMedia.append(photos[lastIndex])
            }

        }

        func updateUpcomingImages() {
            upcomingMedia = []
            for index in lastIndex...lastUpcomingIndex {
                upcomingMedia.append(photos[index])
            }
        }
    }
}

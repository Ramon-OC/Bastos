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

        private let photoService: PhotoLibraryServiceProtocol

        private var fetchedPhotos: [Media] = [] // all pics
        var showingMedia: [Media] = []
        var showingUpcomingMedia: [Media] =  []

        private var removeAssets: [PHAsset] = []
        private var saveAssets: [PHAsset] = []

        // index
        var lastIndex = 1
        var lastUpcomingIndex: Int { min(lastIndex + 4, fetchedPhotos.count - 1) }

        var authorizationStatus: PHAuthorizationStatus = .notDetermined
        var isLoading = false
        private let imageManager = PHCachingImageManager()

        // for deck
        var removalTransition = AnyTransition.trailingBottom
        let dragThreshold: CGFloat = 80.0

        // for bottom bar
        var remainMessage: String = "01 de 1000"

        init(photoService: PhotoLibraryServiceProtocol = PhotoLibraryService()) {
            self.photoService = photoService
            checkAuthorization()
            updateUpcomingImages()
            if fetchedPhotos.count > 2 {
                showingMedia = Array(fetchedPhotos.prefix(2))
            }
        }

        func checkAuthorization() {
            photoService.checkAuthorization { [weak self] status in
                if status == .authorized || status == .limited {
                    self?.fetchPhotos()
                }
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

            fetchedPhotos = tempPhotos
            isLoading = false
        }

        func loadImage(for media: Media, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
                   photoService.loadImage(
                       for: media,
                       targetSize: targetSize
                   ) { image in
                       completion(image)
                   }
               }

        func loadMultipleImages(for media: [Media], targetSize: CGSize, completion: @escaping ([UIImage?]) -> Void) {
            photoService.loadMultipleImages(
                for: media,
                targetSize: targetSize
            ) { images in
                completion(images.compactMap { $0 })
            }
        }

        // for deck managment
        func isTopCard(_ media: Media) -> Bool {
            guard let index = showingMedia.firstIndex(where: { $0.id == media.id }) else {
                return false
            }
            return index == 0
        }

        private func updateDeckImages() {
            showingMedia.removeFirst()
            self.lastIndex += 1
            if lastIndex < fetchedPhotos.count {
                showingMedia.append(fetchedPhotos[lastIndex])
            }
        }

        private func updateUpcomingImages() {
            showingUpcomingMedia = []

            if lastIndex < fetchedPhotos.count {
                for index in lastIndex...lastUpcomingIndex {
                    showingUpcomingMedia.append(fetchedPhotos[index])
                }
            }
        }

        private func moveCard() {
            updateDeckImages()
            updateUpcomingImages()
        }

        // MARK: VIEW FUNCTIONS
        func leftCardSwipe(asset: PHAsset) {
            removeAssets.append(asset)
            moveCard()
        }

        func rightCardSwipe(asset: PHAsset) {
            saveAssets.append(asset)
            moveCard()
        }

        func centerButtonPressed() {

        }

        func leftButtonPressed() {

        }

        func rightButtonPressed() {

        }
    }
}

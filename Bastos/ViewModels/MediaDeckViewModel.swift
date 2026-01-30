//
//  MediaDeckViewModel.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 20/01/26.
//

import Photos
import SwiftUI

extension MediaDeckView {

    enum SwipeAction {
        case none
        case remove
        case save
        case hide
    }

    enum ModifyAction {
        case none
        case undo
        case hide
    }

    @Observable
    class MediaDeckViewModel {
        private let photoService: PhotoLibraryServiceProtocol
        private let coreDataRepository: ViewedImageRepositoryProtocol

        private var fetchedPhotos: [Media] = []  // all pics
        private var swipeActionHistory: [SwipeAction] = []

        private var toRemoveAssets: [Media] = [] // temp arrays for storing elements to be saved or deleted
        private var toSaveAssets: [Media] = []
        private var toHideAssets: [Media] = []
        private var toFavoriteAssets: [Media] = []

        var deckMedia: [Media] = []              // only stores media that is displayed on screen
        var upcomingMedia: [Media] = []

        private var imageOnDisplayIndex: Int = 0

        init(photoService: PhotoLibraryServiceProtocol = PhotoLibraryService(),
             repository: ViewedImageRepositoryProtocol) {
            self.coreDataRepository = repository
            self.photoService = photoService
            fetchPhotos()
        }

        // MARK: - model
        // takes the next five (or fewer if there aren't enough) images from the list and saves them to 'upcomingMedia'
        private func setUpcomingImages() {
            upcomingMedia = []
            if (imageOnDisplayIndex + 1) < fetchedPhotos.count {
                for index in (imageOnDisplayIndex + 1)...min(imageOnDisplayIndex + 5, fetchedPhotos.count - 1) {
                    upcomingMedia.append(fetchedPhotos[index])
                }

            }
        }

        // takes media from the current index and the next one to manage the deck (it only has two cards)
        private func setDeckImages() {
            deckMedia = []
            if (imageOnDisplayIndex + 1) == (fetchedPhotos.count) { // is last card
                deckMedia.append(fetchedPhotos[imageOnDisplayIndex])
            } else if (imageOnDisplayIndex+1) < fetchedPhotos.count {
                deckMedia.append(fetchedPhotos[imageOnDisplayIndex])
                deckMedia.append(fetchedPhotos[imageOnDisplayIndex+1])
            }
        }

        private func moveCard() {
            self.imageOnDisplayIndex += 1
            setUpcomingImages()
            setDeckImages()
        }

        private func undoSwipe(lastAction type: SwipeAction) {
            switch type {
            case .none:
                return
            case .remove:
                if toRemoveAssets.isEmpty { return }
                toRemoveAssets.removeLast()
                self.imageOnDisplayIndex -= 1
                setUpcomingImages()
                setDeckImages()
            case .save:
                if toSaveAssets.isEmpty { return }
                toSaveAssets.removeLast()

                self.imageOnDisplayIndex -= 1
                setUpcomingImages()
                setDeckImages()
            case .hide:
                if toHideAssets.isEmpty { return }
                toHideAssets.removeLast()
                self.imageOnDisplayIndex -= 1
                setUpcomingImages()
                setDeckImages()
            }
        }

        func isTopCard(_ media: Media) -> Bool {
            guard let index = deckMedia.firstIndex(where: { $0.id == media.id }) else {
                return false
            }
            return index == 0
        }

        func isCurrentAssetFavorite() -> Bool {
            if imageOnDisplayIndex < fetchedPhotos.count {
                return fetchedPhotos[imageOnDisplayIndex].isFavorite
            } else {
                return false
            }
        }

        private func toggleFavorite() async {
            if imageOnDisplayIndex < fetchedPhotos.count {
                do {
                    try await photoService.toggleFavorite(
                        for: fetchedPhotos[imageOnDisplayIndex]
                    )
                    fetchedPhotos[imageOnDisplayIndex].isFavorite.toggle() // for the library
                } catch {
                    print("Error toggling favorite:", error)
                }
            }
        }

        private func emptyAllLists() {
            toRemoveAssets = []
            toSaveAssets = []
            toHideAssets = []
            toFavoriteAssets = []
        }

        // MARK: - computed view vars
        var remainMessage: String {
            toRemoveAssets.count > 0 ? "Borrar \(String(toRemoveAssets.count)) elementos" :
            "Desliza a la izquierda para eliminar"
        }

        // MARK: - view actions functions
        func leftCardSwipe(media: Media) {
            swipeActionHistory.append(.remove)
            toRemoveAssets.append(media)
            moveCard()
        }

        func rightCardSwipe(media: Media) {
            swipeActionHistory.append(.save)
            toSaveAssets.append(media)
            moveCard()
        }

        func leftButtonPressed() { // undo last swipe
            if swipeActionHistory.isEmpty {return}
            switch swipeActionHistory.removeLast() {
            case .none:
                return
            case .remove:
                undoSwipe(lastAction: .remove)
            case .save:
                undoSwipe(lastAction: .save)
            case .hide:
                undoSwipe(lastAction: .hide)
            }

        }

        // This button executes all changes to the assets.
        func centerButtonPressed() {
            // 1. Mark saved items as read
            coreDataRepository.markMultipleAssetsAsViewed(assets: toSaveAssets)
            // 2. Mark hidden items as read
            coreDataRepository.markMultipleAssetsAsViewed(assets: toHideAssets)
            // 4. Delete deleted items from the library list
            Task {
                do {
                    try await photoService.hideMultipleImages(medias: toHideAssets)
                    try await photoService.deleteMultipleAsstes(for: toRemoveAssets)
                    emptyAllLists()
                } catch {
                    print(error)
                }
            }

            // 6. Refresh assets for display
        }

        func right01ButtonPressed() { // hide image
            swipeActionHistory.append(.hide)
            toHideAssets.append(fetchedPhotos[imageOnDisplayIndex])
            moveCard()
        }

        func right02ButtonPressed() async { // mark as favorite
            await toggleFavorite()
        }

        func centerButtonIsDisabled() -> Bool {
            false
        }

        // MARK: - photo service functions [fetching]
        // loads user's entire library using media service
//        private func fetchPhotos() {
//            photoService.checkAuthorization { [weak self] status in
//                if status == .authorized || status == .limited {
//                    self?.photoService.fetchPhotos { media in
//                        self?.fetchedPhotos = media
//                    }
//                }
//            }
//        }

        // MARK: - photo service functions [fetching]
        // loads user's entire library using media service
        private func fetchPhotos() {
            photoService.checkAuthorization { [weak self] status in
                if status == .authorized || status == .limited {
                    // 1. Primero obtener los IDs de assets ya vistos desde Core Data
                    let viewedAssetIDs = self?.coreDataRepository.fetchReadAssetIDs() ?? []

                    // 2. Luego hacer fetch de todas las fotos
                    self?.photoService.fetchPhotos { media in
                        // 3. Filtrar las fotos para excluir las ya vistas
                        let unfilteredPhotos = media.filter { photo in
                            !viewedAssetIDs.contains(photo.id)
                        }

                        // 4. Guardar las fotos filtradas
                        self?.fetchedPhotos = unfilteredPhotos

                        // 5. Actualizar las vistas después del filtrado
                        self?.setDeckImages()
                        self?.setUpcomingImages()
                    }
                }
            }
        }

        // allows a subview in onappear to load a single media asset
        func loadSingleUIImage(for media: Media, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
            photoService.loadImage(for: media, targetSize: targetSize) { image in
                completion(image)
            }
        }

        // allows a subview in onappear to load multiple media assets
        func loadMultipleUIImages(for media: [Media], targetSize: CGSize, completion: @escaping ([UIImage?]) -> Void) {
            photoService.loadMultipleImages(for: media, targetSize: targetSize) { images in
                completion(images.compactMap { $0 })
            }
        }

        // MARK: - view personalitatio
        var removalTransition: AnyTransition = AnyTransition.trailingBottom
        let dragThreshold: CGFloat = 80.0

        var toRemoveCount: Int { toRemoveAssets.count }
        var toSaveCount: Int { toSaveAssets.count }
        var toHideCount: Int { toHideAssets.count }

    }
}

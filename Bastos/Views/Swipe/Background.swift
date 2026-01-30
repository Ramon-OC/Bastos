//
//  Background.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 22/01/26.
//

import SwiftUI

 struct Background: View {

    var viewModel: MediaDeckView.MediaDeckViewModel

    @State private var image: UIImage?
    @State private var fadeTrigger = false

    // Task cancelable para debounce
    @State private var loadTask: Task<Void, Never>?

    // ID del media actualmente esperado
    @State private var currentMediaID: String?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(2)
                    .blur(radius: 100)
                    .opacity(fadeTrigger ? 1 : 0.8)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0),
                                Color.black.opacity(0.4)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
        }
        .animation(.easeInOut(duration: 1), value: fadeTrigger)
        .onAppear {
            scheduleThumbnailLoad()
        }
        .onChange(of: viewModel.deckMedia) {
            scheduleThumbnailLoad()
        }
    }

    // MARK: - Debounce con cancelación

    private func scheduleThumbnailLoad() {
        loadTask?.cancel()

        guard viewModel.deckMedia.count > 1 else {
            image = nil
            return
        }

        let media = viewModel.deckMedia[0]
        currentMediaID = media.id

        loadTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            guard !Task.isCancelled else { return }

            await MainActor.run {
                loadThumbnail(for: media)
            }
        }
    }

    // MARK: - Carga real

    private func loadThumbnail(for media: Media) {
        let targetSize = CGSize(width: 40, height: 40)

        fadeTrigger = false

        viewModel.loadSingleUIImage(
            for: media,
            targetSize: targetSize
        ) { newImage in
            // 🔐 Si el usuario ya cambió, ignoramos esta imagen
            guard currentMediaID == media.id else { return }

            image = newImage
            fadeTrigger = true
        }
    }
 }
